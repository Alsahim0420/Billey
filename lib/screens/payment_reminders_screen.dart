import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_extensions.dart';
import '../models/payment_reminder.dart';
import '../providers/currency_provider.dart';
import '../providers/payment_reminder_provider.dart';
import '../theme/colors/app_colors.dart';

class PaymentRemindersScreen extends StatefulWidget {
  const PaymentRemindersScreen({super.key});

  @override
  State<PaymentRemindersScreen> createState() => _PaymentRemindersScreenState();
}

class _PaymentRemindersScreenState extends State<PaymentRemindersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PaymentReminderProvider>();
      if (!provider.isLoaded) await provider.initialize();
    });
  }

  String _notificationBody(PaymentReminder reminder) {
    final l10n = context.l10n;
    final currency = context.read<CurrencyProvider>();
    if (reminder.amount != null) {
      return l10n.paymentReminderBody(currency.format(reminder.amount!));
    }
    return l10n.paymentReminderBodySimple;
  }

  Future<void> _openReminderSheet({PaymentReminder? existing}) async {
    final provider = context.read<PaymentReminderProvider>();
    final granted = await provider.requestPermissions();
    if (!mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.notificationPermissionDenied)),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReminderFormSheet(
        existing: existing,
        onSave: (reminder) async {
          String bodyBuilder(_) => _notificationBody(reminder);
          if (existing == null) {
            await provider.addReminder(
              reminder,
              notificationBodyBuilder: bodyBuilder,
            );
          } else {
            await provider.updateReminder(
              reminder,
              notificationBodyBuilder: bodyBuilder,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        title: Text(l10n.paymentReminders),
        backgroundColor: AppColors.backgroundAlt,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openReminderSheet(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
        icon: const Icon(TablerIcons.bell_plus),
        label: Text(l10n.addPaymentReminder),
      ),
      body: Consumer<PaymentReminderProvider>(
        builder: (context, provider, _) {
          if (!provider.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = provider.reminders;
          if (reminders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      TablerIcons.bell_off,
                      size: 48,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.paymentRemindersEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: reminders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _ReminderCard(
                reminder: reminder,
                onEdit: () => _openReminderSheet(existing: reminder),
                onToggle: () => provider.toggleEnabled(
                  reminder.id,
                  notificationBodyBuilder: _notificationBody,
                ),
                onDelete: () => provider.deleteReminder(reminder.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final PaymentReminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.watch<CurrencyProvider>();
    final time =
        TimeOfDay(hour: reminder.hour, minute: reminder.minute).format(context);

    final scheduleText = reminder.repeatMonthly
        ? l10n.paymentReminderScheduleMonthly(reminder.dayOfMonth, time)
        : l10n.paymentReminderScheduleOnce(
            DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                .format(reminder.oneTimeDate ?? DateTime.now()),
            time,
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              TablerIcons.receipt,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (reminder.amount != null)
                  Text(
                    currency.format(reminder.amount!),
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                Text(
                  scheduleText,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: reminder.enabled,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.primaryColor,
            onChanged: (_) => onToggle(),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(TablerIcons.pencil, color: AppColors.textSecondary),
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.deletePaymentReminderTitle),
                  content:
                      Text(l10n.deletePaymentReminderMessage(reminder.title)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        l10n.delete,
                        style: const TextStyle(color: AppColors.expenseColor),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) onDelete();
            },
            icon: const Icon(TablerIcons.trash, color: AppColors.expenseColor),
          ),
        ],
      ),
    );
  }
}

class _ReminderFormSheet extends StatefulWidget {
  const _ReminderFormSheet({
    this.existing,
    required this.onSave,
  });

  final PaymentReminder? existing;
  final Future<void> Function(PaymentReminder reminder) onSave;

  @override
  State<_ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<_ReminderFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late bool _repeatMonthly;
  late bool _enabled;
  late int _dayOfMonth;
  late DateTime _oneTimeDate;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final provider = context.read<PaymentReminderProvider>();
    final currency = context.read<CurrencyProvider>();
    final draft = provider.createDraft(existing: existing);

    _titleController = TextEditingController(text: draft.title);
    _amountController = TextEditingController(
      text: draft.amount != null && draft.amount! > 0
          ? currency.formatValue(draft.amount!)
          : '',
    );
    _repeatMonthly = draft.repeatMonthly;
    _enabled = draft.enabled;
    _dayOfMonth = draft.dayOfMonth;
    _oneTimeDate = draft.oneTimeDate ?? DateTime.now();
    _time = TimeOfDay(hour: draft.hour, minute: draft.minute);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _oneTimeDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _oneTimeDate = picked);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    if (title.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paymentReminderNameRequired)),
      );
      return;
    }

    final amount =
        context.read<CurrencyProvider>().parseValue(_amountController.text);
    final existing = widget.existing;
    final provider = context.read<PaymentReminderProvider>();
    final id = existing?.id ?? provider.createDraft().id;

    final reminder = PaymentReminder(
      id: id,
      title: title,
      amount: amount,
      dayOfMonth: _dayOfMonth,
      oneTimeDate: _repeatMonthly ? null : _oneTimeDate,
      hour: _time.hour,
      minute: _time.minute,
      repeatMonthly: _repeatMonthly,
      enabled: _enabled,
    );

    await widget.onSave(reminder);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final existing = widget.existing;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  existing == null
                      ? l10n.addPaymentReminder
                      : l10n.editPaymentReminder,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.paymentReminderName,
                    hintText: l10n.paymentReminderNameHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters:
                      context.watch<CurrencyProvider>().usesDecimals
                          ? null
                          : [context.read<CurrencyProvider>().inputFormatter],
                  decoration: InputDecoration(
                    labelText: l10n.paymentReminderAmount,
                    hintText: l10n.paymentReminderAmountHint,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.paymentReminderTime,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(_time.format(context)),
                  trailing: const Icon(TablerIcons.clock,
                      color: AppColors.primaryColor),
                  onTap: _pickTime,
                ),
                if (_repeatMonthly) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.paymentReminderDayOfMonth,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _dayOfMonth,
                    decoration: const InputDecoration(),
                    items: List.generate(31, (index) {
                      final day = index + 1;
                      return DropdownMenuItem(
                        value: day,
                        child: Text(l10n.paymentReminderDayOption(day)),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) setState(() => _dayOfMonth = value);
                    },
                  ),
                ] else ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.paymentReminderDate,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      DateFormat.yMMMd(
                              Localizations.localeOf(context).languageCode)
                          .format(_oneTimeDate),
                    ),
                    trailing: const Icon(TablerIcons.calendar,
                        color: AppColors.primaryColor),
                    onTap: _pickDate,
                  ),
                ],
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.paymentReminderRepeatMonthly,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    l10n.paymentReminderRepeatMonthlyHint,
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  value: _repeatMonthly,
                  activeThumbColor: AppColors.white,
                  activeTrackColor: AppColors.primaryColor,
                  onChanged: (value) => setState(() => _repeatMonthly = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.paymentReminderEnabled,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _enabled,
                  activeThumbColor: AppColors.white,
                  activeTrackColor: AppColors.primaryColor,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(existing == null ? l10n.add : l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
