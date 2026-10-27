
## Totales mensuales de Inicio

Las tarjetas de Inicio utilizan `getMonthlyIncome`, `getMonthlyExpenses` y su diferencia para el mes actual según el calendario local del dispositivo. No trasladan ingresos, gastos ni sobrantes del mes anterior. Los métodos de totales históricos siguen disponibles para consultas históricas, y los registros de Firebase no se borran ni se modifican.

`MonthlyPeriodBuilder` comprueba el calendario a medianoche y al regresar la app a primer plano. Renueva el periodo sin recrear la pantalla ni perder su estado. La etiqueta del saldo incluye el mes y año. Recientes y Actividad conservan su historial; el periodo mensual se aplica a los totales del Home.
