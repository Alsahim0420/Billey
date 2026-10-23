# Clasificación de gastos con Gemini

## Configuración local

1. Crea una clave en https://aistudio.google.com/api-keys usando un proyecto en nivel gratuito y sin facturación habilitada. Comprueba modelos y cuotas del proyecto en AI Studio: la aplicación no puede garantizar que una clave pertenezca al nivel gratuito ni evitar cobros si habilitas facturación fuera de la app.
2. El archivo `.env` ya existe, sin clave. Completa `GEMINI_API_KEY=...`; deja `GEMINI_MODEL=gemini-3.5-flash-lite`, modelo con entrada/salida gratuitas en la documentación consultada el 22/10/2026. `.env.example` contiene las variables de ejemplo. Nunca publiques la clave.
3. Ejecuta `bash tool/prepare_environment.sh`. Usa la misma clave de cifrado predeterminada que la app (o `ENV_ENCRYPTION_KEY` si se proporciona); mezcla `.env.local` (voz existente) y `.env` (Gemini, con prioridad). No imprime valores secretos.
4. Ejecuta `bash tool/run_with_environment.sh --release` o recompila usando la configuración ENV_ENCRYPTION_KEY que ya usa el proyecto.
5. Crea un gasto con un comercio reconocible sin elegir una categoría manualmente. Verifica la categoría en el detalle. Prueba otro concepto ambiguo: debe pedir una categoría en vez de guardarlo en Otros. Si seleccionas una categoría manualmente, no se llama a Gemini ni se modifica tu decisión.

La clave se configuró y se verificaron llamadas reales con títulos ficticios. No se envió ningún gasto del usuario durante las pruebas. La configuración continúa en el asset cifrado existente, sin añadir `.env` como asset. El cifrado no protege una clave distribuida en un binario: para producción Google recomienda un proxy que proteja la clave. Esta integración directa es apropiada para pruebas personales, no proporciona protección de credenciales de producción.

## Datos y tokens

Se envía únicamente el título completo y la lista de categorías activas del usuario sin `other` (hasta 100 categorías, con sus IDs y nombres completos). No se envían monto, descripción, fecha, identificadores de usuario, alias de tarjeta ni transacciones anteriores. Google indica que el contenido del nivel gratuito puede utilizarse para mejorar sus productos; hay que reflejar este tratamiento en la información de privacidad antes de distribuir la función a terceros.

El prompt de sistema trata nombres y concepto como datos no confiables, exige una categoría existente y permite abstenerse. El contrato de entrada es `{"title":"Uber","categories":[{"id":"transport","name":"Transporte"}]}`. La respuesta contiene una única clave: `{"categoryId":"transport"}`; la abstención es `{"categoryId":""}`. La salida JSON está restringida a los IDs del catálogo y se valida otra vez localmente. Temperatura 0, thinkingLevel MINIMAL (thinkingBudget 0 solo para modelos 2.5), máximo 64 tokens de salida, sin herramientas ni búsqueda. El consumo real de entrada depende del catálogo; no se garantiza un número fijo de tokens ni exactitud absoluta.

Caché de 128 resultados en memoria por concepto+catálogo, borrada al cambiar de sesión. No persiste información de compras adicionalmente. Sin reintentos automáticos; HTTP 429 pausa llamadas durante un minuto. Tiempo máximo 8 segundos por petición. Ante fallos, clave ausente o cuota agotada se usan las reglas locales existentes, solo si producen una categoría activa válida; en caso contrario se solicita revisión. No se crean categorías arbitrarias.

## Almacenamiento y compatibilidad

`TransactionProvider` categoriza antes de guardar gastos nuevos e importar Apple Pay. Conserva ID, importe, moneda, fecha, origen, propietario y campos de compartir. Las ediciones no vuelven a clasificar automáticamente. Los ingresos no se envían.

`other` permanece como valor histórico compatible con Hive/Firestore, pero se excluye de las categorías activas y del catálogo de IA. Los movimientos antiguos se muestran como «Sin categorizar» mediante la traducción del enum y pueden recategorizarse desde su detalle. No se reclasifican ni se eliminan datos históricos en masa. Los presupuestos automáticos no asignan dinero a ese ID.

Una entrada ambigua de Apple Pay no se confirma en la bandeja nativa hasta poder clasificarla y guardarla; permanece pendiente. Esta versión no incluye un editor de entradas nativas pendientes: verifica el concepto recibido y vuelve a importar una vez corregida la configuración o el catálogo. La categorización requiere que Flutter procese la bandeja; el Intent no realiza solicitudes de red.

## Referencias verificadas

- https://ai.google.dev/gemini-api/docs/pricing
- https://ai.google.dev/gemini-api/docs/rate-limits
- https://ai.google.dev/gemini-api/docs/structured-output
- https://ai.google.dev/gemini-api/docs/api-key

## Reclasificar los gastos existentes

En **Categorías → Clasificar gastos pendientes con IA → Clasificar pendientes**. Requiere clave configurada, configuración cifrada regenerada, app actualizada y sesión iniciada. Se implementó dentro de la app porque el catálogo personalizado vive en Hive en el dispositivo, no en Firebase: un script administrativo no tendría necesariamente las categorías del usuario.

Se consultan únicamente los documentos propios de `users/{uid}/transactions`, sin movimientos de la pareja. Solo son candidatos los gastos cuyo `effectiveCategoryId` es `other`: no se confunden categorías personalizadas con el enum de compatibilidad `other`. Se procesa un máximo de 20 por ejecución. El reporte distingue actualizados, ambiguos, omitidos por cambios concurrentes y sin procesar; puedes repetir para continuar. Si una tanda contiene muchos ambiguos, recategorízalos manualmente para avanzar a los restantes.

Se exige un resultado de IA válido: esta tarea no utiliza el fallback local. Cada gasto usa su título y las categorías activas actuales del dispositivo. Los ambiguos permanecen sin cambios. Las actualizaciones de Firebase usan una transacción por documento: vuelven a leer el título y categoría antes de escribir únicamente `category`, `categoryId` y `updatedAt`. No reescriben importes, fechas, moneda, origen, notas ni campos para compartir. Si el proceso se interrumpe, los cambios ya confirmados permanecen y la siguiente ejecución los omite. No hay una transacción global sobre toda la tanda.

No se ha ejecutado la migración de los datos reales. La clave y el modelo ya se validaron con una petición ficticia. Se verificaron selección de candidatos, aislamiento de propietario, requerimiento de IA, preservación de datos, límite de tanda y cancelación ante cambio de sesión mediante pruebas automatizadas. La escritura contra los datos reales y la calidad de clasificación requieren configurar la clave y ejecutar el botón en la app.


## Corrección verificada el 22/10/2026

La petición anterior fallaba con HTTP 400 porque el enum del esquema incluía una cadena vacía. El esquema ahora exige una propiedad string `categoryId`; la pertenencia al catálogo y la abstención vacía se validan localmente. Google también rechazó `gemini-2.5-flash-lite` para esta cuenta con HTTP 404, recomendando `gemini-3.5-flash-lite`. El modelo actualizado respondió HTTP 200 con `{"categoryId":"transport"}` para una compra ficticia de taxi. Se configura thinkingLevel MINIMAL, conservando thinkingBudget 0 si se selecciona explícitamente un modelo 2.5.

Prueba real opcional: `BILLEY_GEMINI_LIVE_TEST=1 flutter test test/integration/gemini_live_test.dart`. Usa el mismo asset cifrado y servicio Dart que la app. Envía un título ficticio; no guarda transacciones. Está desactivada en las pruebas normales.

### Revisión manual de todos los pendientes

La misma tarjeta de Categorías incluye ahora una fila por **cada** gasto propio sin categoría, sin el límite de 20 aplicado a las solicitudes de IA. Cada fila muestra título, importe con su moneda, fecha y selector con las categorías activas. Seleccionar una categoría la guarda inmediatamente en Firebase con la misma comprobación transaccional contra cambios concurrentes. Solo después del guardado se actualiza la lista y desaparece la fila; el contador refleja los pendientes actuales. No requiere llamadas a Gemini ni clave. Un error mantiene el gasto visible y permite reintentar. Tras un guardado manual se elimina el resumen anterior de IA para no mostrar un conteo desactualizado.

Verificación: prueba de interfaz con 17 gastos produce exactamente 17 selectores; asignar uno produce 16 selectores y preserva los otros gastos. Otra prueba simula un fallo de guardado y verifica que la fila y el aviso permanecen visibles.

### Interfaz actual

Se retiró el botón de clasificación masiva con IA de Categorías. La vista conserva únicamente la lista de pendientes con selección manual. La clasificación automática de gastos nuevos sigue funcionando; el proceso de migración permanece disponible internamente, sin botón en esta pantalla.
