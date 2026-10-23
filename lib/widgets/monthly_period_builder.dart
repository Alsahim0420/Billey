import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../providers/financial_cycle_provider.dart';

/// Re-evaluates the local calendar month at midnight and after app resume.
class MonthlyPeriodBuilder extends StatefulWidget {
  const MonthlyPeriodBuilder({super.key, required this.builder, this.now});
  final Widget Function(BuildContext, DateTime month) builder;
  final DateTime Function()? now;
  @override
  State<MonthlyPeriodBuilder> createState() => _MonthlyPeriodBuilderState();
}

class _MonthlyPeriodBuilderState extends State<MonthlyPeriodBuilder>
    with WidgetsBindingObserver {
  Timer? _timer;
  late DateTime _month;
  late DateTime _day;
  DateTime _now() => (widget.now?.call() ?? DateTime.now()).toLocal();
  @override
  void initState() {
    super.initState();
    final now = _now();
    _month = DateTime(now.year, now.month);
    _day = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final now = _now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(
        midnight.difference(now) + const Duration(milliseconds: 50), _update);
  }

  void _update() {
    if (!mounted) return;
    final now = _now();
    final day = DateTime(now.year, now.month, now.day);
    if (_day != day) {
      setState(() {
        _day = day;
        _month = DateTime(now.year, now.month);
      });
    }
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _update();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
      context,
      context
              .watch<FinancialCycleProvider?>()
              ?.cycle
              .containing(_now())
              .start ??
          _month);
}
