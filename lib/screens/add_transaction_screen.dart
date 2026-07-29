// ignore_for_file: library_private_types_in_public_api

import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/l10n/localization_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../features/speech/application/speech_assistant_controller.dart';
import '../features/speech/application/speech_assistant_state.dart';
import '../features/speech/domain/expense_voice_parser.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/category_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/income_distribution_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/colors/app_colors.dart';
import '../theme/billey_theme_scope.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  final TransactionType initialType;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.initialType = TransactionType.gasto,
  });

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final TextEditingController _amountController;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late String _id;
  late DateTime _date;
  late TransactionType _type;
  CategoryModel? _selectedCategory;
  bool _autoDistributeIncome = true;
  double _essentialsPercent = 50;
  double _wantsPercent = 30;
  double _savingsPercent = 20;
  String _distributionTemplateId = 'balanced_50_30_20';
  bool _distributionLoaded = false;
  SpeechAssistantController? _speechController;
  bool _speechSessionInitialized = false;
  String? _lastAppliedTranscript;
  String? _voiceSummary;
  String? _voiceConfirmationText;

  bool get _isIncome => _type == TransactionType.ingreso;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    final transaction = widget.transaction;
    _amountController = TextEditingController(
      text: transaction != null ? _initialAmountText(transaction.amount) : '',
    );

    if (transaction != null) {
      _id = transaction.id!;
      _titleController.text = transaction.title;
      _descriptionController.text = transaction.description ?? '';
      _date = transaction.date;
      _type = transaction.type;
    } else {
      _id = DateTime.now().millisecondsSinceEpoch.toString();
      _date = DateTime.now();
      _type = widget.initialType;
    }

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final speechController = context.read<SpeechAssistantController>();
    if (!identical(_speechController, speechController)) {
      _speechController?.removeListener(_handleSpeechResult);
      _speechController = speechController..addListener(_handleSpeechResult);
    }
    if (!_speechSessionInitialized) {
      _speechSessionInitialized = true;
      speechController.resetSession(notify: false);
    }
    if (_distributionLoaded) return;

    final distribution = context.watch<IncomeDistributionProvider>();
    if (!distribution.isLoaded) return;

    final active = distribution.activeTemplate;
    _autoDistributeIncome = distribution.autoEnabled;
    _essentialsPercent = active.essentials;
    _wantsPercent = active.wants;
    _savingsPercent = active.savings;
    _distributionTemplateId = active.id;
    _distributionLoaded = true;
  }

  @override
  void dispose() {
    _speechController?.removeListener(_handleSpeechResult);
    _speechController?.resetSession(notify: false);
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _localizedTemplateName(AppLocalizations l10n) {
    for (final template in IncomeDistributionProvider.templates) {
      if (template.id == _distributionTemplateId) {
        return template.localizedName(l10n);
      }
    }
    return l10n.templateCustomName;
  }

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    final l10n = context.l10n;
    final speechState = context.watch<SpeechAssistantController>().state;
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              final categories = categoryProvider.categories.isNotEmpty
                  ? categoryProvider.categories
                  : CategoryModel.getDefaultCategories();
              _selectedCategory ??= _findInitialCategory(categories);

              if (_isIncome) {
                return _buildIncomeScreen(categories);
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _ModalHeader(
                      title: widget.transaction == null
                          ? l10n.newExpense
                          : l10n.editExpense,
                      onClose: () => Navigator.pop(context),
                      onSave: _saveTransaction,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
                      child: Column(
                        children: [
                          _ConceptField(controller: _titleController),
                          const SizedBox(height: 26),
                          _CategoryPill(
                            category: _selectedCategory!,
                            onTap: () => _showCategoryPicker(categories),
                          ),
                          const SizedBox(height: 30),
                          _AmountInputField(
                            controller: _amountController,
                            isIncome: false,
                            onChanged: () => setState(() {}),
                          ),
                          const SizedBox(height: 30),
                          _VoiceButton(
                            state: speechState,
                            resultSummary: _voiceSummary,
                            onTap: _toggleVoiceListening,
                            onPlay: _playVoiceConfirmation,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeScreen(List<CategoryModel> categories) {
    final amount = _parsedAmount;
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 14),
            child: Column(
              children: [
                _IncomeHeader(
                  title: widget.transaction == null
                      ? l10n.addIncomeTitle
                      : l10n.editIncomeTitle,
                  onBack: () => Navigator.pop(context),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 58, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: _AmountInputField(
                          controller: _amountController,
                          isIncome: true,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 36),
                      _IncomeLabel(l10n.source),
                      const SizedBox(height: 10),
                      _IncomeSourceField(
                        controller: _titleController,
                        onClear: () => setState(_titleController.clear),
                      ),
                      const SizedBox(height: 18),
                      _IncomeLabel(l10n.date),
                      const SizedBox(height: 10),
                      _IncomeDateTile(
                        date: _date,
                        onTap: _presentDatePicker,
                      ),
                      const SizedBox(height: 40),
                      _DistributionCard(
                        amount: amount,
                        autoDistribute: _autoDistributeIncome,
                        templateName: _localizedTemplateName(l10n),
                        essentialsPercent: _essentialsPercent,
                        wantsPercent: _wantsPercent,
                        savingsPercent: _savingsPercent,
                        onAutoDistributeChanged: (value) {
                          setState(() => _autoDistributeIncome = value);
                          context
                              .read<IncomeDistributionProvider>()
                              .setAutoEnabled(value);
                        },
                      ),
                      const SizedBox(height: 26),
                      Center(
                        child: TextButton.icon(
                          onPressed: _showDistributionRulesEditor,
                          icon: const Icon(
                            TablerIcons.adjustments_horizontal,
                            size: 16,
                          ),
                          label: Text(l10n.editDistributionRules),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.primaryColor.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.depositFunds,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(TablerIcons.arrow_right, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  CategoryModel _findInitialCategory(List<CategoryModel> categories) {
    final transaction = widget.transaction;
    if (transaction == null) return categories.first;

    return categories.firstWhere(
      (category) => category.transactionCategory == transaction.category,
      orElse: () => categories.first,
    );
  }

  double get _parsedAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0;

  static String _initialAmountText(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.round().toString();
    }
    return amount.toStringAsFixed(2);
  }

  Future<void> _toggleVoiceListening() async {
    final controller = context.read<SpeechAssistantController>();
    if (controller.state.status == SpeechAssistantStatus.unavailable) {
      _showErrorMessage(
        controller.state.errorMessage ?? context.l10n.voiceNotAvailable,
      );
      return;
    }
    if (controller.state.status == SpeechAssistantStatus.recording) {
      await controller.stopRecordingAndTranscribe();
    } else {
      await controller.startRecording();
    }
  }

  void _handleSpeechResult() {
    if (!mounted) return;
    final state = _speechController?.state;
    if (state?.status != SpeechAssistantStatus.transcriptionSuccess) return;
    final transcript = state?.transcript?.text.trim();
    if (transcript == null ||
        transcript.isEmpty ||
        transcript == _lastAppliedTranscript) {
      return;
    }
    _lastAppliedTranscript = transcript;

    final provider = context.read<CategoryProvider>();
    final categories = provider.categories.isNotEmpty
        ? provider.categories
        : CategoryModel.getDefaultCategories();
    final draft = const ExpenseVoiceParser().parse(
      transcript,
      now: DateTime.now(),
      customCategories: {
        for (final category in categories) category.id: category.name,
      },
    );
    final category = categories.firstWhere(
      (item) => item.id == draft.categoryId,
      orElse: () => categories.firstWhere(
        (item) => item.id == 'other',
        orElse: () => categories.first,
      ),
    );
    final title = draft.title == 'Gasto' && category.id != 'other'
        ? category.name
        : draft.title;

    setState(() {
      _titleController.text = title;
      if (draft.amount != null) {
        _amountController.text = _initialAmountText(draft.amount!);
      }
      _selectedCategory = category;
      _date = draft.date;
      _voiceConfirmationText = transcript;
      _voiceSummary = draft.amount == null
          ? '$title · ${category.name}'
          : '$title · \$${NumberFormat('#,##0', 'es').format(draft.amount)} · ${category.name}';
    });
  }

  Future<void> _playVoiceConfirmation() async {
    final controller = context.read<SpeechAssistantController>();
    final confirmationText = _voiceConfirmationText;
    if (confirmationText == null || confirmationText.isEmpty) return;
    await controller.generateAndPlaySpeech(
      '${context.l10n.voiceConfirmationPrefix} $confirmationText',
    );
  }

  Future<void> _showDistributionRulesEditor() async {
    final result = await Navigator.of(context).push<_DistributionRules>(
      MaterialPageRoute(
        builder: (context) => _AutomatedRulesScreen(
          essentialsPercent: _essentialsPercent,
          wantsPercent: _wantsPercent,
          savingsPercent: _savingsPercent,
          monthlyAmount: _parsedAmount,
        ),
      ),
    );

    if (result != null && mounted) {
      await context.read<IncomeDistributionProvider>().saveCustom(
            essentials: result.essentials,
            wants: result.wants,
            savings: result.savings,
          );
      if (!mounted) return;
      setState(() {
        _essentialsPercent = result.essentials;
        _wantsPercent = result.wants;
        _savingsPercent = result.savings;
        _distributionTemplateId = IncomeDistributionProvider.customTemplateId;
      });
    }
  }

  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final base = isDark ? ThemeData.dark() : ThemeData.light();

        return Theme(
          data: base.copyWith(
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: AppColors.surfaceColor,
              onSurface: AppColors.textPrimary,
              secondary: AppColors.primaryColor,
              onSecondary: Colors.white,
              error: AppColors.errorColor,
              onError: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.backgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _date) {
      setState(() => _date = pickedDate);
    }
  }

  Future<void> _showCategoryPicker(List<CategoryModel> categories) async {
    final selected = await showModalBottomSheet<CategoryModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = context.l10n;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.chooseCategory,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final category in categories)
                      _CategoryChoice(
                        category: category,
                        selected: _selectedCategory?.id == category.id,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedCategory = selected);
    }
  }

  Future<void> _saveTransaction() async {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (title.length < 3) {
      _showErrorMessage(l10n.conceptMinLength);
      return;
    }

    if (amount == null || amount <= 0) {
      _showErrorMessage(l10n.amountMustBePositive);
      return;
    }

    final category = _selectedCategory;
    if (category == null) {
      _showErrorMessage(l10n.selectCategory);
      return;
    }

    final description = _descriptionController.text.trim();
    final distributionDescription = _isIncome && _autoDistributeIncome
        ? l10n.autoDistributionNote(
            '${_essentialsPercent.round()}',
            '${_wantsPercent.round()}',
            '${_savingsPercent.round()}',
          )
        : '';

    final transaction = TransactionModel(
      id: _id,
      title: title,
      amount: amount,
      date: _date,
      type: _type,
      category: category.transactionCategory,
      description: [
        if (description.isNotEmpty) description,
        if (distributionDescription.isNotEmpty) distributionDescription,
      ].join(' | ').trim().isEmpty
          ? null
          : [
              if (description.isNotEmpty) description,
              if (distributionDescription.isNotEmpty) distributionDescription,
            ].join(' | '),
    );

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    if (widget.transaction == null) {
      await provider.addTransaction(transaction);
      if (mounted) {
        _showSuccessMessage(l10n.transactionAdded);
        Navigator.of(context).pop();
      }
    } else {
      await provider.editTransaction(transaction);
      if (mounted) {
        _showSuccessMessage(l10n.transactionUpdated);
        Navigator.of(context).pop();
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(TablerIcons.check, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(TablerIcons.alert_circle, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _IncomeHeader({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              TablerIcons.chevron_left,
              color: AppColors.textPrimary,
              size: 30,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _IncomeLabel extends StatelessWidget {
  final String text;

  const _IncomeLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _IncomeSourceField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _IncomeSourceField({
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: AppColors.primaryColor,
      decoration: InputDecoration(
        hintText: l10n.sourceHint,
        hintStyle: TextStyle(color: AppColors.textPrimary),
        prefixIcon: const Icon(
          TablerIcons.briefcase,
          color: AppColors.primaryColor,
        ),
        suffixIcon: IconButton(
          onPressed: onClear,
          icon: Icon(
            TablerIcons.circle_x,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: AppColors.surfaceInput,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.primaryColor.withValues(alpha: 0.22),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.primaryColor.withValues(alpha: 0.22),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}

class _IncomeDateTile extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _IncomeDateTile({
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = DateFormat('MMM d').format(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              TablerIcons.calendar,
              color: AppColors.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.todayDate(label),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              TablerIcons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  final double amount;
  final bool autoDistribute;
  final String templateName;
  final double essentialsPercent;
  final double wantsPercent;
  final double savingsPercent;
  final ValueChanged<bool> onAutoDistributeChanged;

  const _DistributionCard({
    required this.amount,
    required this.autoDistribute,
    required this.templateName,
    required this.essentialsPercent,
    required this.wantsPercent,
    required this.savingsPercent,
    required this.onAutoDistributeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const essentialsBucket = DistributionBucket(
      id: 'essentials',
      label: 'Essentials',
      percent: 50,
      iconKey: 'home',
      colorValue: 0xFF2D6CDF,
    );
    const wantsBucket = DistributionBucket(
      id: 'wants',
      label: 'Wants',
      percent: 30,
      iconKey: 'bag',
      colorValue: 0xFF8B4DD7,
    );
    const savingsBucket = DistributionBucket(
      id: 'savings',
      label: 'Savings',
      percent: 20,
      iconKey: 'pig',
      colorValue: 0xFF0EA56A,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.autoDistributeIncome,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      autoDistribute
                          ? l10n.usingTemplate(templateName)
                          : l10n.distributionPaused,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: autoDistribute,
                onChanged: onAutoDistributeChanged,
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.primaryColor,
                inactiveThumbColor: AppColors.textSecondary,
                inactiveTrackColor: AppColors.textLight,
              ),
            ],
          ),
          Divider(
            height: 30,
            color: AppColors.borderSubtle.withValues(alpha: 0.8),
          ),
          _DistributionRow(
            icon: TablerIcons.home,
            title: essentialsBucket.localizedLabel(l10n),
            subtitle: l10n.percentAllocation(
              '${essentialsPercent.round()}',
            ),
            amount: autoDistribute ? amount * essentialsPercent / 100 : 0,
            color: const Color(0xFF2D6CDF),
            enabled: autoDistribute,
          ),
          const SizedBox(height: 16),
          _DistributionRow(
            icon: TablerIcons.shopping_bag,
            title: wantsBucket.localizedLabel(l10n),
            subtitle: l10n.percentAllocation('${wantsPercent.round()}'),
            amount: autoDistribute ? amount * wantsPercent / 100 : 0,
            color: const Color(0xFF8B4DD7),
            enabled: autoDistribute,
          ),
          const SizedBox(height: 16),
          _DistributionRow(
            icon: TablerIcons.pig_money,
            title: savingsBucket.localizedLabel(l10n),
            subtitle: l10n.percentAllocation('${savingsPercent.round()}'),
            amount: autoDistribute ? amount * savingsPercent / 100 : 0,
            color: const Color(0xFF0EA56A),
            enabled: autoDistribute,
          ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double amount;
  final Color color;
  final bool enabled;

  const _DistributionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = context.watch<CurrencyProvider>().format(amount);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: enabled ? color : AppColors.textSecondary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color:
                      enabled ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          '+\$$formatted',
          style: TextStyle(
            color: enabled ? AppColors.primaryColor : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DistributionRules {
  final double essentials;
  final double wants;
  final double savings;

  const _DistributionRules({
    required this.essentials,
    required this.wants,
    required this.savings,
  });
}

class _AutomatedRulesScreen extends StatefulWidget {
  final double essentialsPercent;
  final double wantsPercent;
  final double savingsPercent;
  final double monthlyAmount;

  const _AutomatedRulesScreen({
    required this.essentialsPercent,
    required this.wantsPercent,
    required this.savingsPercent,
    required this.monthlyAmount,
  });

  @override
  State<_AutomatedRulesScreen> createState() => _AutomatedRulesScreenState();
}

class _AutomatedRulesScreenState extends State<_AutomatedRulesScreen> {
  late double _essentials;
  late double _wants;
  late double _savings;

  double get _total => _essentials + _wants + _savings;
  bool get _isValid => _total.round() == 100;

  @override
  void initState() {
    super.initState();
    _essentials = widget.essentialsPercent;
    _wants = widget.wantsPercent;
    _savings = widget.savingsPercent;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const essentialsBucket = DistributionBucket(
      id: 'essentials',
      label: 'Essentials',
      percent: 50,
      iconKey: 'home',
      colorValue: 0xFF2D6CDF,
    );
    const wantsBucket = DistributionBucket(
      id: 'wants',
      label: 'Wants',
      percent: 30,
      iconKey: 'bag',
      colorValue: 0xFF8B4DD7,
    );
    const savingsBucket = DistributionBucket(
      id: 'savings',
      label: 'Savings',
      percent: 20,
      iconKey: 'pig',
      colorValue: 0xFF0EA56A,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        TablerIcons.arrow_left,
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.automatedRules,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.35,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _reset,
                      child: Text(
                        l10n.reset,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 18, 30, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.totalAllocation,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Text(
                          '${_total.round()}%',
                          style: TextStyle(
                            color: _isValid
                                ? AppColors.primaryColor
                                : AppColors.expenseColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: (_total / 100).clamp(0, 1),
                        color: _isValid
                            ? AppColors.primaryColor
                            : AppColors.expenseColor,
                        backgroundColor:
                            AppColors.textLight.withValues(alpha: 0.22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                  children: [
                    _AutomatedRuleCard(
                      icon: TablerIcons.home,
                      title: essentialsBucket.localizedLabel(l10n),
                      value: _essentials,
                      monthlyAmount: widget.monthlyAmount,
                      color: AppColors.primaryColor,
                      onChanged: (value) {
                        setState(() => _essentials = value.roundToDouble());
                      },
                    ),
                    const SizedBox(height: 16),
                    _AutomatedRuleCard(
                      icon: TablerIcons.hanger,
                      title: wantsBucket.localizedLabel(l10n),
                      value: _wants,
                      monthlyAmount: widget.monthlyAmount,
                      color: AppColors.primaryColor,
                      onChanged: (value) {
                        setState(() => _wants = value.roundToDouble());
                      },
                    ),
                    const SizedBox(height: 16),
                    _AutomatedRuleCard(
                      icon: TablerIcons.pig_money,
                      title: savingsBucket.localizedLabel(l10n),
                      value: _savings,
                      monthlyAmount: widget.monthlyAmount,
                      color: AppColors.primaryColor,
                      onChanged: (value) {
                        setState(() => _savings = value.roundToDouble());
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundAlt.withValues(alpha: 0.98),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.primaryColor.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 62,
                  child: ElevatedButton(
                    onPressed: _isValid ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor:
                          AppColors.textLight.withValues(alpha: 0.24),
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.saveRules,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _essentials = 50;
      _wants = 30;
      _savings = 20;
    });
  }

  void _save() {
    Navigator.pop(
      context,
      _DistributionRules(
        essentials: _essentials,
        wants: _wants,
        savings: _savings,
      ),
    );
  }
}

class _AutomatedRuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double monthlyAmount;
  final Color color;
  final ValueChanged<double> onChanged;

  const _AutomatedRuleCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.monthlyAmount,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final amount = monthlyAmount * value / 100;
    final formatted = NumberFormat('#,##0').format(amount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${value.round()}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.8,
                  ),
                ),
                TextSpan(
                  text: '%',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.monthlyAllocation('\$$formatted'),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryColor,
              inactiveTrackColor:
                  AppColors.backgroundColor.withValues(alpha: 0.5),
              thumbColor: AppColors.white,
              overlayColor: AppColors.primaryColor.withValues(alpha: 0.16),
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13),
            ),
            child: Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final VoidCallback onSave;

  const _ModalHeader({
    required this.title,
    required this.onClose,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: Icon(
              TablerIcons.x,
              color: AppColors.textSecondary,
              size: 26,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
              ),
            ),
          ),
          TextButton(
            onPressed: onSave,
            child: Text(
              l10n.save,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptField extends StatelessWidget {
  final TextEditingController controller;

  const _ConceptField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
      cursorColor: AppColors.primaryColor,
      decoration: InputDecoration(
        hintText: l10n.expenseHint,
        hintStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        prefixIcon: const Icon(
          TablerIcons.notes,
          color: AppColors.primaryColor,
          size: 22,
        ),
        filled: true,
        fillColor: AppColors.surfaceInput,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              TablerIcons.chevron_down,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountInputField extends StatefulWidget {
  const _AmountInputField({
    required this.controller,
    required this.isIncome,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isIncome;
  final VoidCallback onChanged;

  @override
  State<_AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<_AmountInputField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final allowDecimals = currency.usesDecimals;
    final color =
        widget.isIncome ? AppColors.textPrimary : AppColors.expenseColor;
    final fontSize = widget.isIncome ? 50.0 : 48.0;
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: widget.isIncome ? -1.8 : -2.2,
      height: 1,
    );
    const noBorder = InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: false,
      isCollapsed: true,
      contentPadding: EdgeInsets.zero,
    );

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${currency.selectedCurrency.symbol} ',
              style: textStyle,
            ),
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: widget.controller.text.isEmpty ? 28 : 48,
                  maxWidth: 240,
                ),
                child: TextField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: allowDecimals,
                  ),
                  inputFormatters: [
                    if (allowDecimals)
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      )
                    else
                      FilteringTextInputFormatter.digitsOnly,
                  ],
                  textAlign: TextAlign.left,
                  style: textStyle,
                  cursorColor: color,
                  decoration: noBorder.copyWith(
                    hintText: '0',
                    hintStyle: textStyle.copyWith(
                      color: color.withValues(alpha: 0.38),
                    ),
                  ),
                  onChanged: (_) => widget.onChanged(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  final SpeechAssistantState state;
  final String? resultSummary;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _VoiceButton({
    required this.state,
    required this.resultSummary,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isListening = state.status == SpeechAssistantStatus.recording;
    final transcript = state.transcript?.text ?? '';
    final statusText = switch (state.status) {
      SpeechAssistantStatus.recording => l10n.listening,
      SpeechAssistantStatus.stoppingRecording ||
      SpeechAssistantStatus.transcribing =>
        l10n.voiceTranscribing,
      SpeechAssistantStatus.generatingSpeech ||
      SpeechAssistantStatus.playingSpeech =>
        l10n.voicePlaying,
      SpeechAssistantStatus.failure ||
      SpeechAssistantStatus.unavailable =>
        state.errorMessage ?? l10n.voiceNotAvailable,
      _ => transcript.isEmpty ? l10n.tapToSpeak : resultSummary ?? transcript,
    };
    final canTap =
        !state.isBusy && state.status != SpeechAssistantStatus.playingSpeech;

    return Column(
      children: [
        GestureDetector(
          onTap: canTap ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 82,
            height: 82,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isListening
                    ? AppColors.expenseColor
                    : AppColors.primaryColor.withValues(alpha: 0.65),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isListening
                          ? AppColors.expenseColor
                          : AppColors.primaryColor)
                      .withValues(alpha: isListening ? 0.35 : 0.24),
                  blurRadius: isListening ? 34 : 28,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isListening
                    ? AppColors.expenseColor
                    : AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isListening
                    ? TablerIcons.microphone_off
                    : TablerIcons.microphone,
                color: AppColors.backgroundColor,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          width: 280,
          child: Text(
            statusText,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  isListening ? AppColors.expenseColor : AppColors.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        if (transcript.isNotEmpty) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: state.isBusy ? null : onPlay,
            icon: const Icon(TablerIcons.volume),
            label: Text(l10n.voiceListenConfirmation),
          ),
        ],
      ],
    );
  }
}

class _CategoryChoice extends StatelessWidget {
  final CategoryModel category;
  final bool selected;

  const _CategoryChoice({
    required this.category,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withValues(alpha: 0.16)
              : AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primaryColor : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              color: selected ? AppColors.primaryColor : category.color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                color:
                    selected ? AppColors.primaryColor : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
