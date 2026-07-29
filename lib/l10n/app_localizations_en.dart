// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Billey';

  @override
  String get financialManager => 'Financial Manager';

  @override
  String get navHome => 'Home';

  @override
  String get navGoals => 'Goals';

  @override
  String get navActivity => 'Activity';

  @override
  String get navProfile => 'Profile';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addIncomeSubtitle => 'Deposit funds and distribute income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get addExpenseSubtitle => 'Record a purchase or payment';

  @override
  String get splashSubtitle => 'Manage your money smartly';

  @override
  String get loading => 'Loading...';

  @override
  String get introSmartTracking => 'Smart tracking';

  @override
  String get introAutomatedInsights => 'Automated insights';

  @override
  String get introGetStarted => 'Get Started';

  @override
  String get introTakeControl => 'Take Control of';

  @override
  String get introYourWealth => 'Your Wealth';

  @override
  String get setupPagePersonalData => 'Personal data';

  @override
  String get setupPageGoals => 'Savings goals';

  @override
  String get setupPageDistribution => 'Income distribution';

  @override
  String get setupSubtitlePersonalData => 'What we call you and your email';

  @override
  String get setupSubtitleGoals => 'Choose how to start with your goals';

  @override
  String get setupSubtitleDistribution => 'How to split what you earn';

  @override
  String get continueButton => 'Continue';

  @override
  String get finishButton => 'Finish';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameHint => 'What should we call you?';

  @override
  String get nameMinLength => 'Enter at least 2 characters';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'For notifications and exporting data';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get setupGoalsHelp =>
      'Goals are savings targets in your currency (Colombian pesos by default). You can leave them empty, use suggested ones, or create your own now.';

  @override
  String get goalsEmpty => 'Empty';

  @override
  String get goalsSuggested => 'Suggested';

  @override
  String get goalsCustom => 'Custom';

  @override
  String get setupGoalsEmptyHelp =>
      'You\'ll start with no goals. You can create them later from the Goals tab.';

  @override
  String get setupSuggestedHeader => 'These goals will be created for you:';

  @override
  String get goalEmergencyTitle => 'Emergency fund';

  @override
  String get goalEmergencySubtitle => 'Safety';

  @override
  String get goalTripTitle => 'Trip';

  @override
  String get goalTripSubtitle => 'Personal goal';

  @override
  String get setupCustomEmpty =>
      'You don\'t have goals yet. Tap the button below to create the first one.';

  @override
  String get addCustomGoal => 'Add custom goal';

  @override
  String get setupDistributionHelp =>
      'The template defines how to split your income (needs, wants, savings). Pick a template or customize your percentages.';

  @override
  String get chooseTemplate => 'Choose a template';

  @override
  String get customTemplate => 'Custom';

  @override
  String get setupPercentTip =>
      'Tip: they don\'t have to add up to 100 exactly; the app normalizes them.';

  @override
  String get needs => 'Needs';

  @override
  String get wants => 'Wants';

  @override
  String get savings => 'Savings';

  @override
  String get addGoalOrChooseOption =>
      'Add at least one goal or choose another option';

  @override
  String get reviewNameEmail => 'Check your name and email and try again';

  @override
  String get newGoal => 'New goal';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get goalName => 'Name';

  @override
  String get goalNameHint => 'E.g. Emergency fund';

  @override
  String get goalCategory => 'Category';

  @override
  String get goalCategoryHint => 'E.g. Safety';

  @override
  String get goalTargetAmount => 'Target amount';

  @override
  String get goalSavedAmount => 'Saved amount';

  @override
  String get monthsRemaining => 'Months remaining';

  @override
  String get style => 'Style';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get validGoalName => 'Enter a valid name';

  @override
  String get goalTargetPositive => 'Target must be greater than 0';

  @override
  String get goalPersonalDefault => 'Personal';

  @override
  String goalPreviewMeta(String subtitle, String amount) {
    return '$subtitle · Target $amount';
  }

  @override
  String goalPreviewWithMonths(String subtitle, String amount, int months) {
    return '$subtitle · Target $amount · $months months';
  }

  @override
  String get targetLabel => 'Target';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get recentMonths => 'Recent months';

  @override
  String get homeChartTrend => 'Trend';

  @override
  String get homeChartByCategory => 'By category';

  @override
  String get noExpensesInPeriod => 'No expenses in this period';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get seeAll => 'See all';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String todayAt(String time) {
    return 'Today, $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday, $time';
  }

  @override
  String get financialFreedom => 'FINANCIAL FREEDOM';

  @override
  String get yourGoals => 'Your Goals';

  @override
  String get totalSavings => 'Total Savings';

  @override
  String get newGoalSheet => 'New Goal';

  @override
  String get editGoalSheet => 'Edit Goal';

  @override
  String get goalTitle => 'Title';

  @override
  String get goalTitleHint => 'Emergency Fund';

  @override
  String get goalCategoryLabel => 'Category';

  @override
  String get goalCategorySheetHint => 'Safety Net';

  @override
  String get saved => 'Saved';

  @override
  String get target => 'Target';

  @override
  String get monthsLeft => 'Months left';

  @override
  String get goalDefaultSubtitle => 'Goal';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get saveGoal => 'Save Goal';

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String monthsLeftBadge(int count) {
    return '$count mos left';
  }

  @override
  String get transactions => 'Transactions';

  @override
  String get searchHint => 'Search merchant or category...';

  @override
  String get filterAll => 'All';

  @override
  String get filterIncome => 'Income';

  @override
  String get filterExpenses => 'Expenses';

  @override
  String get filterPending => 'Pending';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get dateToday => 'TODAY';

  @override
  String get dateYesterday => 'YESTERDAY';

  @override
  String get deleteTransactionTitle => 'Delete transaction?';

  @override
  String deleteTransactionMessage(String title) {
    return 'This will remove \"$title\" permanently.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get newExpense => 'New Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get addIncomeTitle => 'Add Income';

  @override
  String get editIncomeTitle => 'Edit Income';

  @override
  String get source => 'Source';

  @override
  String get sourceHint => 'Client Payment';

  @override
  String get date => 'Date';

  @override
  String todayDate(String date) {
    return 'Today, $date';
  }

  @override
  String get autoDistributeIncome => 'Auto-distribute Income';

  @override
  String usingTemplate(String name) {
    return 'Using $name';
  }

  @override
  String get distributionPaused => 'Distribution paused';

  @override
  String percentAllocation(String percent) {
    return '$percent% allocation';
  }

  @override
  String get editDistributionRules => 'Edit Distribution Rules';

  @override
  String get depositFunds => 'Deposit Funds';

  @override
  String get automatedRules => 'Automated Rules';

  @override
  String get reset => 'Reset';

  @override
  String get totalAllocation => 'TOTAL ALLOCATION';

  @override
  String get saveRules => 'Save Rules';

  @override
  String monthlyAllocation(String amount) {
    return '$amount monthly';
  }

  @override
  String get done => 'Done';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get expenseHint => 'Dinner at Nobu';

  @override
  String get tapToSpeak => 'TAP TO SPEAK';

  @override
  String get listening => 'LISTENING...';

  @override
  String get voiceTranscribing => 'TRANSCRIBING...';

  @override
  String get voicePlaying => 'PLAYING...';

  @override
  String get voiceListenConfirmation => 'LISTEN TO CONFIRMATION';

  @override
  String get voiceConfirmationPrefix => 'I understood:';

  @override
  String get confirmExpense => 'Confirm Expense';

  @override
  String get updateExpense => 'Update Expense';

  @override
  String get confirmIncome => 'Confirm Income';

  @override
  String get updateIncome => 'Confirm Income';

  @override
  String get conceptMinLength => 'Enter a description of at least 3 characters';

  @override
  String get amountMustBePositive => 'Enter an amount greater than 0';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get transactionAdded => 'Transaction added successfully';

  @override
  String get transactionUpdated => 'Transaction updated successfully';

  @override
  String get voiceNotAvailable =>
      'Voice not available. Stop the app, run \"flutter pub get\", then \"cd ios && pod install\" and reopen with flutter run (don\'t use hot reload).';

  @override
  String get micPermissionRequired =>
      'Enable microphone permission to record expenses by voice.';

  @override
  String get voiceAmountNotUnderstood =>
      'Couldn\'t understand the amount. Try: \"Spent 50000 on food\" or \"Paid 25 thousand for taxi\".';

  @override
  String get voiceAmountDetected =>
      'Amount detected. Adjust the description or speak again with more detail.';

  @override
  String autoDistributionNote(String essentials, String wants, String savings) {
    return 'Auto-distribution: Needs $essentials%, Wants $wants%, Savings $savings%';
  }

  @override
  String get autoDistribution => 'Auto-distribution';

  @override
  String get templatesSection => 'TEMPLATES';

  @override
  String get customRuleSection => 'CUSTOM RULE';

  @override
  String get customTemplateSubtitle => 'Adjust percentages to your reality';

  @override
  String get disabledForNewDeposits => 'Disabled for new deposits';

  @override
  String get totalAllocationLabel => 'Total allocation';

  @override
  String get saveCustomRule => 'Save Custom Rule';

  @override
  String get customRuleSaved => 'Custom rule saved';

  @override
  String get settings => 'Settings';

  @override
  String get generalSection => 'GENERAL';

  @override
  String get dataPrivacySection => 'DATA & PRIVACY';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get accountSecurity => 'Account Security';

  @override
  String get currencySetting => 'Currency';

  @override
  String get budgetLimits => 'Budget Limits';

  @override
  String get dataExport => 'Data Export';

  @override
  String get csvPdf => 'CSV/PDF';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get versionInfo => 'Version 1.0.0 (Build 1)';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String currencyItem(String name, String code) {
    return '$name ($code)';
  }

  @override
  String get csvHeaders => 'Date, Type, Category, Concept, Amount, Description';

  @override
  String get exportShareText => 'My Billey transactions';

  @override
  String get exportFailed => 'Could not export data. Please try again.';

  @override
  String get exportDataTitle => 'Export data';

  @override
  String get exportFormatSection => 'Format';

  @override
  String get exportFormatCsv => 'CSV';

  @override
  String get exportFormatPdf => 'PDF';

  @override
  String get exportContentSection => 'Content';

  @override
  String get exportContentAll => 'All (income and expenses)';

  @override
  String get exportContentExpenses => 'Expenses only';

  @override
  String get exportContentIncome => 'Income only';

  @override
  String get exportButton => 'Export';

  @override
  String get exportNoData => 'No transactions match this selection.';

  @override
  String get exportPdfTitle => 'Billey transactions';

  @override
  String exportPdfGenerated(String date) {
    return 'Generated on $date';
  }

  @override
  String get exportPdfSummaryIncome => 'Total income';

  @override
  String get exportPdfSummaryExpenses => 'Total expenses';

  @override
  String get exportPdfSummaryCount => 'Records';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get photoUpdated => 'Profile photo updated';

  @override
  String get photoRemoved => 'Profile photo removed';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get dataStoredLocally => 'Data is stored only on this device.';

  @override
  String get yourName => 'Your name';

  @override
  String get emailHintShort => 'you@email.com';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get checkNameEmail => 'Check your name and email';

  @override
  String get completeProfile => 'Complete your profile';

  @override
  String get addYourEmail => 'Add your email';

  @override
  String featureComingSoon(String feature) {
    return '$feature will be available soon';
  }

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutMessage =>
      'Your local session will remain secure on this device.';

  @override
  String get spendingInsights => 'Spending Insights';

  @override
  String get monthlyComparison => 'Monthly Comparison';

  @override
  String get viewReport => 'View Report';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get totalSpend => 'Total Spend';

  @override
  String get insight => 'Insight';

  @override
  String get youSpent => 'You spent';

  @override
  String get less => 'less';

  @override
  String get more => 'more';

  @override
  String get insightBudgetTight =>
      'this month. Nice work keeping the budget tight.';

  @override
  String get monthlySpending => 'Monthly spending';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get thisMonth => 'This Month';

  @override
  String get categoryManagement => 'Category Management';

  @override
  String get deactivatedCategories => 'Deactivated Categories';

  @override
  String get defaultBadge => 'Default';

  @override
  String get deactivatedBadge => 'Deactivated';

  @override
  String get edit => 'Edit';

  @override
  String get activate => 'Activate';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get deleteCategoryTitle => 'Delete Category';

  @override
  String deleteCategoryMessage(String name) {
    return 'Are you sure you want to delete the category \"$name\"?';
  }

  @override
  String get deleteDefaultCategoryWarning =>
      'This is a default category. It can be deleted but may affect functionality.';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String categoryActivated(String name) {
    return 'Category \"$name\" activated';
  }

  @override
  String categoryDeleted(String name) {
    return 'Category \"$name\" deleted';
  }

  @override
  String get editCategory => 'Edit Category';

  @override
  String get newCategory => 'New Category';

  @override
  String get saveUpper => 'SAVE';

  @override
  String get createUpper => 'CREATE';

  @override
  String get preview => 'Preview';

  @override
  String get categoryNamePlaceholder => 'Category name';

  @override
  String get customSectionPlaceholder => 'Custom section';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryNameHint => 'E.g.: Gym, Pets, etc.';

  @override
  String get categoryAutoSuggested => 'Icon and color suggested from the name';

  @override
  String get enterCategoryName => 'Please enter a name';

  @override
  String get categoryNameMinLength => 'Name must be at least 2 characters';

  @override
  String get categoryNameExists => 'A category with this name already exists';

  @override
  String get section => 'Section';

  @override
  String get predefined => 'Predefined';

  @override
  String get customSection => 'Custom';

  @override
  String get sectionNameHint => 'Section name';

  @override
  String get sectionNameRequired => 'Section name is required';

  @override
  String get selectSection => 'Select section';

  @override
  String get sectionColor => 'Section color';

  @override
  String get selectIcon => 'Select an Icon';

  @override
  String get selectColor => 'Select a Color';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get createCategory => 'Create Category';

  @override
  String get categoryUpdated => 'Category updated successfully';

  @override
  String get categoryCreated => 'Category created successfully';

  @override
  String get monthlySummary => 'Monthly Summary';

  @override
  String get balance => 'Balance';

  @override
  String get incomeVsExpenses => 'Income vs Expenses';

  @override
  String get noExpensesThisMonth => 'No expenses this month';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get categoryDetail => 'Category Detail';

  @override
  String summaryFor(String month) {
    return 'Summary for $month';
  }

  @override
  String totalIncomeLine(String amount) {
    return 'Total Income: $amount';
  }

  @override
  String totalExpenseLine(String amount) {
    return 'Total Expense: $amount';
  }

  @override
  String balanceLine(String amount) {
    return 'Balance: $amount';
  }

  @override
  String get firstTransactionTitle => 'Your first transaction awaits!';

  @override
  String get firstTransactionMessage =>
      'Start recording your income and expenses to take full control of your money.';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get summary => 'Summary';

  @override
  String get deleteTransactionCardTitle => 'Delete transaction?';

  @override
  String deleteTransactionCardMessage(String title, String amount) {
    return '\"$title\" for $amount will be removed.\n\nThis action cannot be undone.';
  }

  @override
  String get transactionDeleted => 'Transaction deleted successfully';

  @override
  String get defaultUser => 'User';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get currencyCop => 'Colombian peso';

  @override
  String get currencyUsd => 'US dollar';

  @override
  String get currencyEur => 'Euro';

  @override
  String get currencyMxn => 'Mexican peso';

  @override
  String get currencyBrl => 'Brazilian real';

  @override
  String get goalStyleEmergency => 'Emergency';

  @override
  String get goalStyleTrip => 'Trip';

  @override
  String get goalStyleCar => 'Car';

  @override
  String get goalStyleHome => 'Home';

  @override
  String get goalStyleEducation => 'Education';

  @override
  String get goalStyleHealth => 'Health';

  @override
  String get goalStyleTech => 'Technology';

  @override
  String get goalStyleWedding => 'Wedding';

  @override
  String get goalStyleBusiness => 'Business';

  @override
  String get goalStyleGift => 'Gift';

  @override
  String get bucketEssentials => 'Essentials';

  @override
  String get bucketWants => 'Wants';

  @override
  String get bucketSavings => 'Savings';

  @override
  String get bucketDebts => 'Debts';

  @override
  String get bucketInvesting => 'Investing';

  @override
  String get bucketBuffer => 'Buffer';

  @override
  String get templateBalancedName => '50/30/20 Balanced';

  @override
  String get templateBalancedSubtitle => 'Needs, wants and savings';

  @override
  String get templateDebtFirstName => 'Debt first';

  @override
  String get templateDebtFirstSubtitle => 'Adds a dedicated envelope for debt';

  @override
  String get templateInvestorName => 'Investor mode';

  @override
  String get templateInvestorSubtitle => 'Savings separate from investing';

  @override
  String get templateVariableName => 'Variable income';

  @override
  String get templateVariableSubtitle => 'Includes buffer for slow months';

  @override
  String get templateCustomName => 'Custom';

  @override
  String get templateCustomSubtitle => 'Your own distribution rule';

  @override
  String get txnCategoryFood => 'Food';

  @override
  String get txnCategoryTransport => 'Transport';

  @override
  String get txnCategoryEntertainment => 'Entertainment';

  @override
  String get txnCategoryHealth => 'Health';

  @override
  String get txnCategoryEducation => 'Education';

  @override
  String get txnCategoryOther => 'Other';

  @override
  String get insightDemoHousing => 'Housing';

  @override
  String get insightDemoHousingSubtitle => 'Rent & Utilities';

  @override
  String get insightDemoFoodDining => 'Food & Dining';

  @override
  String get insightDemoFoodDiningSubtitle => 'Groceries, Restaurants';

  @override
  String get insightDemoFun => 'Fun';

  @override
  String get insightDemoFunSubtitle => 'Entertainment';

  @override
  String get insightDemoTransport => 'Transport';

  @override
  String get insightDemoTransportSubtitle => 'Mobility';

  @override
  String get paymentReminders => 'Payment reminders';

  @override
  String get addPaymentReminder => 'Add reminder';

  @override
  String get editPaymentReminder => 'Edit reminder';

  @override
  String get paymentRemindersEmpty =>
      'Create reminders for your bills and payments. You can set them to repeat every month.';

  @override
  String get paymentReminderName => 'Payment name';

  @override
  String get paymentReminderNameHint => 'E.g. Rent, Netflix, Credit card';

  @override
  String get paymentReminderNameRequired =>
      'Enter a name with at least 2 characters';

  @override
  String get paymentReminderAmount => 'Amount (optional)';

  @override
  String get paymentReminderAmountHint => '500000';

  @override
  String get paymentReminderTime => 'Time';

  @override
  String get paymentReminderDayOfMonth => 'Day of the month';

  @override
  String paymentReminderDayOption(int day) {
    return 'Day $day';
  }

  @override
  String get paymentReminderDate => 'Payment date';

  @override
  String get paymentReminderRepeatMonthly => 'Repeat monthly';

  @override
  String get paymentReminderRepeatMonthlyHint =>
      'Get notified on the same day every month';

  @override
  String get paymentReminderEnabled => 'Reminder enabled';

  @override
  String paymentReminderScheduleMonthly(int day, String time) {
    return 'Day $day at $time · Monthly';
  }

  @override
  String paymentReminderScheduleOnce(String date, String time) {
    return '$date at $time · One time';
  }

  @override
  String paymentReminderBody(String amount) {
    return 'Payment due: $amount';
  }

  @override
  String get paymentReminderBodySimple => 'Payment reminder';

  @override
  String get deletePaymentReminderTitle => 'Delete reminder?';

  @override
  String deletePaymentReminderMessage(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get notificationPermissionDenied =>
      'Enable notifications in settings to receive payment reminders';

  @override
  String get coupleFinanceTitle => 'Shared finances';

  @override
  String get couplePairingIntro =>
      'Link your phone with family or friends by scanning a QR code. Then share transfers and track spending by syncing with QR.';

  @override
  String get couplePartnerName => 'Name of person you share with';

  @override
  String get couplePartnerNameHint => 'E.g. Maria, dad, sibling';

  @override
  String get couplePartnerNameRequired => 'Enter a name';

  @override
  String get coupleShowPairingQr => 'Show pairing QR';

  @override
  String get coupleScanPairingQr => 'Scan QR';

  @override
  String get couplePairingQrTitle => 'Link';

  @override
  String couplePairingQrSubtitle(String name) {
    return 'Ask $name to scan this code';
  }

  @override
  String get coupleQrHint =>
      'Keep this code visible until it is scanned from Billey.';

  @override
  String get coupleScanQr => 'Scan QR';

  @override
  String get coupleScanHint => 'Point the camera at the Billey QR code.';

  @override
  String get coupleScanFromCamera => 'Scanning with Billey\'s camera';

  @override
  String get coupleScanFromGallery => 'Choose from gallery';

  @override
  String get coupleQrNotFound =>
      'No Billey QR detected. Try again with better lighting.';

  @override
  String get couplePasteHint =>
      'If the camera does not work, paste here the code shown under the QR.';

  @override
  String get couplePasteConfirm => 'Use code';

  @override
  String coupleLinkedWith(String name) {
    return 'Sharing with $name';
  }

  @override
  String get coupleSyncReminder =>
      'After each expense, share an update via QR so both of you see the movements.';

  @override
  String get coupleShareUpdate => 'Share QR';

  @override
  String get coupleScanUpdate => 'Scan';

  @override
  String get coupleSharedWallets => 'Shared transfers';

  @override
  String get coupleWalletsEmpty =>
      'Create a transfer (e.g. 2M) and share the QR so they receive it on their phone.';

  @override
  String get coupleNewTransfer => 'New transfer';

  @override
  String get coupleTransferTitle => 'Title';

  @override
  String get coupleTransferTitleHint => 'E.g. March budget';

  @override
  String get coupleTransferAmount => 'Amount';

  @override
  String coupleHolderIsPartner(String name) {
    return 'Used by $name';
  }

  @override
  String get coupleWalletCreated =>
      'Transfer created. Show the QR to share it.';

  @override
  String get coupleSyncQrTitle => 'Sync';

  @override
  String coupleSyncQrSubtitle(String title) {
    return 'Scan to update \"$title\"';
  }

  @override
  String get coupleSyncQrSubtitleAll =>
      'Scan to update all transfers and expenses';

  @override
  String get coupleSyncSuccess => 'Data synced successfully';

  @override
  String get coupleSyncInvalid =>
      'Could not read the QR. Make sure it\'s from Billey.';

  @override
  String get coupleLinkedSuccess => 'Successfully linked!';

  @override
  String get coupleUnlink => 'Unlink';

  @override
  String get coupleUnlinkTitle => 'Unlink shared finances?';

  @override
  String get coupleUnlinkMessage =>
      'Shared transfers on this device will be deleted. The other person keeps their local copy.';

  @override
  String get coupleUnlinked => 'Unlinked successfully';

  @override
  String get coupleSharedWallet => 'Shared transfer';

  @override
  String get coupleWalletNotFound => 'Transfer not found';

  @override
  String get coupleAddExpense => 'Add expense';

  @override
  String get coupleExpenseTitle => 'Expense description';

  @override
  String get coupleExpenseAmount => 'Amount';

  @override
  String get coupleBudget => 'Budget';

  @override
  String get coupleSpent => 'Spent';

  @override
  String get coupleRemaining => 'Remaining';

  @override
  String get coupleFrom => 'From';

  @override
  String get coupleFor => 'For';

  @override
  String get coupleExpenses => 'Expenses';

  @override
  String get coupleNoExpensesYet => 'No expenses in this transfer yet';

  @override
  String get assistantVoice => 'Assistant voice';

  @override
  String get assistantVoiceDescription =>
      'Choose the voice for spoken confirmations';

  @override
  String get assistantFemaleVoice => 'Warm female';

  @override
  String get assistantMaleVoice => 'Warm male';
}
