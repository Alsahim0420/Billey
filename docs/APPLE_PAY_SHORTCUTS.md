# Apple Pay → Atajos → Billey

## Arquitectura y alcance

Revisión del repositorio: no se encontraron archivos AGENTS.md. La app usa
Provider; `main.dart` crea `TransactionProvider.cloud()`. Los gastos actuales se
guardan en `users/{uid}/transactions` mediante `FirestoreTransactionService`.
`DatabaseHelper` es una alternativa Hive local, no el almacenamiento del flujo
actual. Categorías y preferencias son locales y están separadas por usuario.
El formulario `AddTransactionScreen` crea `TransactionModel`; para sugerir la
categoría de gastos por voz usa `ExpenseVoiceParser`, con fallback `other`.
La importación reutiliza esas categorías, modelo, provider y servicio. Como en
el formulario, las categorías personalizadas se reducen a `TransactionCategory`
al persistir. No se cambia el esquema de Hive ni se escribe Hive desde Swift.

No se usa FinanceKit, PassKit para leer compras, integración bancaria, extensión
de Wallet ni backend nuevo. Se reutiliza el Firestore que ya usa Billey. La
recepción es local y no requiere red; la importación al almacenamiento actual
necesita la sesión correspondiente y conexión, porque usa una transacción de
Firestore. Se reintenta al abrir/reanudar la app o desde ajustes.

### Recibir no equivale a importar

1. `RegisterWalletExpenseIntent`, disponible desde iOS 16, recibe parámetros
   simples y valida antes de aceptar. La automatización Transacción exige iOS 17+.
2. `ApplePayInbox` guarda en Application Support/ApplePayInbox/inbox.json.
   Es independiente de Flutter. Usa `flock`, escritura atómica y `fsync` antes de
   responder. El bloqueo cubre lectura, modificación y escritura, incluso entre
   procesos. Una lectura corrupta falla sin sustituir la bandeja por una vacía.
3. El directorio y archivo usan Data Protection
   `completeUntilFirstUserAuthentication`; se excluyen de las copias de seguridad.
   No hay datos en logs ni almacenamiento de PAN/CVV. El alias es texto opcional:
   el usuario no debe enviar números completos. No hay App Group: la acción
   pertenece al target Runner y se ejecuta en su contenedor, sin extensión.
4. Dart consulta al arrancar la sesión, al reanudar, desde ajustes y mediante
   una notificación cuando el intent se ejecuta con el motor activo. El canal
   transporta lecturas y confirmaciones; nunca es la única copia de la entrada.
5. Se crea un gasto privado con ID `applepay_<uuid>`, origen
   `apple_pay_shortcuts` en Firestore y notas visibles `Apple Pay/Atajos`.
   Se usa la categorización existente sobre el comercio, conservando el monto y
   fecha originales: los números o palabras como «ayer» en el comercio no los
   modifican. Sin coincidencia se usa `other`.
6. `FirestoreTransactionService.importApplePay` escribe dentro de una transacción
   solo si no existe ese ID. Un reintento no sobrescribe un gasto editado.
   La ruta de usuario se captura y valida antes de escribir; un cambio de cuenta
   no redirige una escritura a la nueva cuenta. Las reglas existentes permiten
   esta operación, sin despliegue ni colecciones nuevas.
7. Solo tras confirmar el guardado se elimina la entrada pendiente y se conserva
   su referencia en el registro nativo de completados. Si falla la red o se
   cierra la app entre pasos, se vuelve a intentar con el mismo ID. No se deduplica
   por comercio, monto o ventana temporal.

La recepción se habilita explícitamente para una cuenta y una moneda en ajustes.
Cerrar sesión o cambiar de cuenta la deshabilita al sincronizar la sesión nativa.
Las entradas anteriores siguen vinculadas a su cuenta. Volver a esa cuenta permite
importarlas, aunque la recepción de nuevas entradas esté deshabilitada. La bandeja
admite hasta 500 pendientes; al llenarse rechaza nuevas recepciones con un error
explícito. El registro de referencias completadas se conserva hasta desinstalar
la app. Desinstalar elimina pendientes y protección contra reintentos anteriores.

### Límites de idempotencia

La referencia del evento es un UUID generado una vez por ejecución/pago en el
atajo. Debe conservarse para reintentos. Si se omite, Billey genera uno: repetir
manualmente la acción sin la referencia genera un gasto nuevo. Wallet no tiene
un identificador estable de pago documentado aquí, por lo que dos automatizaciones
distintas del mismo pago no se pueden deduplicar con seguridad. Una referencia
reutilizada para otra compra se considera un reintento: cada compra necesita otra.
El registro local no sobrevive a desinstalación ni se comparte entre dispositivos.
Si se elimina remotamente un gasto justo después del commit y antes de que se
confirme su recepción local, un reintento podría recrearlo: no se ofrece una
garantía global de exactly-once entre borrados remotos, dispositivos y reinstalación.

### Validación de datos

| Campo de Billey | Regla |
| --- | --- |
| Monto | Texto numérico positivo, máximo 1 billón, hasta 2 decimales. Acepta `12500.50`, `12500,50`, `12.500,50`, `12,500.50` y el texto formateado que entrega Wallet (`$ 18.900`, `COP 18.900`, `US$12.50`): se quitan símbolo/código de moneda al inicio o al final. Como ninguna moneda admitida usa 3 decimales, un separador seguido de exactamente 3 dígitos es de miles (`18.900` = 18900). Rechaza cero, negativos, exponentes y agrupaciones inválidas (`1,23,4`, `1.234,567`). |
| Moneda ISO | Obligatoria: COP, USD, EUR, MXN o BRL. Normaliza mayúsculas; `$` no permite inferir moneda. Debe coincidir con la moneda configurada para recepción. |
| Comercio | Opcional, máximo 200 caracteres. Ausente: título explícito «Compra con Apple Pay». |
| Fecha de compra | Opcional. Ausente: hora de recepción del dispositivo, identificada como tal en las notas. Fechas negativas o más de 5 minutos futuras se rechazan. |
| Alias de tarjeta | Opcional, máximo 80 caracteres; solo alias. No es un número de tarjeta ni prueba de identidad. |
| Referencia del evento | UUID opcional. Conservar para reintentos, generar otro para cada compra. |
| Es una prueba | Predeterminado falso. Una prueba nunca se convierte en `TransactionModel`, no cambia el saldo ni «Último gasto recibido». |

No hay valor inventado para monto o moneda. Si falta un parámetro obligatorio,
Atajos puede pedirlo; configura un bloque «Si» para detenerse cuando falte el
monto y evitar preguntas mientras el dispositivo está bloqueado. Los valores
inválidos devuelven un error de la acción, sin registrar un gasto incompleto.

El modelo actual no tiene moneda por transacción: se guarda el código original
en notas y no se realiza conversión. Dart también exige que coincida con la moneda
seleccionada en Billey al importar. Un pendiente en otra moneda permanece en la
bandeja y muestra la instrucción de seleccionar esa moneda. Cambiar globalmente
la moneda en Billey sigue teniendo las limitaciones existentes de la app; esta
integración no implementa contabilidad multimoneda.

## Fuentes de Apple y qué está realmente comprobado

Consulta realizada el 22 de octubre de 2026:

- [Transaction triggers](https://support.apple.com/en-bh/guide/shortcuts/apd65c67538a/ios):
  confirma el disparador al acercar la tarjeta seleccionada. La guía ofrece
  versiones iOS 17, 18, 26 y 27. No publica un contrato de campos, identificador
  estable de compra, formato numérico o moneda de la entrada.
- [Novedades de Atajos en iOS 17](https://support.apple.com/en-au/111098):
  documenta la incorporación de automatizaciones de transacción en iOS 17.
  Apple también menciona watchOS; eso no constituye una prueba de que esta
  implementación reciba pagos de un Apple Watch, y no se ofrece esa garantía.
- [Variables y propiedades](https://support.apple.com/guide/shortcuts/adjust-variables-apda36b9018b/ios):
  el editor permite inspeccionar y ajustar variables. Esto no garantiza que una
  propiedad particular de Wallet esté disponible para una tarjeta determinada.
- [authenticationPolicy](https://developer.apple.com/documentation/appintents/appintent/authenticationpolicy):
  `.alwaysAllowed` permite ejecutar sin autenticación, incluso bloqueado. La
  acción lo declara y `openAppWhenRun = false`. Esto no obliga al sistema a lanzar
  la automatización ni elimina permisos de Atajos o restricciones de ejecución.
- [Firma desde Terminal](https://support.apple.com/guide/shortcuts-mac/run-shortcuts-from-the-command-line-apd455c82f02/mac):
  Apple documenta firmar un atajo previamente exportado, con validación por Apple.

**No hubo compra real ni entrada Wallet disponible en este entorno.** No se ha
comprobado qué campos entrega una tarjeta concreta. Los parámetros son el contrato
de la acción Billey, no una afirmación sobre el contrato de Wallet. Comercio,
importe, tarjeta, moneda y fecha deben inspeccionarse en un iPhone. No se debe
convertir la transacción completa a JSON/diccionario suponiendo claves internas.
No se garantiza captura de todas las compras, historial, pagos web/in-app ni Watch.

## Configuración del usuario final

1. Instalar/abrir Billey, iniciar sesión, seleccionar su moneda y abrir Perfil →
   **Registrar compras con Apple Pay**. Permitir recepción para esa cuenta.
2. Opcional: **Probar recepción (sin crear gasto)**. Valida el puente nativo y
   persistencia; no valida Wallet ni la automatización.
3. Abrir Atajos → Automatización → + → Transacción (iOS 17/18); si la versión
   posterior lo presenta como Wallet/Cartera, elegir ese disparador. Seleccionar
   las tarjetas deseadas y **Ejecutar inmediatamente**. Las etiquetas pueden
   cambiar según idioma y versión; en versiones anteriores a iOS 17 no se ofrece
   esta automatización. El SDK actual de Flutter eleva el mínimo de la app a iOS
   15; la pantalla explica que la automatización sigue requiriendo iOS 17+.
4. Crear una automatización en blanco. Añadir **Registrar gasto en Billey** o
   **Ejecutar atajo** con el atajo intermediario descrito abajo. En este último
   caso pasar la transacción como Entrada del atajo.
5. Para cada campo, seleccionar la variable **Entrada del atajo**, tocarla otra
   vez e inspeccionar las propiedades de la transacción real. Si aparece
   Importe/Monto, seleccionarlo y convertir a texto numérico sin agrupación, con
   hasta dos decimales. No enviar el objeto completo como monto.
6. Si existe moneda en la propiedad de importe, usar el código ISO, tras verificar
   una compra. Si no existe, configurar explícitamente el código de esa tarjeta
   como constante y restringir la automatización a tarjetas de esa moneda. No
   asumir que coincide con la región del iPhone o con la moneda de Billey.
7. Mapear Comercio y Tarjeta/Pase solo si existen y producen texto válido. Usar
   únicamente un alias de tarjeta. Omitir Fecha si no se ofrece una fecha de compra.
8. Guardar. Hacer una compra presencial real y revisar monto, moneda, comercio,
   fecha y notas en Billey. El botón de reproducción no demuestra que Wallet
   entregue datos: puede no tener entrada de transacción.

## Especificación del atajo compartible (pendiente de validación Wallet)

No se entrega un `.shortcut` instalable ni enlace iCloud: no existe todavía un
archivo exportado desde Atajos con esta acción instalada y probado con una
transacción real. No hay claves privadas de Workflow inventadas ni JSON presentado
como atajo firmado. La acción directa evita necesitar el atajo intermediario.

Nombre propuesto: **Billey · Recibir compra Apple Pay**.

Construirlo en un iPhone con la build instalada:

1. Crear un atajo vacío con ese nombre. Recibir la transacción desde **Ejecutar
   atajo** en la automatización (no una cadena con comas).
2. Conservar **Entrada del atajo** en una variable `Transaccion` antes de extraer
   campos, evitando que la salida anterior sustituya la entrada.
3. Inspeccionar la entrada. Si ofrece Importe/Monto, extraerlo de `Transaccion`
   y guardar como `MontoWallet`. No asumir que admite conversión a diccionario.
4. Comprobar «Si MontoWallet no tiene ningún valor» → mostrar un aviso de que no
   se recibió monto y detener el atajo. Nunca convertir ausencia a cero. Si la
   conversión numérica falla, detenerse; corregir después con el formulario normal.
5. Convertir `MontoWallet` a número y formatear sin separador de miles, con dos
   decimales. Mantener el texto resultante en `MontoTexto`. Verificar que no
   arrastra símbolos/códigos. Billey admite coma o punto decimal. Si la propiedad
   es un objeto «importe con moneda», inspeccionar sus subpropiedades en el
   dispositivo; no dar por conocido su esquema.
6. Extraer por separado Comercio y Tarjeta/Pase de `Transaccion` **solo si las
   propiedades aparecen y funcionan en la compra real**. Dejarlas vacías si no.
   Para moneda usar propiedad ISO verificada o pregunta de configuración con
   constante explícita. No mapear Name/Nombre automáticamente como moneda/fecha.
7. Generar un UUID una vez y guardarlo en `ReferenciaEvento`. Cualquier rama que
   reintente la acción debe usar esa misma variable. No ejecutar de nuevo todo el
   atajo para reintentar conservando identidad: generaría otro UUID. Si se necesita
   reintento entre ejecuciones, conservar primero el UUID y los campos en un
   registro local del atajo; no deducirlo de monto/comercio/hora aproximada.
8. Llamar **Registrar gasto en Billey** con `MontoTexto`, moneda explícita,
   comercio/alias opcionales y `ReferenciaEvento`. Fecha vacía salvo que exista
   una fecha de compra verificada. «Es una prueba» desactivado para producción.
9. Conservar/mostrar el resultado solo si se desea diagnosticar. No añadir una
   acción que abra Billey: la bandeja no lo requiere.

### Paso manual para firmar y publicar

Después de completar la matriz de prueba real de abajo:

1. En Atajos del iPhone, compartir ese atajo → compartir como archivo/exportar
   (según versión) y guardar `Billey Apple Pay.shortcut`, o sincronizarlo a Atajos
   en Mac y exportarlo allí. Quitar datos personales de prueba.
2. En un Mac con Atajos:

   ```sh
   shortcuts sign --mode anyone --input "Billey Apple Pay.shortcut" --output "Billey Apple Pay firmado.shortcut"
   ```

   La herramienta envía el atajo a Apple para validación. Importar el archivo
   firmado en un segundo iPhone y comprobar que resuelve la acción Billey y sus
   parámetros. La firma no demuestra que la extracción Wallet sea correcta.
3. Alternativamente, en la hoja de compartir de Atajos usar **Copiar enlace de
   iCloud**. Abrir el enlace en otro dispositivo y verificar que instala el atajo
   esperado. Solo entonces añadir ese enlace real a la pantalla de Billey.
4. Compartir el atajo no crea ni activa la automatización personal: cada usuario
   debe seleccionar tarjetas, pasar la entrada y activar Ejecutar inmediatamente.

## Verificación reproducible

### Pruebas del repositorio

Resultado en este entorno: las 5 pruebas nuevas de Dart pasaron; las pruebas
nativas Swift pasaron. `flutter analyze` terminó sin incidencias. El conjunto
de 18 pruebas de importación/modelo Firestore/provider pasó completo. La suite
general terminó con 97 aprobadas y los mismos 22 fallos observados antes de
esta integración (providers ausentes en pruebas de widgets y expectativas de
iconos de categorías). No se presenta la suite general como aprobada.
La build `flutter build ios --simulator --debug
--no-codesign` terminó correctamente con Xcode 27.0. Se inspeccionó
`Runner.app/Metadata.appintents/extract.actionsdata`: la acción es descubrible,
su título es «Registrar gasto en Billey», `openAppWhenRun` es falso y monto/moneda
son obligatorios; comercio/fecha/alias/referencia son opcionales. Esto comprueba
la publicación de metadatos de la app, no el contenido real de una transacción
Wallet. La build se instaló y lanzó en un simulador iPhone 18 Pro / iOS 27.
Tras migrar UIScene se comprobó visualmente que completa la pantalla de carga
y llega al inicio de sesión. No se inició sesión con credenciales reales ni se
registró un gasto real en Firestore durante esta comprobación.

Flutter 3.47.4 actualizó automáticamente el proyecto iOS al mínimo 15.0 e incorporó
Swift Package Manager para los plugins. Se conservan los cambios de proyecto,
esquema, Podfile y archivos de resolución producidos por la compilación exitosa.
La integración CocoaPods restante contiene el framework Flutter. No se modificó
el proyecto Android.

El primer intento de arranque detectó un cierre del sistema por no adoptar
`UIScene` (símbolo de diagnóstico
`UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption`). Se migró el
registro de plugins y del canal a `FlutterImplicitEngineDelegate` y se añadió
el manifiesto de escenas con `FlutterSceneDelegate`, siguiendo la
[migración oficial de Flutter](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate).
Es necesaria para arrancar con Xcode 27/iOS 27 y no modifica Android.

```sh
flutter analyze
flutter test test/unit/features/apple_pay --reporter expanded
swiftc -module-cache-path /tmp/billey-swift-module-cache \
  ios/Runner/ApplePayInbox.swift ios/ApplePayTests/main.swift \
  -o /tmp/billey-inbox-tests
/tmp/billey-inbox-tests
flutter build ios --simulator --debug --no-codesign
```

Las pruebas Swift ejercitan el mismo código de persistencia usado en iOS, en un
directorio temporal de macOS: formatos de monto, errores, reapertura, reintentos,
confirmación, 40 escrituras concurrentes, separación de cuentas y archivo corrupto.
No comprueban Data Protection de iOS. Las Dart prueban validación, categoría,
origen, moneda incompatible, sesiones, pruebas sin saldo y fallo antes del ack.
La prueba de idempotencia de Dart usa un almacenamiento simulado; no sustituye
una prueba de Firestore con sesión real.

### Matriz de compra real — PENDIENTE, no ejecutada en este entorno

Anotar modelo de iPhone, versión/build de iOS, idioma, tarjeta/emisor (solo alias),
moneda, build Billey y propiedades reales que aparecen en la variable Transacción.
No guardar números completos ni capturas con datos sensibles en el repositorio.

| Estado | Procedimiento | Resultado que se debe comprobar | Estado |
| --- | --- | --- | --- |
| App abierta | Compra real con la automatización guardada; volver a la pantalla de ajustes si Apple Pay tomó el foco | Recepción y un gasto correcto; saldo, moneda, categoría, origen y fecha | Pendiente |
| Segundo plano | Enviar Billey al fondo, comprar y abrir Billey | Entrada conservada e importada una sola vez | Pendiente |
| App cerrada | Cerrar Billey desde el selector, comprar, luego abrirla | Intent descubierto, error claro si iOS impide ejecución; si se recibió, persistencia e importación única | Pendiente |
| Bloqueado tras primer desbloqueo | Reiniciar, desbloquear una vez, volver a bloquear y realizar pago compatible | Si Atajos se ejecuta, recepción sin abrir Billey; importación al desbloquear/abrir | Pendiente |
| Reiniciado sin primer desbloqueo | Intentar ejecutar una prueba sin haber desbloqueado | No prometer ejecución: almacenamiento protegido puede impedirla; sin registros parciales | Pendiente |
| Sin red | Comprar con Billey cerrada o al fondo y abrirla sin conexión; recuperar red y pulsar revisar pendientes | Pendiente visible, después un solo gasto | Pendiente |
| Reintento | Repetir acción con mismo UUID y luego con otro UUID, mismo comercio/monto | Uno para el mismo UUID; dos para compras con UUID distintos | Pendiente |
| Datos ausentes | Probar monto vacío/0, moneda vacía/$ y formatos ambiguos | Error visible o detención previa del atajo; ningún gasto incompleto | Pendiente |
| Cuenta distinta | Recibir en A, cerrar sesión y entrar en B, luego volver a A | B no ve ni importa entradas de A; recepción deshabilitada; A puede importar pendientes | Pendiente |
| Cierre durante importación | Recibir, abrir sin red, recuperar red y cerrar durante el intento; reabrir | Referencia estable; sin sobreescribir movimientos editados por reintento | Pendiente |

`alwaysAllowed` y la protección elegida permiten intentar recibir bloqueado tras
el primer desbloqueo, pero no garantizan lanzamiento, permisos, disponibilidad
de datos ni ejecución tras un cierre forzado. Atajos puede solicitar permisos en
su primera ejecución. Completar esa primera ejecución desbloqueado. No se afirma
que esto capture pagos por internet, historial, todas las tarjetas o Apple Watch.
