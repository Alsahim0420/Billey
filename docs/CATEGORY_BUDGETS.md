# Presupuestos por categoría

Perfil → Límites de presupuesto abre los presupuestos mensuales. Cada mes tiene
sus propios montos. Selecciona el mes, toca una categoría y guarda un límite
positivo. Puedes cambiarlo o quitarlo; esto no cambia tus movimientos. Copiar mes
anterior añade únicamente límites ausentes, sin sobrescribir los del mes actual.
La copia usa una transacción de Firestore para conservar cambios concurrentes.

Los límites se sincronizan en tiempo real bajo:

`users/{uid}/categoryBudgets/{YYYY-MM}_{ISO}_{categoryId}`

Campos: `userId`, `month`, `categoryId`, `categoryName`, `currency`, `limit`,
`updatedAt` (timestamp del servidor). No hay jobs mensuales, montos de ejemplo
creados en producción ni Functions nuevas: cambiar de mes selecciona documentos
independientes. La colección se crea automáticamente al guardar el primer límite.

Las reglas solo permiten acceso a la cuenta propietaria, incluida lectura; el
permiso de pareja del documento padre no se hereda. Validan moneda, mes, monto,
campos permitidos e identidad del documento. El despliegue se limita a Firestore:

```sh
npx --yes firebase-tools@15.34.1 deploy --only firestore:rules --project billey-64a3b --non-interactive
```

El CLI `firebase` standalone instalado en este Mac falla al arrancar; se usó el
CLI oficial de npm. No hace falta modificar datos manualmente en la consola.
Las reglas se desplegaron correctamente el 22 de octubre de 2026 en
`billey-64a3b`, con ruleset `d6b81093-b5a4-456f-810d-1d18f7e371fe`.
El analizador y las pruebas locales no sustituyen comprobar sincronización entre
dos instalaciones con la misma cuenta y una sesión real.

## Cálculo

Se suman solo gastos propios del mes, por identificador de categoría y moneda.
Los ingresos y los movimientos de la pareja se excluyen. El total superior de
consumo corresponde a categorías que tienen un presupuesto configurado.
Los límites no impiden registrar gastos: muestran disponible o exceso.

Los movimientos nuevos guardan `categoryId` y `currencyCode`. Los adaptadores Hive
se regeneraron agregando campos 7 y 8 sin cambiar los existentes. Los movimientos
anteriores sin identificador usan su categoría enum; las categorías personalizadas
antiguas se habían reducido a `other` y no es posible reconstruirlas con certeza.
Se pueden recategorizar desde el detalle. Los movimientos antiguos sin moneda
se cuentan en la moneda seleccionada, igual que el modelo monetario anterior.
No se hacen conversiones. Los presupuestos se separan por código ISO.

Las categorías siguen siendo locales en Billey. El presupuesto conserva el nombre
para poder mostrar una categoría personalizada cuyo catálogo no exista en otro
dispositivo; su ID permite sumar los gastos sincronizados correctamente.

Al cambiar de cuenta, el provider cancela la suscripción anterior y limpia datos.
Las operaciones capturan su propietario; una hoja abierta en una cuenta no puede
escribir en otra después de cambiar de sesión. Guardar espera confirmación de
Firestore; si no hay conexión puede quedar pendiente. Se muestra error cuando la
operación falla, sin afirmar que se haya sincronizado.

## Verificación

```sh
flutter analyze
flutter test test/unit/models/category_budget_test.dart test/unit/models/transaction_storage_test.dart test/unit/providers/budget_provider_test.dart
```

Pruebas de reglas con Java 17 y el emulador ya presente en este entorno:

```sh
java -jar ~/.cache/firebase/emulators/cloud-firestore-emulator-v1.19.8.jar \
  --host 127.0.0.1 --port 8787 --project_id demo-billey-budget --rules firestore.rules
# En otra terminal:
cd tool/firestore_budget_tests
npm ci
npm test
```

El proyecto `demo-billey-budget` es exclusivamente local. Las pruebas verifican
lectura/escritura propias, denegación a otras cuentas y parejas, límites inválidos,
monedas, meses y campos adicionales. No escriben presupuestos reales.

Verificado en este entorno: análisis sin incidencias, 17 pruebas Flutter de
modelo/provider/importación/edición y una prueba de la pantalla en tamaño iPhone
aprobadas; cinco pruebas de reglas aprobadas. La prueba de compatibilidad escribe
con el adaptador Hive anterior y reabre con el nuevo para comprobar los datos.
Las herramientas de pruebas JavaScript usan una versión corregida de gRPC;
`npm audit` no reportó vulnerabilidades tras instalarla.

La compilación `flutter build ios --release` también terminó correctamente.
La build está en `build/ios/iphoneos/Runner.app`; todavía debe instalarse para
ver la nueva pantalla en el teléfono. No se crearon presupuestos de ejemplo en
la base de datos de producción.

Referencias: [condiciones de reglas de Firebase](https://firebase.google.com/docs/firestore/security/rules-conditions),
[pruebas con emulador](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
y [despliegues parciales con el CLI](https://firebase.google.com/docs/cli#deploy_specific_services).

## Límites iniciales desde la plantilla

`AutomaticCategoryBudgets` calcula valores derivados, sin crear documentos ni sobrescribir ajustes manuales. `BudgetProvider.effectiveForMonth` mezcla esos valores con los límites explícitos de Firebase; ambos consumidores (dashboard y ajustes) usan este mismo resultado. Al eliminar un ajuste explícito vuelve el valor automático. La opción existente de distribución automática desactiva los valores derivados.

Base: ingresos propios de la moneda y mes consultados; si su suma no es positiva, ingresos del mes anterior. Sin base positiva no se generan importes. Los registros antiguos sin moneda conservan la interpretación en la moneda seleccionada. No existe un salario previsto configurable actualmente; los importes pueden variar conforme se registran ingresos.

Necesidades: food, transport, health, education, y categorías de las secciones Necesidades Básicas, Bienestar, Desarrollo Personal, Trabajo y Hogar. Las restantes se consideran gustos, salvo Inversiones (reservada). Ahorro, inversión, deudas, colchón y sobres personalizados sin correspondencia no se convierten en presupuesto de gasto. Cada grupo respeta exactamente su porcentaje; los grupos sin categorías quedan reservados.

Dentro de cada grupo, el 90 % sigue la proporción de gasto de los tres meses completos anteriores y el 10 % se reparte por igual. Sin historial todo se reparte por igual. Redondeo a pesos COP o centavos en las demás monedas; el residuo se asigna de forma determinista a la última categoría. Un ajuste manual puede exceder la distribución original: se respeta la decisión del usuario.

Los valores automáticos son calculados desde los datos disponibles; solamente los ajustes manuales se guardan en categoryBudgets. La plantilla continúa usando el almacenamiento local existente y no se afirma sincronización de la plantilla entre dispositivos.
