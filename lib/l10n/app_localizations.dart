import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Billey'**
  String get appTitle;

  /// No description provided for @financialManager.
  ///
  /// In en, this message translates to:
  /// **'Financial Manager'**
  String get financialManager;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @addIncomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit funds and distribute income'**
  String get addIncomeSubtitle;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @addExpenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record a purchase or payment'**
  String get addExpenseSubtitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your money smartly'**
  String get splashSubtitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @introSmartTracking.
  ///
  /// In en, this message translates to:
  /// **'Smart tracking'**
  String get introSmartTracking;

  /// No description provided for @introAutomatedInsights.
  ///
  /// In en, this message translates to:
  /// **'Automated insights'**
  String get introAutomatedInsights;

  /// No description provided for @introGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get introGetStarted;

  /// No description provided for @introTakeControl.
  ///
  /// In en, this message translates to:
  /// **'Take Control of'**
  String get introTakeControl;

  /// No description provided for @introYourWealth.
  ///
  /// In en, this message translates to:
  /// **'Your Wealth'**
  String get introYourWealth;

  /// No description provided for @setupPagePersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get setupPagePersonalData;

  /// No description provided for @setupPageGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get setupPageGoals;

  /// No description provided for @setupPageDistribution.
  ///
  /// In en, this message translates to:
  /// **'Income distribution'**
  String get setupPageDistribution;

  /// No description provided for @setupSubtitlePersonalData.
  ///
  /// In en, this message translates to:
  /// **'What we call you and your email'**
  String get setupSubtitlePersonalData;

  /// No description provided for @setupSubtitleGoals.
  ///
  /// In en, this message translates to:
  /// **'Choose how to start with your goals'**
  String get setupSubtitleGoals;

  /// No description provided for @setupSubtitleDistribution.
  ///
  /// In en, this message translates to:
  /// **'How to split what you earn'**
  String get setupSubtitleDistribution;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @finishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get fullNameHint;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters'**
  String get nameMinLength;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'For notifications and exporting data'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @setupGoalsHelp.
  ///
  /// In en, this message translates to:
  /// **'Goals are savings targets in your currency (Colombian pesos by default). You can leave them empty, use suggested ones, or create your own now.'**
  String get setupGoalsHelp;

  /// No description provided for @goalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get goalsEmpty;

  /// No description provided for @goalsSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get goalsSuggested;

  /// No description provided for @goalsCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get goalsCustom;

  /// No description provided for @setupGoalsEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'You\'ll start with no goals. You can create them later from the Goals tab.'**
  String get setupGoalsEmptyHelp;

  /// No description provided for @setupSuggestedHeader.
  ///
  /// In en, this message translates to:
  /// **'These goals will be created for you:'**
  String get setupSuggestedHeader;

  /// No description provided for @goalEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency fund'**
  String get goalEmergencyTitle;

  /// No description provided for @goalEmergencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get goalEmergencySubtitle;

  /// No description provided for @goalTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get goalTripTitle;

  /// No description provided for @goalTripSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal goal'**
  String get goalTripSubtitle;

  /// No description provided for @setupCustomEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have goals yet. Tap the button below to create the first one.'**
  String get setupCustomEmpty;

  /// No description provided for @addCustomGoal.
  ///
  /// In en, this message translates to:
  /// **'Add custom goal'**
  String get addCustomGoal;

  /// No description provided for @setupDistributionHelp.
  ///
  /// In en, this message translates to:
  /// **'The template defines how to split your income (needs, wants, savings). Pick a template or customize your percentages.'**
  String get setupDistributionHelp;

  /// No description provided for @chooseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose a template'**
  String get chooseTemplate;

  /// No description provided for @customTemplate.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customTemplate;

  /// No description provided for @setupPercentTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: they don\'t have to add up to 100 exactly; the app normalizes them.'**
  String get setupPercentTip;

  /// No description provided for @needs.
  ///
  /// In en, this message translates to:
  /// **'Needs'**
  String get needs;

  /// No description provided for @wants.
  ///
  /// In en, this message translates to:
  /// **'Wants'**
  String get wants;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @addGoalOrChooseOption.
  ///
  /// In en, this message translates to:
  /// **'Add at least one goal or choose another option'**
  String get addGoalOrChooseOption;

  /// No description provided for @reviewNameEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your name and email and try again'**
  String get reviewNameEmail;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get newGoal;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get editGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get goalName;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Emergency fund'**
  String get goalNameHint;

  /// No description provided for @goalCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get goalCategory;

  /// No description provided for @goalCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Safety'**
  String get goalCategoryHint;

  /// No description provided for @goalTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalTargetAmount;

  /// No description provided for @goalSavedAmount.
  ///
  /// In en, this message translates to:
  /// **'Saved amount'**
  String get goalSavedAmount;

  /// No description provided for @monthsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Months remaining'**
  String get monthsRemaining;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @validGoalName.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid name'**
  String get validGoalName;

  /// No description provided for @goalTargetPositive.
  ///
  /// In en, this message translates to:
  /// **'Target must be greater than 0'**
  String get goalTargetPositive;

  /// No description provided for @goalPersonalDefault.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get goalPersonalDefault;

  /// No description provided for @goalPreviewMeta.
  ///
  /// In en, this message translates to:
  /// **'{subtitle} · Target {amount}'**
  String goalPreviewMeta(String subtitle, String amount);

  /// No description provided for @goalPreviewWithMonths.
  ///
  /// In en, this message translates to:
  /// **'{subtitle} · Target {amount} · {months} months'**
  String goalPreviewWithMonths(String subtitle, String amount, int months);

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetLabel;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @recentMonths.
  ///
  /// In en, this message translates to:
  /// **'Recent months'**
  String get recentMonths;

  /// No description provided for @homeChartTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get homeChartTrend;

  /// No description provided for @homeChartByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get homeChartByCategory;

  /// No description provided for @noExpensesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get noExpensesInPeriod;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String todayAt(String time);

  /// No description provided for @yesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String yesterdayAt(String time);

  /// No description provided for @financialFreedom.
  ///
  /// In en, this message translates to:
  /// **'FINANCIAL FREEDOM'**
  String get financialFreedom;

  /// No description provided for @yourGoals.
  ///
  /// In en, this message translates to:
  /// **'Your Goals'**
  String get yourGoals;

  /// No description provided for @totalSavings.
  ///
  /// In en, this message translates to:
  /// **'Total Savings'**
  String get totalSavings;

  /// No description provided for @newGoalSheet.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoalSheet;

  /// No description provided for @editGoalSheet.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoalSheet;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get goalTitle;

  /// No description provided for @goalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get goalTitleHint;

  /// No description provided for @goalCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get goalCategoryLabel;

  /// No description provided for @goalCategorySheetHint.
  ///
  /// In en, this message translates to:
  /// **'Safety Net'**
  String get goalCategorySheetHint;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @monthsLeft.
  ///
  /// In en, this message translates to:
  /// **'Months left'**
  String get monthsLeft;

  /// No description provided for @goalDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalDefaultSubtitle;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @saveGoal.
  ///
  /// In en, this message translates to:
  /// **'Save Goal'**
  String get saveGoal;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// No description provided for @monthsLeftBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} mos left'**
  String monthsLeftBadge(int count);

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search merchant or category...'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// No description provided for @filterExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get filterExpenses;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get dateYesterday;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove \"{title}\" permanently.'**
  String deleteTransactionMessage(String title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @addIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncomeTitle;

  /// No description provided for @editIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get editIncomeTitle;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @sourceHint.
  ///
  /// In en, this message translates to:
  /// **'Client Payment'**
  String get sourceHint;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @todayDate.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String todayDate(String date);

  /// No description provided for @autoDistributeIncome.
  ///
  /// In en, this message translates to:
  /// **'Auto-distribute Income'**
  String get autoDistributeIncome;

  /// No description provided for @usingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Using {name}'**
  String usingTemplate(String name);

  /// No description provided for @distributionPaused.
  ///
  /// In en, this message translates to:
  /// **'Distribution paused'**
  String get distributionPaused;

  /// No description provided for @percentAllocation.
  ///
  /// In en, this message translates to:
  /// **'{percent}% allocation'**
  String percentAllocation(String percent);

  /// No description provided for @editDistributionRules.
  ///
  /// In en, this message translates to:
  /// **'Edit Distribution Rules'**
  String get editDistributionRules;

  /// No description provided for @depositFunds.
  ///
  /// In en, this message translates to:
  /// **'Deposit Funds'**
  String get depositFunds;

  /// No description provided for @automatedRules.
  ///
  /// In en, this message translates to:
  /// **'Automated Rules'**
  String get automatedRules;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @totalAllocation.
  ///
  /// In en, this message translates to:
  /// **'TOTAL ALLOCATION'**
  String get totalAllocation;

  /// No description provided for @saveRules.
  ///
  /// In en, this message translates to:
  /// **'Save Rules'**
  String get saveRules;

  /// No description provided for @monthlyAllocation.
  ///
  /// In en, this message translates to:
  /// **'{amount} monthly'**
  String monthlyAllocation(String amount);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get chooseCategory;

  /// No description provided for @expenseHint.
  ///
  /// In en, this message translates to:
  /// **'Dinner at Nobu'**
  String get expenseHint;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'TAP TO SPEAK'**
  String get tapToSpeak;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'LISTENING... I\'LL STOP WHEN YOU FINISH SPEAKING'**
  String get listening;

  /// No description provided for @voiceTranscribing.
  ///
  /// In en, this message translates to:
  /// **'TRANSCRIBING...'**
  String get voiceTranscribing;

  /// No description provided for @voicePlaying.
  ///
  /// In en, this message translates to:
  /// **'PLAYING...'**
  String get voicePlaying;

  /// No description provided for @voiceListenConfirmation.
  ///
  /// In en, this message translates to:
  /// **'LISTEN TO CONFIRMATION'**
  String get voiceListenConfirmation;

  /// No description provided for @voiceConfirmationPrefix.
  ///
  /// In en, this message translates to:
  /// **'I understood:'**
  String get voiceConfirmationPrefix;

  /// No description provided for @confirmExpense.
  ///
  /// In en, this message translates to:
  /// **'Confirm Expense'**
  String get confirmExpense;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// No description provided for @confirmIncome.
  ///
  /// In en, this message translates to:
  /// **'Confirm Income'**
  String get confirmIncome;

  /// No description provided for @updateIncome.
  ///
  /// In en, this message translates to:
  /// **'Confirm Income'**
  String get updateIncome;

  /// No description provided for @conceptMinLength.
  ///
  /// In en, this message translates to:
  /// **'Enter a description of at least 3 characters'**
  String get conceptMinLength;

  /// No description provided for @amountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get amountMustBePositive;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @transactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully'**
  String get transactionAdded;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdated;

  /// No description provided for @voiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Voice not available. Stop the app, run \"flutter pub get\", then \"cd ios && pod install\" and reopen with flutter run (don\'t use hot reload).'**
  String get voiceNotAvailable;

  /// No description provided for @micPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enable microphone permission to record expenses by voice.'**
  String get micPermissionRequired;

  /// No description provided for @voiceAmountNotUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t understand the amount. Try: \"Spent 50000 on food\" or \"Paid 25 thousand for taxi\".'**
  String get voiceAmountNotUnderstood;

  /// No description provided for @voiceAmountDetected.
  ///
  /// In en, this message translates to:
  /// **'Amount detected. Adjust the description or speak again with more detail.'**
  String get voiceAmountDetected;

  /// No description provided for @autoDistributionNote.
  ///
  /// In en, this message translates to:
  /// **'Auto-distribution: Needs {essentials}%, Wants {wants}%, Savings {savings}%'**
  String autoDistributionNote(String essentials, String wants, String savings);

  /// No description provided for @autoDistribution.
  ///
  /// In en, this message translates to:
  /// **'Auto-distribution'**
  String get autoDistribution;

  /// No description provided for @templatesSection.
  ///
  /// In en, this message translates to:
  /// **'TEMPLATES'**
  String get templatesSection;

  /// No description provided for @customRuleSection.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM RULE'**
  String get customRuleSection;

  /// No description provided for @customTemplateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust percentages to your reality'**
  String get customTemplateSubtitle;

  /// No description provided for @disabledForNewDeposits.
  ///
  /// In en, this message translates to:
  /// **'Disabled for new deposits'**
  String get disabledForNewDeposits;

  /// No description provided for @totalAllocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Total allocation'**
  String get totalAllocationLabel;

  /// No description provided for @saveCustomRule.
  ///
  /// In en, this message translates to:
  /// **'Save Custom Rule'**
  String get saveCustomRule;

  /// No description provided for @customRuleSaved.
  ///
  /// In en, this message translates to:
  /// **'Custom rule saved'**
  String get customRuleSaved;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get generalSection;

  /// No description provided for @dataPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'DATA & PRIVACY'**
  String get dataPrivacySection;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @currencySetting.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencySetting;

  /// No description provided for @budgetLimits.
  ///
  /// In en, this message translates to:
  /// **'Budget Limits'**
  String get budgetLimits;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get dataExport;

  /// No description provided for @csvPdf.
  ///
  /// In en, this message translates to:
  /// **'CSV/PDF'**
  String get csvPdf;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 (Build 1)'**
  String get versionInfo;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @currencyItem.
  ///
  /// In en, this message translates to:
  /// **'{name} ({code})'**
  String currencyItem(String name, String code);

  /// No description provided for @csvHeaders.
  ///
  /// In en, this message translates to:
  /// **'Date, Type, Category, Concept, Amount, Description'**
  String get csvHeaders;

  /// No description provided for @exportShareText.
  ///
  /// In en, this message translates to:
  /// **'My Billey transactions'**
  String get exportShareText;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export data. Please try again.'**
  String get exportFailed;

  /// No description provided for @exportDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportDataTitle;

  /// No description provided for @exportFormatSection.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get exportFormatSection;

  /// No description provided for @exportFormatCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get exportFormatCsv;

  /// No description provided for @exportFormatPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get exportFormatPdf;

  /// No description provided for @exportContentSection.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get exportContentSection;

  /// No description provided for @exportContentAll.
  ///
  /// In en, this message translates to:
  /// **'All (income and expenses)'**
  String get exportContentAll;

  /// No description provided for @exportContentExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses only'**
  String get exportContentExpenses;

  /// No description provided for @exportContentIncome.
  ///
  /// In en, this message translates to:
  /// **'Income only'**
  String get exportContentIncome;

  /// No description provided for @exportButton.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportButton;

  /// No description provided for @exportNoData.
  ///
  /// In en, this message translates to:
  /// **'No transactions match this selection.'**
  String get exportNoData;

  /// No description provided for @exportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Billey transactions'**
  String get exportPdfTitle;

  /// No description provided for @exportPdfGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String exportPdfGenerated(String date);

  /// No description provided for @exportPdfSummaryIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get exportPdfSummaryIncome;

  /// No description provided for @exportPdfSummaryExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get exportPdfSummaryExpenses;

  /// No description provided for @exportPdfSummaryCount.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get exportPdfSummaryCount;

  /// No description provided for @transactionTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionTypeIncome;

  /// No description provided for @transactionTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionTypeExpense;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @photoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get photoUpdated;

  /// No description provided for @photoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile photo removed'**
  String get photoRemoved;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @dataStoredLocally.
  ///
  /// In en, this message translates to:
  /// **'Data is stored only on this device.'**
  String get dataStoredLocally;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @emailHintShort.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get emailHintShort;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @checkNameEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your name and email'**
  String get checkNameEmail;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeProfile;

  /// No description provided for @addYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Add your email'**
  String get addYourEmail;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} will be available soon'**
  String featureComingSoon(String feature);

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Your local session will remain secure on this device.'**
  String get logOutMessage;

  /// No description provided for @spendingInsights.
  ///
  /// In en, this message translates to:
  /// **'Spending Insights'**
  String get spendingInsights;

  /// No description provided for @monthlyComparison.
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get monthlyComparison;

  /// No description provided for @viewReport.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get viewReport;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategories;

  /// No description provided for @totalSpend.
  ///
  /// In en, this message translates to:
  /// **'Total Spend'**
  String get totalSpend;

  /// No description provided for @insight.
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get insight;

  /// No description provided for @youSpent.
  ///
  /// In en, this message translates to:
  /// **'You spent'**
  String get youSpent;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// No description provided for @insightBudgetTight.
  ///
  /// In en, this message translates to:
  /// **'this month. Nice work keeping the budget tight.'**
  String get insightBudgetTight;

  /// No description provided for @monthlySpending.
  ///
  /// In en, this message translates to:
  /// **'Monthly spending'**
  String get monthlySpending;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// No description provided for @deactivatedCategories.
  ///
  /// In en, this message translates to:
  /// **'Deactivated Categories'**
  String get deactivatedCategories;

  /// No description provided for @defaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultBadge;

  /// No description provided for @deactivatedBadge.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get deactivatedBadge;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the category \"{name}\"?'**
  String deleteCategoryMessage(String name);

  /// No description provided for @deleteDefaultCategoryWarning.
  ///
  /// In en, this message translates to:
  /// **'This is a default category. It can be deleted but may affect functionality.'**
  String get deleteDefaultCategoryWarning;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @categoryActivated.
  ///
  /// In en, this message translates to:
  /// **'Category \"{name}\" activated'**
  String categoryActivated(String name);

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category \"{name}\" deleted'**
  String categoryDeleted(String name);

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @saveUpper.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveUpper;

  /// No description provided for @createUpper.
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get createUpper;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @categoryNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNamePlaceholder;

  /// No description provided for @customSectionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Custom section'**
  String get customSectionPlaceholder;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Gym, Pets, etc.'**
  String get categoryNameHint;

  /// No description provided for @categoryAutoSuggested.
  ///
  /// In en, this message translates to:
  /// **'Icon and color suggested from the name'**
  String get categoryAutoSuggested;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get enterCategoryName;

  /// No description provided for @categoryNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get categoryNameMinLength;

  /// No description provided for @categoryNameExists.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists'**
  String get categoryNameExists;

  /// No description provided for @section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// No description provided for @predefined.
  ///
  /// In en, this message translates to:
  /// **'Predefined'**
  String get predefined;

  /// No description provided for @customSection.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customSection;

  /// No description provided for @sectionNameHint.
  ///
  /// In en, this message translates to:
  /// **'Section name'**
  String get sectionNameHint;

  /// No description provided for @sectionNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Section name is required'**
  String get sectionNameRequired;

  /// No description provided for @selectSection.
  ///
  /// In en, this message translates to:
  /// **'Select section'**
  String get selectSection;

  /// No description provided for @sectionColor.
  ///
  /// In en, this message translates to:
  /// **'Section color'**
  String get sectionColor;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select an Icon'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select a Color'**
  String get selectColor;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdated;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created successfully'**
  String get categoryCreated;

  /// No description provided for @monthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary'**
  String get monthlySummary;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @incomeVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expenses'**
  String get incomeVsExpenses;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get noExpensesThisMonth;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @categoryDetail.
  ///
  /// In en, this message translates to:
  /// **'Category Detail'**
  String get categoryDetail;

  /// No description provided for @summaryFor.
  ///
  /// In en, this message translates to:
  /// **'Summary for {month}'**
  String summaryFor(String month);

  /// No description provided for @totalIncomeLine.
  ///
  /// In en, this message translates to:
  /// **'Total Income: {amount}'**
  String totalIncomeLine(String amount);

  /// No description provided for @totalExpenseLine.
  ///
  /// In en, this message translates to:
  /// **'Total Expense: {amount}'**
  String totalExpenseLine(String amount);

  /// No description provided for @balanceLine.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount}'**
  String balanceLine(String amount);

  /// No description provided for @firstTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first transaction awaits!'**
  String get firstTransactionTitle;

  /// No description provided for @firstTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Start recording your income and expenses to take full control of your money.'**
  String get firstTransactionMessage;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @deleteTransactionCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get deleteTransactionCardTitle;

  /// No description provided for @deleteTransactionCardMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" for {amount} will be removed.\n\nThis action cannot be undone.'**
  String deleteTransactionCardMessage(String title, String amount);

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeleted;

  /// No description provided for @defaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @currencyCop.
  ///
  /// In en, this message translates to:
  /// **'Colombian peso'**
  String get currencyCop;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US dollar'**
  String get currencyUsd;

  /// No description provided for @currencyEur.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEur;

  /// No description provided for @currencyMxn.
  ///
  /// In en, this message translates to:
  /// **'Mexican peso'**
  String get currencyMxn;

  /// No description provided for @currencyBrl.
  ///
  /// In en, this message translates to:
  /// **'Brazilian real'**
  String get currencyBrl;

  /// No description provided for @goalStyleEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get goalStyleEmergency;

  /// No description provided for @goalStyleTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get goalStyleTrip;

  /// No description provided for @goalStyleCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get goalStyleCar;

  /// No description provided for @goalStyleHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get goalStyleHome;

  /// No description provided for @goalStyleEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get goalStyleEducation;

  /// No description provided for @goalStyleHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get goalStyleHealth;

  /// No description provided for @goalStyleTech.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get goalStyleTech;

  /// No description provided for @goalStyleWedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get goalStyleWedding;

  /// No description provided for @goalStyleBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get goalStyleBusiness;

  /// No description provided for @goalStyleGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get goalStyleGift;

  /// No description provided for @bucketEssentials.
  ///
  /// In en, this message translates to:
  /// **'Essentials'**
  String get bucketEssentials;

  /// No description provided for @bucketWants.
  ///
  /// In en, this message translates to:
  /// **'Wants'**
  String get bucketWants;

  /// No description provided for @bucketSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get bucketSavings;

  /// No description provided for @bucketDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get bucketDebts;

  /// No description provided for @bucketInvesting.
  ///
  /// In en, this message translates to:
  /// **'Investing'**
  String get bucketInvesting;

  /// No description provided for @bucketBuffer.
  ///
  /// In en, this message translates to:
  /// **'Buffer'**
  String get bucketBuffer;

  /// No description provided for @templateBalancedName.
  ///
  /// In en, this message translates to:
  /// **'50/30/20 Balanced'**
  String get templateBalancedName;

  /// No description provided for @templateBalancedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Needs, wants and savings'**
  String get templateBalancedSubtitle;

  /// No description provided for @templateDebtFirstName.
  ///
  /// In en, this message translates to:
  /// **'Debt first'**
  String get templateDebtFirstName;

  /// No description provided for @templateDebtFirstSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds a dedicated envelope for debt'**
  String get templateDebtFirstSubtitle;

  /// No description provided for @templateInvestorName.
  ///
  /// In en, this message translates to:
  /// **'Investor mode'**
  String get templateInvestorName;

  /// No description provided for @templateInvestorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Savings separate from investing'**
  String get templateInvestorSubtitle;

  /// No description provided for @templateVariableName.
  ///
  /// In en, this message translates to:
  /// **'Variable income'**
  String get templateVariableName;

  /// No description provided for @templateVariableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes buffer for slow months'**
  String get templateVariableSubtitle;

  /// No description provided for @templateCustomName.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get templateCustomName;

  /// No description provided for @templateCustomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your own distribution rule'**
  String get templateCustomSubtitle;

  /// No description provided for @txnCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get txnCategoryFood;

  /// No description provided for @txnCategoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get txnCategoryTransport;

  /// No description provided for @txnCategoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get txnCategoryEntertainment;

  /// No description provided for @txnCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get txnCategoryHealth;

  /// No description provided for @txnCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get txnCategoryEducation;

  /// No description provided for @txnCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get txnCategoryOther;

  /// No description provided for @insightDemoHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get insightDemoHousing;

  /// No description provided for @insightDemoHousingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rent & Utilities'**
  String get insightDemoHousingSubtitle;

  /// No description provided for @insightDemoFoodDining.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get insightDemoFoodDining;

  /// No description provided for @insightDemoFoodDiningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Groceries, Restaurants'**
  String get insightDemoFoodDiningSubtitle;

  /// No description provided for @insightDemoFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get insightDemoFun;

  /// No description provided for @insightDemoFunSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get insightDemoFunSubtitle;

  /// No description provided for @insightDemoTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get insightDemoTransport;

  /// No description provided for @insightDemoTransportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get insightDemoTransportSubtitle;

  /// No description provided for @paymentReminders.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders'**
  String get paymentReminders;

  /// No description provided for @addPaymentReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addPaymentReminder;

  /// No description provided for @editPaymentReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editPaymentReminder;

  /// No description provided for @paymentRemindersEmpty.
  ///
  /// In en, this message translates to:
  /// **'Create reminders for your bills and payments. You can set them to repeat every month.'**
  String get paymentRemindersEmpty;

  /// No description provided for @paymentReminderName.
  ///
  /// In en, this message translates to:
  /// **'Payment name'**
  String get paymentReminderName;

  /// No description provided for @paymentReminderNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Rent, Netflix, Credit card'**
  String get paymentReminderNameHint;

  /// No description provided for @paymentReminderNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name with at least 2 characters'**
  String get paymentReminderNameRequired;

  /// No description provided for @paymentReminderAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (optional)'**
  String get paymentReminderAmount;

  /// No description provided for @paymentReminderAmountHint.
  ///
  /// In en, this message translates to:
  /// **'500000'**
  String get paymentReminderAmountHint;

  /// No description provided for @paymentReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get paymentReminderTime;

  /// No description provided for @paymentReminderDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of the month'**
  String get paymentReminderDayOfMonth;

  /// No description provided for @paymentReminderDayOption.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String paymentReminderDayOption(int day);

  /// No description provided for @paymentReminderDate.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get paymentReminderDate;

  /// No description provided for @paymentReminderRepeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Repeat monthly'**
  String get paymentReminderRepeatMonthly;

  /// No description provided for @paymentReminderRepeatMonthlyHint.
  ///
  /// In en, this message translates to:
  /// **'Get notified on the same day every month'**
  String get paymentReminderRepeatMonthlyHint;

  /// No description provided for @paymentReminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Reminder enabled'**
  String get paymentReminderEnabled;

  /// No description provided for @paymentReminderScheduleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Day {day} at {time} · Monthly'**
  String paymentReminderScheduleMonthly(int day, String time);

  /// No description provided for @paymentReminderScheduleOnce.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time} · One time'**
  String paymentReminderScheduleOnce(String date, String time);

  /// No description provided for @paymentReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Payment due: {amount}'**
  String paymentReminderBody(String amount);

  /// No description provided for @paymentReminderBodySimple.
  ///
  /// In en, this message translates to:
  /// **'Payment reminder'**
  String get paymentReminderBodySimple;

  /// No description provided for @deletePaymentReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder?'**
  String get deletePaymentReminderTitle;

  /// No description provided for @deletePaymentReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deletePaymentReminderMessage(String title);

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in settings to receive payment reminders'**
  String get notificationPermissionDenied;

  /// No description provided for @coupleFinanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared finances'**
  String get coupleFinanceTitle;

  /// No description provided for @couplePairingIntro.
  ///
  /// In en, this message translates to:
  /// **'Link your phone with family or friends by scanning a QR code. Then share transfers and track spending by syncing with QR.'**
  String get couplePairingIntro;

  /// No description provided for @couplePartnerName.
  ///
  /// In en, this message translates to:
  /// **'Name of person you share with'**
  String get couplePartnerName;

  /// No description provided for @couplePartnerNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Maria, dad, sibling'**
  String get couplePartnerNameHint;

  /// No description provided for @couplePartnerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get couplePartnerNameRequired;

  /// No description provided for @coupleShowPairingQr.
  ///
  /// In en, this message translates to:
  /// **'Show pairing QR'**
  String get coupleShowPairingQr;

  /// No description provided for @coupleScanPairingQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get coupleScanPairingQr;

  /// No description provided for @couplePairingQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get couplePairingQrTitle;

  /// No description provided for @couplePairingQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask {name} to scan this code'**
  String couplePairingQrSubtitle(String name);

  /// No description provided for @coupleQrHint.
  ///
  /// In en, this message translates to:
  /// **'Keep this code visible until it is scanned from Billey.'**
  String get coupleQrHint;

  /// No description provided for @coupleScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get coupleScanQr;

  /// No description provided for @coupleScanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the Billey QR code.'**
  String get coupleScanHint;

  /// No description provided for @coupleScanFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Scanning with Billey\'s camera'**
  String get coupleScanFromCamera;

  /// No description provided for @coupleScanFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get coupleScanFromGallery;

  /// No description provided for @coupleQrNotFound.
  ///
  /// In en, this message translates to:
  /// **'No Billey QR detected. Try again with better lighting.'**
  String get coupleQrNotFound;

  /// No description provided for @couplePasteHint.
  ///
  /// In en, this message translates to:
  /// **'If the camera does not work, paste here the code shown under the QR.'**
  String get couplePasteHint;

  /// No description provided for @couplePasteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use code'**
  String get couplePasteConfirm;

  /// No description provided for @coupleLinkedWith.
  ///
  /// In en, this message translates to:
  /// **'Sharing with {name}'**
  String coupleLinkedWith(String name);

  /// No description provided for @coupleSyncReminder.
  ///
  /// In en, this message translates to:
  /// **'After each expense, share an update via QR so both of you see the movements.'**
  String get coupleSyncReminder;

  /// No description provided for @coupleShareUpdate.
  ///
  /// In en, this message translates to:
  /// **'Share QR'**
  String get coupleShareUpdate;

  /// No description provided for @coupleScanUpdate.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get coupleScanUpdate;

  /// No description provided for @coupleSharedWallets.
  ///
  /// In en, this message translates to:
  /// **'Shared transfers'**
  String get coupleSharedWallets;

  /// No description provided for @coupleWalletsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Create a transfer (e.g. 2M) and share the QR so they receive it on their phone.'**
  String get coupleWalletsEmpty;

  /// No description provided for @coupleNewTransfer.
  ///
  /// In en, this message translates to:
  /// **'New transfer'**
  String get coupleNewTransfer;

  /// No description provided for @coupleTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get coupleTransferTitle;

  /// No description provided for @coupleTransferTitleHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. March budget'**
  String get coupleTransferTitleHint;

  /// No description provided for @coupleTransferAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get coupleTransferAmount;

  /// No description provided for @coupleHolderIsPartner.
  ///
  /// In en, this message translates to:
  /// **'Used by {name}'**
  String coupleHolderIsPartner(String name);

  /// No description provided for @coupleWalletCreated.
  ///
  /// In en, this message translates to:
  /// **'Transfer created. Show the QR to share it.'**
  String get coupleWalletCreated;

  /// No description provided for @coupleSyncQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get coupleSyncQrTitle;

  /// No description provided for @coupleSyncQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to update \"{title}\"'**
  String coupleSyncQrSubtitle(String title);

  /// No description provided for @coupleSyncQrSubtitleAll.
  ///
  /// In en, this message translates to:
  /// **'Scan to update all transfers and expenses'**
  String get coupleSyncQrSubtitleAll;

  /// No description provided for @coupleSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully'**
  String get coupleSyncSuccess;

  /// No description provided for @coupleSyncInvalid.
  ///
  /// In en, this message translates to:
  /// **'Could not read the QR. Make sure it\'s from Billey.'**
  String get coupleSyncInvalid;

  /// No description provided for @coupleLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully linked!'**
  String get coupleLinkedSuccess;

  /// No description provided for @coupleUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get coupleUnlink;

  /// No description provided for @coupleUnlinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink shared finances?'**
  String get coupleUnlinkTitle;

  /// No description provided for @coupleUnlinkMessage.
  ///
  /// In en, this message translates to:
  /// **'Shared transfers on this device will be deleted. The other person keeps their local copy.'**
  String get coupleUnlinkMessage;

  /// No description provided for @coupleUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Unlinked successfully'**
  String get coupleUnlinked;

  /// No description provided for @coupleSharedWallet.
  ///
  /// In en, this message translates to:
  /// **'Shared transfer'**
  String get coupleSharedWallet;

  /// No description provided for @coupleWalletNotFound.
  ///
  /// In en, this message translates to:
  /// **'Transfer not found'**
  String get coupleWalletNotFound;

  /// No description provided for @coupleAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get coupleAddExpense;

  /// No description provided for @coupleExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense description'**
  String get coupleExpenseTitle;

  /// No description provided for @coupleExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get coupleExpenseAmount;

  /// No description provided for @coupleBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get coupleBudget;

  /// No description provided for @coupleSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get coupleSpent;

  /// No description provided for @coupleRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get coupleRemaining;

  /// No description provided for @coupleFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get coupleFrom;

  /// No description provided for @coupleFor.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get coupleFor;

  /// No description provided for @coupleExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get coupleExpenses;

  /// No description provided for @coupleNoExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this transfer yet'**
  String get coupleNoExpensesYet;

  /// No description provided for @assistantVoice.
  ///
  /// In en, this message translates to:
  /// **'Assistant voice'**
  String get assistantVoice;

  /// No description provided for @assistantVoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the voice for spoken confirmations'**
  String get assistantVoiceDescription;

  /// No description provided for @assistantFemaleVoice.
  ///
  /// In en, this message translates to:
  /// **'Warm female'**
  String get assistantFemaleVoice;

  /// No description provided for @assistantMaleVoice.
  ///
  /// In en, this message translates to:
  /// **'Warm male'**
  String get assistantMaleVoice;

  /// No description provided for @assistantVoicePreview.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get assistantVoicePreview;

  /// No description provided for @assistantVoicePreviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}. I\'ll help you record your expenses and confirm that everything is correct in Billey.'**
  String assistantVoicePreviewMessage(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
