// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Billey';

  @override
  String get financialManager => 'Gestor Financiero';

  @override
  String get navHome => 'Inicio';

  @override
  String get navGoals => 'Metas';

  @override
  String get navActivity => 'Actividad';

  @override
  String get navProfile => 'Perfil';

  @override
  String get addIncome => 'Agregar ingreso';

  @override
  String get addIncomeSubtitle => 'Deposita fondos y distribuye ingresos';

  @override
  String get addExpense => 'Agregar gasto';

  @override
  String get addExpenseSubtitle => 'Registra una compra o pago';

  @override
  String get splashSubtitle => 'Gestiona tu dinero con inteligencia';

  @override
  String get loading => 'Cargando...';

  @override
  String get introSmartTracking => 'Seguimiento inteligente';

  @override
  String get introAutomatedInsights => 'Análisis automatizados';

  @override
  String get introGetStarted => 'Comenzar';

  @override
  String get introTakeControl => 'Toma el control de';

  @override
  String get introYourWealth => 'tu dinero';

  @override
  String get setupPagePersonalData => 'Datos personales';

  @override
  String get setupPageGoals => 'Metas de ahorro';

  @override
  String get setupPageDistribution => 'Distribución de ingresos';

  @override
  String get setupSubtitlePersonalData => 'Cómo te llamamos y tu correo';

  @override
  String get setupSubtitleGoals => 'Elige cómo empezar con tus metas';

  @override
  String get setupSubtitleDistribution => 'Cómo repartir lo que ganas';

  @override
  String get continueButton => 'Continuar';

  @override
  String get finishButton => 'Finalizar';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get fullNameHint => 'Cómo quieres que te llamemos';

  @override
  String get nameMinLength => 'Escribe al menos 2 caracteres';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailHint => 'Para notificaciones y exportar datos';

  @override
  String get emailRequired => 'El correo es obligatorio';

  @override
  String get emailInvalid => 'Escribe un correo válido';

  @override
  String get setupGoalsHelp =>
      'Las metas son objetivos de ahorro en tu moneda (por defecto pesos colombianos). Puedes dejarlas vacías, usar sugeridas o crear las tuyas ahora.';

  @override
  String get goalsEmpty => 'Vacías';

  @override
  String get goalsSuggested => 'Sugeridas';

  @override
  String get goalsCustom => 'Propias';

  @override
  String get setupGoalsEmptyHelp =>
      'Empezarás sin metas. Podrás crearlas después desde la pestaña Metas.';

  @override
  String get setupSuggestedHeader => 'Estas metas se crearán por ti:';

  @override
  String get goalEmergencyTitle => 'Fondo de emergencia';

  @override
  String get goalEmergencySubtitle => 'Seguridad';

  @override
  String get goalTripTitle => 'Viaje';

  @override
  String get goalTripSubtitle => 'Meta personal';

  @override
  String get setupCustomEmpty =>
      'Aún no tienes metas. Toca el botón de abajo para crear la primera.';

  @override
  String get addCustomGoal => 'Agregar meta personalizada';

  @override
  String get setupDistributionHelp =>
      'La plantilla define cómo repartir tus ingresos (necesidades, deseos, ahorro). Elige una plantilla o personaliza tus porcentajes.';

  @override
  String get chooseTemplate => 'Elige una plantilla';

  @override
  String get customTemplate => 'Personalizada';

  @override
  String get setupPercentTip =>
      'Tip: no tienen que sumar 100 exacto; la app los normaliza.';

  @override
  String get needs => 'Necesidades';

  @override
  String get wants => 'Deseos';

  @override
  String get savings => 'Ahorro';

  @override
  String get addGoalOrChooseOption =>
      'Agrega al menos una meta o elige otra opción';

  @override
  String get reviewNameEmail =>
      'Revisa tu nombre y correo e inténtalo de nuevo';

  @override
  String get newGoal => 'Nueva meta';

  @override
  String get editGoal => 'Editar meta';

  @override
  String get goalName => 'Nombre';

  @override
  String get goalNameHint => 'Ej. Fondo de emergencia';

  @override
  String get goalCategory => 'Categoría';

  @override
  String get goalCategoryHint => 'Ej. Seguridad';

  @override
  String get goalTargetAmount => 'Meta (monto)';

  @override
  String get goalSavedAmount => 'Ahorrado (monto)';

  @override
  String get monthsRemaining => 'Meses restantes';

  @override
  String get style => 'Estilo';

  @override
  String get add => 'Agregar';

  @override
  String get save => 'Guardar';

  @override
  String get validGoalName => 'Escribe un nombre válido';

  @override
  String get goalTargetPositive => 'La meta debe ser mayor a 0';

  @override
  String get goalPersonalDefault => 'Personal';

  @override
  String goalPreviewMeta(String subtitle, String amount) {
    return '$subtitle · Meta $amount';
  }

  @override
  String goalPreviewWithMonths(String subtitle, String amount, int months) {
    return '$subtitle · Meta $amount · $months meses';
  }

  @override
  String get targetLabel => 'Meta';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get totalBalance => 'Balance total';

  @override
  String get income => 'Ingresos';

  @override
  String get expenses => 'Gastos';

  @override
  String get recentMonths => 'Últimos meses';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get noTransactionsYet => 'Aún no hay transacciones';

  @override
  String todayAt(String time) {
    return 'Hoy, $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ayer, $time';
  }

  @override
  String get financialFreedom => 'LIBERTAD FINANCIERA';

  @override
  String get yourGoals => 'Tus metas';

  @override
  String get totalSavings => 'Ahorro total';

  @override
  String get newGoalSheet => 'Nueva meta';

  @override
  String get editGoalSheet => 'Editar meta';

  @override
  String get goalTitle => 'Título';

  @override
  String get goalTitleHint => 'Fondo de emergencia';

  @override
  String get goalCategoryLabel => 'Categoría';

  @override
  String get goalCategorySheetHint => 'Red de seguridad';

  @override
  String get saved => 'Ahorrado';

  @override
  String get target => 'Meta';

  @override
  String get monthsLeft => 'Meses restantes';

  @override
  String get goalDefaultSubtitle => 'Meta';

  @override
  String get createGoal => 'Crear meta';

  @override
  String get saveGoal => 'Guardar meta';

  @override
  String get deleteGoal => 'Eliminar meta';

  @override
  String monthsLeftBadge(int count) {
    return '$count meses';
  }

  @override
  String get transactions => 'Transacciones';

  @override
  String get searchHint => 'Buscar comercio o categoría...';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterIncome => 'Ingresos';

  @override
  String get filterExpenses => 'Gastos';

  @override
  String get filterPending => 'Pendientes';

  @override
  String get noTransactionsFound => 'No se encontraron transacciones';

  @override
  String get dateToday => 'HOY';

  @override
  String get dateYesterday => 'AYER';

  @override
  String get deleteTransactionTitle => '¿Eliminar transacción?';

  @override
  String deleteTransactionMessage(String title) {
    return 'Se eliminará \"$title\" permanentemente.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get newExpense => 'Nuevo gasto';

  @override
  String get editExpense => 'Editar gasto';

  @override
  String get addIncomeTitle => 'Agregar ingreso';

  @override
  String get editIncomeTitle => 'Editar ingreso';

  @override
  String get source => 'Fuente';

  @override
  String get sourceHint => 'Pago de cliente';

  @override
  String get date => 'Fecha';

  @override
  String todayDate(String date) {
    return 'Hoy, $date';
  }

  @override
  String get autoDistributeIncome => 'Auto-distribuir ingreso';

  @override
  String usingTemplate(String name) {
    return 'Usando $name';
  }

  @override
  String get distributionPaused => 'Distribución pausada';

  @override
  String percentAllocation(String percent) {
    return '$percent% asignación';
  }

  @override
  String get editDistributionRules => 'Editar reglas de distribución';

  @override
  String get depositFunds => 'Depositar fondos';

  @override
  String get automatedRules => 'Reglas automatizadas';

  @override
  String get reset => 'Restablecer';

  @override
  String get totalAllocation => 'ASIGNACIÓN TOTAL';

  @override
  String get saveRules => 'Guardar reglas';

  @override
  String monthlyAllocation(String amount) {
    return '$amount mensual';
  }

  @override
  String get done => 'Listo';

  @override
  String get chooseCategory => 'Elegir categoría';

  @override
  String get expenseHint => 'Cena en restaurante';

  @override
  String get tapToSpeak => 'TOCA PARA HABLAR';

  @override
  String get listening => 'ESCUCHANDO...';

  @override
  String get confirmExpense => 'Confirmar gasto';

  @override
  String get updateExpense => 'Actualizar gasto';

  @override
  String get confirmIncome => 'Confirmar ingreso';

  @override
  String get updateIncome => 'Actualizar ingreso';

  @override
  String get conceptMinLength => 'Ingresa un concepto de al menos 3 caracteres';

  @override
  String get amountMustBePositive => 'Ingresa un valor mayor a 0';

  @override
  String get selectCategory => 'Selecciona una categoría';

  @override
  String get transactionAdded => 'Transacción agregada correctamente';

  @override
  String get transactionUpdated => 'Transacción actualizada correctamente';

  @override
  String get voiceNotAvailable =>
      'Voz no disponible. Detén la app, ejecuta \"flutter pub get\", luego \"cd ios && pod install\" y vuelve a abrir con flutter run (no uses hot reload).';

  @override
  String get micPermissionRequired =>
      'Activa el permiso de micrófono para registrar gastos por voz.';

  @override
  String get voiceAmountNotUnderstood =>
      'No entendí el monto. Prueba: \"Gasté 50000 en comida\" o \"Pagué 25 mil de taxi\".';

  @override
  String get voiceAmountDetected =>
      'Monto detectado. Ajusta el concepto o vuelve a hablar con más detalle.';

  @override
  String autoDistributionNote(String essentials, String wants, String savings) {
    return 'Auto-distribución: Necesidades $essentials%, Deseos $wants%, Ahorro $savings%';
  }

  @override
  String get autoDistribution => 'Auto-distribución';

  @override
  String get templatesSection => 'PLANTILLAS';

  @override
  String get customRuleSection => 'REGLA PERSONALIZADA';

  @override
  String get customTemplateSubtitle => 'Ajusta porcentajes a tu realidad';

  @override
  String get disabledForNewDeposits => 'Desactivado para nuevos depósitos';

  @override
  String get totalAllocationLabel => 'Asignación total';

  @override
  String get saveCustomRule => 'Guardar regla personalizada';

  @override
  String get customRuleSaved => 'Regla personalizada guardada';

  @override
  String get settings => 'Ajustes';

  @override
  String get generalSection => 'GENERAL';

  @override
  String get dataPrivacySection => 'DATOS Y PRIVACIDAD';

  @override
  String get personalInformation => 'Información personal';

  @override
  String get accountSecurity => 'Seguridad de la cuenta';

  @override
  String get currencySetting => 'Moneda';

  @override
  String get budgetLimits => 'Límites de presupuesto';

  @override
  String get dataExport => 'Exportar datos';

  @override
  String get csvPdf => 'CSV/PDF';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get versionInfo => 'Versión 1.0.0 (Build 1)';

  @override
  String get selectCurrency => 'Seleccionar moneda';

  @override
  String currencyItem(String name, String code) {
    return '$name ($code)';
  }

  @override
  String get csvHeaders =>
      'Fecha, Tipo, Categoría, Concepto, Monto, Descripción';

  @override
  String get exportShareText => 'Mis transacciones de Billey';

  @override
  String get exportFailed =>
      'No se pudo exportar los datos. Inténtalo de nuevo.';

  @override
  String get exportDataTitle => 'Exportar datos';

  @override
  String get exportFormatSection => 'Formato';

  @override
  String get exportFormatCsv => 'CSV';

  @override
  String get exportFormatPdf => 'PDF';

  @override
  String get exportContentSection => 'Contenido';

  @override
  String get exportContentAll => 'Todo (ingresos y gastos)';

  @override
  String get exportContentExpenses => 'Solo gastos';

  @override
  String get exportContentIncome => 'Solo ingresos';

  @override
  String get exportButton => 'Exportar';

  @override
  String get exportNoData =>
      'No hay transacciones para exportar con esta selección.';

  @override
  String get exportPdfTitle => 'Transacciones Billey';

  @override
  String exportPdfGenerated(String date) {
    return 'Generado el $date';
  }

  @override
  String get exportPdfSummaryIncome => 'Total ingresos';

  @override
  String get exportPdfSummaryExpenses => 'Total gastos';

  @override
  String get exportPdfSummaryCount => 'Registros';

  @override
  String get transactionTypeIncome => 'Ingreso';

  @override
  String get transactionTypeExpense => 'Gasto';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get photoUpdated => 'Foto de perfil actualizada';

  @override
  String get photoRemoved => 'Foto de perfil eliminada';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get dataStoredLocally =>
      'Los datos se guardan solo en este dispositivo.';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get emailHintShort => 'tu@correo.com';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get checkNameEmail => 'Revisa el nombre y el correo';

  @override
  String get completeProfile => 'Completa tu perfil';

  @override
  String get addYourEmail => 'Añade tu correo electrónico';

  @override
  String featureComingSoon(String feature) {
    return '$feature estará disponible pronto';
  }

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get logOutMessage =>
      'Tu sesión local se mantendrá segura en este dispositivo.';

  @override
  String get spendingInsights => 'Análisis de gastos';

  @override
  String get monthlyComparison => 'Comparación mensual';

  @override
  String get viewReport => 'Ver informe';

  @override
  String get topCategories => 'Principales categorías';

  @override
  String get totalSpend => 'Gasto total';

  @override
  String get insight => 'Insight';

  @override
  String get youSpent => 'Gastaste';

  @override
  String get less => 'menos';

  @override
  String get more => 'más';

  @override
  String get insightBudgetTight =>
      'este mes. Buen trabajo manteniendo el presupuesto.';

  @override
  String get monthlySpending => 'Gasto mensual';

  @override
  String get lastMonth => 'Mes anterior';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get categoryManagement => 'Gestión de categorías';

  @override
  String get deactivatedCategories => 'Categorías desactivadas';

  @override
  String get defaultBadge => 'Por defecto';

  @override
  String get deactivatedBadge => 'Desactivada';

  @override
  String get edit => 'Editar';

  @override
  String get activate => 'Activar';

  @override
  String get addNewCategory => 'Agregar nueva categoría';

  @override
  String get deleteCategoryTitle => 'Eliminar categoría';

  @override
  String deleteCategoryMessage(String name) {
    return '¿Estás seguro de que quieres eliminar la categoría \"$name\"?';
  }

  @override
  String get deleteDefaultCategoryWarning =>
      'Es una categoría por defecto. Se puede eliminar pero podría afectar el funcionamiento.';

  @override
  String get actionCannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String categoryActivated(String name) {
    return 'Categoría \"$name\" activada';
  }

  @override
  String categoryDeleted(String name) {
    return 'Categoría \"$name\" eliminada';
  }

  @override
  String get editCategory => 'Editar categoría';

  @override
  String get newCategory => 'Nueva categoría';

  @override
  String get saveUpper => 'GUARDAR';

  @override
  String get createUpper => 'CREAR';

  @override
  String get preview => 'Vista previa';

  @override
  String get categoryNamePlaceholder => 'Nombre de la categoría';

  @override
  String get customSectionPlaceholder => 'Sección personalizada';

  @override
  String get categoryName => 'Nombre de la categoría';

  @override
  String get categoryNameHint => 'Ej: Gimnasio, Mascotas, etc.';

  @override
  String get enterCategoryName => 'Por favor ingresa un nombre';

  @override
  String get categoryNameMinLength =>
      'El nombre debe tener al menos 2 caracteres';

  @override
  String get categoryNameExists => 'Ya existe una categoría con este nombre';

  @override
  String get section => 'Sección';

  @override
  String get predefined => 'Predefinida';

  @override
  String get customSection => 'Personalizada';

  @override
  String get sectionNameHint => 'Nombre de la sección';

  @override
  String get sectionNameRequired => 'El nombre de la sección es requerido';

  @override
  String get selectSection => 'Seleccionar sección';

  @override
  String get sectionColor => 'Color de la sección';

  @override
  String get selectIcon => 'Selecciona un ícono';

  @override
  String get selectColor => 'Selecciona un color';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get createCategory => 'Crear categoría';

  @override
  String get categoryUpdated => 'Categoría actualizada correctamente';

  @override
  String get categoryCreated => 'Categoría creada correctamente';

  @override
  String get monthlySummary => 'Resumen mensual';

  @override
  String get balance => 'Balance';

  @override
  String get incomeVsExpenses => 'Ingresos vs Gastos';

  @override
  String get noExpensesThisMonth => 'No hay gastos este mes';

  @override
  String get expensesByCategory => 'Gastos por categoría';

  @override
  String get categoryDetail => 'Detalle por categoría';

  @override
  String summaryFor(String month) {
    return 'Resumen de $month';
  }

  @override
  String totalIncomeLine(String amount) {
    return 'Ingresos totales: $amount';
  }

  @override
  String totalExpenseLine(String amount) {
    return 'Gastos totales: $amount';
  }

  @override
  String balanceLine(String amount) {
    return 'Balance: $amount';
  }

  @override
  String get firstTransactionTitle => '¡Tu primera transacción te espera!';

  @override
  String get firstTransactionMessage =>
      'Comienza registrando tus ingresos y gastos para tener control total de tu dinero.';

  @override
  String get addTransaction => 'Agregar transacción';

  @override
  String get summary => 'Resumen';

  @override
  String get deleteTransactionCardTitle => '¿Eliminar transacción?';

  @override
  String deleteTransactionCardMessage(String title, String amount) {
    return 'Se eliminará \"$title\" por $amount.\n\nEsta acción no se puede deshacer.';
  }

  @override
  String get transactionDeleted => 'Transacción eliminada correctamente';

  @override
  String get defaultUser => 'Usuario';

  @override
  String greetingMorning(String name) {
    return 'Buenos días, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Buenas tardes, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Buenas noches, $name';
  }

  @override
  String get currencyCop => 'Peso colombiano';

  @override
  String get currencyUsd => 'Dólar estadounidense';

  @override
  String get currencyEur => 'Euro';

  @override
  String get currencyMxn => 'Peso mexicano';

  @override
  String get currencyBrl => 'Real brasileño';

  @override
  String get goalStyleEmergency => 'Emergencia';

  @override
  String get goalStyleTrip => 'Viaje';

  @override
  String get goalStyleCar => 'Auto';

  @override
  String get goalStyleHome => 'Casa';

  @override
  String get goalStyleEducation => 'Educación';

  @override
  String get goalStyleHealth => 'Salud';

  @override
  String get goalStyleTech => 'Tecnología';

  @override
  String get goalStyleWedding => 'Boda';

  @override
  String get goalStyleBusiness => 'Negocio';

  @override
  String get goalStyleGift => 'Regalo';

  @override
  String get bucketEssentials => 'Necesidades';

  @override
  String get bucketWants => 'Deseos';

  @override
  String get bucketSavings => 'Ahorro';

  @override
  String get bucketDebts => 'Deudas';

  @override
  String get bucketInvesting => 'Inversión';

  @override
  String get bucketBuffer => 'Colchón';

  @override
  String get templateBalancedName => '50/30/20 Balanceado';

  @override
  String get templateBalancedSubtitle => 'Necesidades, gustos y ahorro';

  @override
  String get templateDebtFirstName => 'Deudas primero';

  @override
  String get templateDebtFirstSubtitle => 'Agrega un sobre dedicado a deudas';

  @override
  String get templateInvestorName => 'Modo inversionista';

  @override
  String get templateInvestorSubtitle => 'Ahorro separado de inversión';

  @override
  String get templateVariableName => 'Ingreso variable';

  @override
  String get templateVariableSubtitle => 'Incluye colchón para meses flojos';

  @override
  String get templateCustomName => 'Personalizada';

  @override
  String get templateCustomSubtitle => 'Tu propia regla de distribución';

  @override
  String get txnCategoryFood => 'Comida';

  @override
  String get txnCategoryTransport => 'Transporte';

  @override
  String get txnCategoryEntertainment => 'Entretenimiento';

  @override
  String get txnCategoryHealth => 'Salud';

  @override
  String get txnCategoryEducation => 'Educación';

  @override
  String get txnCategoryOther => 'Otros';

  @override
  String get insightDemoHousing => 'Vivienda';

  @override
  String get insightDemoHousingSubtitle => 'Arriendo y servicios';

  @override
  String get insightDemoFoodDining => 'Comida';

  @override
  String get insightDemoFoodDiningSubtitle => 'Mercado, restaurantes';

  @override
  String get insightDemoFun => 'Ocio';

  @override
  String get insightDemoFunSubtitle => 'Entretenimiento';

  @override
  String get insightDemoTransport => 'Transporte';

  @override
  String get insightDemoTransportSubtitle => 'Movilidad';

  @override
  String get paymentReminders => 'Recordatorios de pago';

  @override
  String get addPaymentReminder => 'Agregar recordatorio';

  @override
  String get editPaymentReminder => 'Editar recordatorio';

  @override
  String get paymentRemindersEmpty =>
      'Crea recordatorios para tus facturas y pagos. Puedes configurarlos para que se repitan cada mes.';

  @override
  String get paymentReminderName => 'Nombre del pago';

  @override
  String get paymentReminderNameHint => 'Ej. Arriendo, Netflix, Tarjeta';

  @override
  String get paymentReminderNameRequired =>
      'Escribe un nombre de al menos 2 caracteres';

  @override
  String get paymentReminderAmount => 'Monto (opcional)';

  @override
  String get paymentReminderAmountHint => '500000';

  @override
  String get paymentReminderTime => 'Hora';

  @override
  String get paymentReminderDayOfMonth => 'Día del mes';

  @override
  String paymentReminderDayOption(int day) {
    return 'Día $day';
  }

  @override
  String get paymentReminderDate => 'Fecha del pago';

  @override
  String get paymentReminderRepeatMonthly => 'Repetir mensualmente';

  @override
  String get paymentReminderRepeatMonthlyHint =>
      'Recibe aviso el mismo día cada mes';

  @override
  String get paymentReminderEnabled => 'Recordatorio activo';

  @override
  String paymentReminderScheduleMonthly(int day, String time) {
    return 'Día $day a las $time · Mensual';
  }

  @override
  String paymentReminderScheduleOnce(String date, String time) {
    return '$date a las $time · Una vez';
  }

  @override
  String paymentReminderBody(String amount) {
    return 'Pago pendiente: $amount';
  }

  @override
  String get paymentReminderBodySimple => 'Recordatorio de pago';

  @override
  String get deletePaymentReminderTitle => '¿Eliminar recordatorio?';

  @override
  String deletePaymentReminderMessage(String title) {
    return '¿Eliminar \"$title\"?';
  }

  @override
  String get notificationPermissionDenied =>
      'Activa las notificaciones en ajustes para recibir recordatorios de pago';
}
