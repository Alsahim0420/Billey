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
  String get homeChartTrend => 'Tendencia';

  @override
  String get homeChartByCategory => 'Por categoría';

  @override
  String get homeChartByPerson => 'Personas';

  @override
  String get expensesByPerson => 'Gastos por persona';

  @override
  String get youLabel => 'Tú';

  @override
  String get noExpensesInPeriod => 'No hay gastos en este período';

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
  String get listening => 'ESCUCHANDO... TERMINARÉ CUANDO DEJES DE HABLAR';

  @override
  String get voiceTranscribing => 'TRANSCRIBIENDO...';

  @override
  String get voicePlaying => 'REPRODUCIENDO...';

  @override
  String get voiceListenConfirmation => 'ESCUCHAR CONFIRMACIÓN';

  @override
  String get voiceConfirmationPrefix => 'Entendí esto:';

  @override
  String get newTransactionByVoice => 'Nueva transacción';

  @override
  String get voiceTransactionPrompt =>
      'Cuéntame qué pasó. Identificaré si es un gasto o un ingreso y completaré los datos por ti.';

  @override
  String get voiceTransactionTypeNotUnderstood =>
      'No pude identificar si fue un gasto o un ingreso. Prueba diciendo “gasté”, “compré”, “me pagaron” o “me consignaron”.';

  @override
  String get manualEntryDividerLabel => 'o llénalo tú mismo';

  @override
  String get manualEntryExpenseButton => 'Gasto';

  @override
  String get manualEntryIncomeButton => 'Ingreso';

  @override
  String get salaryQuestionTitle => '¿Cuál es tu sueldo habitual?';

  @override
  String get salaryQuestionMessage =>
      'Lo guardaré de forma segura en tu perfil para entender futuros ingresos, descuentos o pagos adicionales.';

  @override
  String get salaryAmountHint => 'Ej. 3.000.000';

  @override
  String get salarySaveError =>
      'No pude consultar o guardar tu sueldo. Revisa tu conexión e inténtalo nuevamente.';

  @override
  String get salaryVoiceQuestion =>
      'Todavía no conozco tu sueldo habitual. ¿Cuánto recibes normalmente?';

  @override
  String get salaryVoiceListeningPrompt =>
      'Dime por voz cuánto recibes normalmente';

  @override
  String get salaryVoiceNotUnderstood =>
      'No entendí el valor de tu sueldo. Intenta decir, por ejemplo, tres millones de pesos.';

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
  String get transactionDeleteError => 'No se pudo eliminar la transacción.';

  @override
  String get transactionDeletedUndo => 'Transacción eliminada';

  @override
  String get undo => 'Deshacer';

  @override
  String get transactionSaveError =>
      'No se pudo guardar la transacción. Intenta de nuevo.';

  @override
  String get goalSaveError => 'No se pudo guardar la meta. Intenta de nuevo.';

  @override
  String get goalDeleteError => 'No se pudo eliminar la meta.';

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
  String versionInfo(String version, String build) {
    return 'Versión $version ($build)';
  }

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
  String get updateFromGoogle => 'Actualizar con foto de Google';

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get photoUpdated => 'Foto de perfil actualizada';

  @override
  String get photoRemoved => 'Foto de perfil eliminada';

  @override
  String get photoUpdateError =>
      'No se pudo subir la foto. Revisa tu conexión e intenta de nuevo.';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get dataStoredLocally =>
      'Tu nombre se sincroniza con tu cuenta. El correo es el de tu inicio de sesión y no se puede editar aquí.';

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
  String get logOutError => 'No se pudo cerrar la sesión. Intenta de nuevo.';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirmTitle => '¿Eliminar tu cuenta?';

  @override
  String get deleteAccountConfirmMessage =>
      'Esta acción eliminará tu perfil y tus datos de Billey de forma permanente. No podrás deshacerla una vez enviada la solicitud.';

  @override
  String get deleteAccountConfirmButton => 'Eliminar cuenta';

  @override
  String get deleteAccountRequestTitle => 'Solicitud enviada';

  @override
  String get deleteAccountRequestMessage =>
      'Recibimos tu solicitud de eliminación de cuenta. Nuestro equipo la revisará y te informaremos por correo, en un plazo máximo de 15 días, si el proceso se completó con éxito.';

  @override
  String get deleteAccountRequestButton => 'Entendido';

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
  String get categoryAutoSuggested => 'Icono y color sugeridos según el nombre';

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
  String get aiSuggestGoalsTooltip => 'Sugerir metas con IA';

  @override
  String get aiGoalSuggestionsTitle => 'Sugerencias para ti';

  @override
  String aiGoalSuggestionsSubtitle(String plan, String ratio) {
    return 'Según tu plan $plan ($ratio), esto es lo que te sugerimos ahorrar';
  }

  @override
  String get aiSuggestedEmergencyFund => 'Fondo de emergencia';

  @override
  String get aiSuggestedDebtPayoff => 'Pago de deudas';

  @override
  String get aiSuggestedInvestmentFund => 'Fondo de inversión';

  @override
  String get aiSuggestedIncomeBuffer => 'Colchón de ingresos';

  @override
  String aiSuggestionMonthlyHint(String amount) {
    return '~$amount/mes según tu plan';
  }

  @override
  String get aiAddSelectedGoals => 'Agregar seleccionadas';

  @override
  String get aiNoNewSuggestions =>
      'Ya tienes una meta para todo lo que sugiere tu plan actual.';

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
  String get txnCategoryOther => 'Sin categorizar';

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

  @override
  String get coupleFinanceTitle => 'Finanzas compartidas';

  @override
  String get coupleIntro =>
      'Vincula tu cuenta con tu pareja para decidir, transacción por transacción, qué gastos e ingresos quieren verse mutuamente.';

  @override
  String get coupleMyCodeLabel => 'Tu código';

  @override
  String get coupleMyCodeHint =>
      'Compártelo con tu pareja. Se renueva solo cada 5 minutos.';

  @override
  String coupleCodeExpiresIn(int seconds) {
    return 'Expira en ${seconds}s';
  }

  @override
  String get coupleEnterPartnerCode => '¿Tienes el código de tu pareja?';

  @override
  String get coupleEnterCodeHint => 'Código de 6 dígitos';

  @override
  String get coupleLinkButton => 'Vincular';

  @override
  String coupleLinkedWith(String name) {
    return 'Vinculado con $name';
  }

  @override
  String get coupleLinkedSubtitle =>
      'Ya pueden compartir transacciones entre ustedes desde cada registro.';

  @override
  String get coupleLinkedSuccess => '¡Vinculación exitosa!';

  @override
  String get coupleInvalidCode => 'Ese código no es válido o ya expiró.';

  @override
  String get coupleGenericError => 'Algo salió mal. Intenta de nuevo.';

  @override
  String get coupleUnlink => 'Desvincular';

  @override
  String get coupleUnlinkTitle => '¿Desvincular finanzas compartidas?';

  @override
  String get coupleUnlinkMessage =>
      'Dejarán de ver las transacciones que se compartían mutuamente.';

  @override
  String get coupleUnlinked => 'Desvinculado correctamente';

  @override
  String shareWithPartner(String name) {
    return 'Compartir con $name';
  }

  @override
  String get shareWithPartnerHint => 'Tu pareja podrá ver esta transacción';

  @override
  String get shareGoalWithPartnerHint => 'Tu pareja podrá ver esta meta';

  @override
  String coupleSharedCountZero(String name) {
    return 'Aún no compartes ninguna transacción con $name';
  }

  @override
  String coupleSharedCountOne(String name) {
    return 'Estás compartiendo 1 transacción con $name';
  }

  @override
  String coupleSharedCountMany(int count, String name) {
    return 'Estás compartiendo $count transacciones con $name';
  }

  @override
  String get assistantVoice => 'Voz del asistente';

  @override
  String get assistantVoiceDescription =>
      'Elige la voz para las confirmaciones habladas';

  @override
  String get assistantFemaleVoice => 'Femenina cálida';

  @override
  String get assistantMaleVoice => 'Masculina cálida';

  @override
  String get assistantVoicePreview => 'Escuchar';

  @override
  String assistantVoicePreviewMessage(String name) {
    return 'Hola, $name. Te acompañaré a registrar tus gastos y confirmar que todo esté correcto en Billey.';
  }

  @override
  String get applePayTitle => 'Registrar compras con Apple Pay';

  @override
  String get applePayScope =>
      'Recibe los datos que una automatización personal de Wallet envíe a Billey. Se guardan en una bandeja local incluso sin abrir la app y se importan cuando Billey está abierta y tiene conexión. No incluye historial ni garantiza todas las compras, pagos por internet o desde Apple Watch.';

  @override
  String get applePayRequiresIOS17 =>
      'La automatización de Transacción requiere iOS 17 o posterior. Esta función no está disponible en este dispositivo.';

  @override
  String get applePayAllowReceipt => 'Permitir recepción para esta cuenta';

  @override
  String applePayReceiptConsent(String currency) {
    return 'Guarda los próximos gastos en esta cuenta, en $currency. Esto no crea ni activa una automatización en Atajos. Al cambiar de cuenta se deshabilita la recepción.';
  }

  @override
  String get applePayAutomationStatus =>
      'Billey no puede comprobar si tu automatización está creada o activada.';

  @override
  String applePayConfiguredCurrency(String currency) {
    return 'Moneda configurada para recepción: $currency';
  }

  @override
  String applePayUseCurrency(String currency) {
    return 'Usar $currency para próximas recepciones';
  }

  @override
  String applePayLastReceipt(String date) {
    return 'Último gasto recibido: $date';
  }

  @override
  String get applePayNone => 'Ninguno';

  @override
  String applePayPending(int count) {
    return 'Pendientes de importar: $count';
  }

  @override
  String get applePayRetry => 'Revisar e importar pendientes';

  @override
  String get applePayTest => 'Probar recepción (sin crear gasto)';

  @override
  String get applePayTestExplanation =>
      'La prueba envía 12500.50 en la moneda seleccionada por la misma bandeja nativa. No modifica saldos ni la fecha del último gasto real. No prueba Wallet ni tu automatización.';

  @override
  String get applePaySetup => 'Configurar en Atajos';

  @override
  String get applePaySteps =>
      '1. Permite la recepción arriba.\n2. Abre Atajos → Automatización → +.\n3. En iOS 17/18 busca Transacción; en versiones posteriores puede aparecer como Wallet o Cartera. Selecciona las tarjetas que usarás.\n4. Selecciona Ejecutar inmediatamente.\n5. Crea una automatización en blanco y añade Registrar gasto en Billey. También puedes ejecutar tu atajo intermediario y pasar la transacción como Entrada del atajo.\n6. Configura los campos de entrada y guarda. Haz una compra real para comprobarla; el botón de reproducción puede no tener una transacción de Wallet.';

  @override
  String get applePayMapping =>
      'Monto: toca Entrada del atajo y comprueba qué propiedades ofrece la transacción en tu iPhone. Si hay Importe/Monto, selecciona ese valor y conviértelo a texto numérico sin símbolo (por ejemplo, 12500.50). Moneda ISO: usa el código real si está disponible; si no, configura explícitamente la moneda de esa tarjeta y valida una compra antes de automatizarla. No se deduce moneda a partir de \$. Comercio y alias de tarjeta son opcionales y solo deben mapearse si existen. La fecha es opcional: si falta, se marca como fecha de recepción. No se asume que Wallet entregue todos estos campos. Si falta el monto, detén el atajo y revisa el gasto manualmente. Para reintentos conserva un mismo UUID por compra en Referencia del evento; una compra nueva requiere otro UUID.';

  @override
  String get applePayLocked =>
      'Con el iPhone bloqueado se intenta recibir sin abrir la interfaz, después del primer desbloqueo tras reiniciar. iOS, Atajos y los permisos pueden impedir la ejecución. Los pendientes se importan al volver a Billey. No se usa FinanceKit ni conexión bancaria. Una moneda diferente se rechaza; no se convierten importes.';

  @override
  String get applePayShortcutAvailability =>
      'No hay un atajo publicado para instalar todavía. Puedes usar la acción directamente. La extracción de los campos debe validarse en un iPhone con Wallet antes de compartir un atajo.';

  @override
  String get applePayIntro =>
      'Conecta Atajos con Billey y lleva tus compras a tus gastos, sin anotarlas una por una.';

  @override
  String applePayAccountHint(String currency) {
    return 'Recibe las compras en esta cuenta y en $currency. Se importarán cuando abras Billey.';
  }

  @override
  String get applePayActivity => 'Tu actividad';

  @override
  String get applePayLastLabel => 'Último gasto recibido';

  @override
  String get applePayPendingLabel => 'Pendientes de importar';

  @override
  String get applePayTestShort => 'Probar recepción';

  @override
  String get applePayTestHint =>
      'Usa datos de ejemplo. No crea gastos ni cambia tu saldo.';

  @override
  String get applePayMoreDetails => 'Resuelve tus dudas';

  @override
  String get applePayMappingTitle => 'Qué datos enviar desde Atajos';

  @override
  String get applePayScopeTitle => 'Alcance y privacidad';

  @override
  String get applePayShortcutTitle => 'Sobre el atajo y las pruebas';

  @override
  String get applePayGuideSteps =>
      'Abre Atajos → Automatización → + → Transacción o Wallet y selecciona tus tarjetas.\nElige Ejecutar inmediatamente y crea una automatización en blanco.\nAñade Registrar gasto en Billey. Pasa el monto y el comercio disponibles; indica la moneda de tu tarjeta.\nGuarda y comprueba una compra real. Abre Billey para importar y revisar el gasto.';

  @override
  String get transactionDetailsTitle => 'Detalle de transacción';

  @override
  String get transactionDataTitle => 'Datos del movimiento';

  @override
  String get transactionNameLabel => 'Nombre';

  @override
  String get transactionAmountLabel => 'Monto';

  @override
  String get transactionNotesLabel => 'Notas y origen';

  @override
  String get transactionSharedReadOnly =>
      'Este movimiento fue compartido contigo. Solo su propietario puede editarlo.';

  @override
  String get monthlyBudgets => 'Presupuestos mensuales';

  @override
  String get budgetIntro =>
      'Define cuánto quieres gastar por categoría este mes. Tus límites se guardan en tu cuenta y se sincronizan con Firebase.';

  @override
  String get budgetPreviousMonth => 'Mes anterior';

  @override
  String get budgetNextMonth => 'Mes siguiente';

  @override
  String get budgetPlanned => 'Presupuesto del mes';

  @override
  String get budgetTrackedSpend => 'Gastado en categorías con presupuesto';

  @override
  String get budgetAvailable => 'Disponible';

  @override
  String get budgetExceeded => 'Excedido';

  @override
  String get budgetCopyPrevious => 'Copiar mes anterior';

  @override
  String get budgetCopyHint =>
      'Solo copia categorías que aún no tienen presupuesto en este mes.';

  @override
  String budgetCopied(int count) {
    return 'Se copiaron $count presupuestos. Si no había límites previos o ya estaban configurados, no se modificó nada.';
  }

  @override
  String get budgetNotSet => 'Sin presupuesto · Toca para configurar';

  @override
  String budgetSpentOf(String spent, String limit) {
    return '$spent gastado de $limit';
  }

  @override
  String budgetRemaining(String amount) {
    return 'Disponible: $amount';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Excediste el presupuesto en $amount';
  }

  @override
  String get budgetEditTitle => 'Presupuesto de la categoría';

  @override
  String get budgetInvalidAmount =>
      'Introduce un monto mayor que cero y de hasta 1 billón.';

  @override
  String get budgetRemove => 'Quitar ajuste manual de este mes';

  @override
  String get budgetSaveError =>
      'No se pudo guardar. Comprueba tu conexión y tu sesión e inténtalo de nuevo.';

  @override
  String get budgetLoadError =>
      'No se pudieron sincronizar los presupuestos. Puedes estar viendo datos guardados anteriormente.';

  @override
  String get budgetRetry => 'Reintentar sincronización';

  @override
  String get budgetSignIn => 'Inicia sesión para configurar tus presupuestos.';

  @override
  String get budgetLegacyHint =>
      'Solo se cuentan tus gastos, sin los de tu pareja ni ingresos. No se convierten monedas. Los movimientos antiguos sin moneda se cuentan en la moneda seleccionada; las categorías personalizadas antiguas guardadas como Otros requieren recategorización para distinguirlas. Cada mes tiene sus propios límites.';

  @override
  String get budgetChartLegend =>
      'Sólido: gastado · Línea: presupuesto · Solo tus gastos';

  @override
  String get budgetAutomaticHint =>
      'Los límites iniciales se calculan con tu plantilla y tus ingresos registrados del mes (o del mes anterior si aún no hay ingresos). Necesidades y gustos se reparten según los gastos de los últimos 3 meses, reservando un 10 % para repartir por igual; sin historial, se reparten por igual. Ahorro, inversión, deudas y colchón quedan reservados. Sin ingresos registrados no se inventan montos. Tus ajustes manuales tienen prioridad y se guardan en Firebase.';

  @override
  String get categoryReviewRequired =>
      'No se pudo identificar la categoría. Toca la categoría, elige la correcta y vuelve a guardar.';

  @override
  String get categoryAutomaticLabel => 'Categoría automática';

  @override
  String get categoryMigrationTitle => 'Clasificar gastos pendientes con IA';

  @override
  String get categoryMigrationHint =>
      'Procesa hasta 20 gastos sin categorizar de tu cuenta por vez. Gemini recibe sus títulos y tus categorías. Los gastos ambiguos quedan para revisión; no se modifican montos ni fechas.';

  @override
  String get categoryMigrationAction => 'Clasificar pendientes';

  @override
  String get categoryMigrationError =>
      'No se pudo completar. Comprueba la clave de Gemini, la conexión y tu sesión. Los cambios ya guardados se conservan; puedes volver a intentar.';

  @override
  String categoryMigrationReport(
      int updated, int unresolved, int skipped, int remaining) {
    return 'Clasificados: $updated. Por revisar: $unresolved. Omitidos por cambios recientes: $skipped. Sin procesar: $remaining.';
  }

  @override
  String get categoryReviewEmpty => 'No tienes gastos pendientes de categoría.';

  @override
  String categoryReviewCount(int count) {
    return '$count gastos por categorizar';
  }

  @override
  String get categoryReviewHint =>
      'Elige una categoría para cada gasto. Se guarda al seleccionarla y el gasto sale de esta lista.';

  @override
  String get categoryReviewSaveError =>
      'No se pudo guardar o el gasto cambió. Revisa tu conexión y vuelve a seleccionar la categoría.';

  @override
  String get homeRefreshPull => 'Desliza para actualizar';

  @override
  String get homeRefreshRelease => 'Suelta para actualizar';

  @override
  String get homeRefreshing => 'Actualizando tu información…';

  @override
  String get homeRefreshDone => 'Todo actualizado';

  @override
  String get homeRefreshFailed => 'No se pudo actualizar. Intenta de nuevo.';
}
