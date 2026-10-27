import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/financial_cycle.dart';
import '../providers/financial_cycle_provider.dart';
import '../theme/colors/app_colors.dart';
import '../widgets/billey_back_button.dart';

class FinancialCycleScreen extends StatefulWidget {
  const FinancialCycleScreen({super.key});
  @override
  State<FinancialCycleScreen> createState() => _FinancialCycleScreenState();
}

class _FinancialCycleScreenState extends State<FinancialCycleScreen> {
  int? _day;
  bool _busy = false;
  String? _error;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinancialCycleProvider>();
    final en = Localizations.localeOf(context).languageCode == 'en';
    final day = _day ?? provider.cycle.startDay;
    final cycle = FinancialCycle(day);
    final period = cycle.containing(DateTime.now());
    final format =
        DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag());
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
          leading: const BilleyBackButton(),
          title: Text(en ? 'Your financial cycle' : 'Tu ciclo financiero')),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(padding: const EdgeInsets.all(24), children: [
                Text(
                    en
                        ? 'Plan from payday to payday'
                        : 'Organízate de pago a pago',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(
                    en
                        ? 'Choose when your monthly cycle starts and closes. Income, expenses and category budgets will follow these dates.'
                        : 'Elige cuándo empieza y termina tu ciclo mensual. Los ingresos, gastos y presupuestos por categoría seguirán estas fechas.',
                    style:
                        TextStyle(color: AppColors.textSecondary, height: 1.5)),
                const SizedBox(height: 28),
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderSubtle)),
                    child: Column(children: [
                      DropdownButtonFormField<int>(
                          initialValue: day,
                          key: ValueKey('start_$day'),
                          decoration: InputDecoration(
                              labelText: en ? 'Starts on' : 'Día de inicio'),
                          items: List.generate(
                              31,
                              (i) => DropdownMenuItem(
                                  value: i + 1, child: Text('${i + 1}'))),
                          onChanged:
                              _busy ? null : (v) => setState(() => _day = v)),
                      const SizedBox(height: 22),
                      DropdownButtonFormField<int>(
                          initialValue: cycle.closingDay,
                          key: ValueKey('end_$day'),
                          decoration: InputDecoration(
                              labelText: en ? 'Closes on' : 'Día de cierre'),
                          items: List.generate(
                              31,
                              (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(i == 30
                                      ? (en
                                          ? 'Last day of month'
                                          : 'Último día del mes')
                                      : '${i + 1}'))),
                          onChanged: _busy
                              ? null
                              : (v) =>
                                  setState(() => _day = v == 31 ? 1 : v! + 1)),
                    ])),
                const SizedBox(height: 20),
                Text(
                    '${format.format(period.start)} → ${format.format(period.lastDay)}',
                    style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 17)),
                const SizedBox(height: 12),
                Text(
                    en
                        ? 'Closing is the day before the next start, so no days are skipped or counted twice. In shorter months, the start moves to the last available day. Changing your cycle regroups existing transactions; it never deletes them. Saved budget limits follow the month in which the cycle starts. This preference is saved on this device for your account.'
                        : 'El cierre es el día anterior al siguiente inicio, sin huecos ni días duplicados. En meses cortos, el inicio se ajusta al último día disponible. Cambiar el ciclo reorganiza tus movimientos; no los elimina. Los límites guardados corresponden al mes en que empieza el ciclo. Esta preferencia se guarda en este dispositivo para tu cuenta.',
                    style:
                        TextStyle(color: AppColors.textSecondary, height: 1.5)),
                const SizedBox(height: 28),
                if (_error != null)
                  Text(_error!,
                      style: const TextStyle(color: AppColors.expenseColor)),
                FilledButton(
                    onPressed: _busy || !provider.loaded
                        ? null
                        : () async {
                            setState(() {
                              _busy = true;
                              _error = null;
                            });
                            try {
                              await provider.save(day);
                              if (context.mounted) Navigator.pop(context);
                            } catch (_) {
                              if (mounted) {
                                setState(() {
                                  _busy = false;
                                  _error = en
                                      ? 'Could not save. Please try again.'
                                      : 'No se pudo guardar. Inténtalo de nuevo.';
                                });
                              }
                            }
                          },
                    child: Text(_busy
                        ? (en ? 'Saving…' : 'Guardando…')
                        : (en ? 'Save cycle' : 'Guardar ciclo'))),
              ]))),
    );
  }
}
