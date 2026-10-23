import '../../services/expense_categorizer.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../providers/category_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/transaction_provider.dart';
import 'wallet_importer.dart';

class ApplePayController extends ChangeNotifier with WidgetsBindingObserver {
  ApplePayController(this.transactions, this.categories, this.currency);

  final TransactionProvider transactions;
  final CategoryProvider categories;
  final CurrencyProvider currency;
  static const _channel = MethodChannel('billey/apple_pay');
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool supported = false;
  bool receiving = false;
  bool busy = false;
  int pending = 0;
  DateTime? lastReceived;
  String? configuredCurrency;
  String? message;
  String? _readyOwner;
  Future<void>? _running;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> initialize() async {
    if (!isIOS) return;
    try {
      supported = await _channel.invokeMethod<bool>('capabilities') ?? false;
    } on PlatformException {
      message =
          'La recepción de Apple Pay no está disponible. Reabre Billey para reintentar.';
    } on MissingPluginException {
      message = 'Esta instalación no incluye la acción nativa de Apple Pay.';
    }
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'received') await refresh();
    });
    WidgetsBinding.instance.addObserver(this);
    currency.addListener(_currencyChanged);
  }

  void _currencyChanged() => unawaited(refresh());

  Future<void> sessionChanged() async {
    if (!isIOS) return;
    final uid = _uid;
    _readyOwner = null;
    receiving = false;
    lastReceived = null;
    pending = 0;
    message = null;
    notifyListeners();
    var nativeReady = false;
    try {
      await _channel.invokeMethod<void>('session', {'owner': uid});
      nativeReady = true;
    } catch (_) {
      message =
          'No se pudo leer la bandeja. Abre Billey con el iPhone desbloqueado y reintenta.';
      notifyListeners();
    }
    // Keep normal category loading independent of the optional native bridge.
    await categories.initialize();
    if (_uid != uid || !nativeReady) return;
    _readyOwner = uid;
    await refresh();
  }

  Future<void> configure(bool allow) async {
    final uid = _uid;
    if (uid == null || !supported) return;
    try {
      await _channel.invokeMethod<void>('configure', {
        'owner': allow ? uid : null,
        'currency': allow ? currency.selectedCurrency.code : null,
      });
      await refresh();
    } on CategoryReviewRequired {
      message =
          'Hay un gasto pendiente sin categoría. Comprueba la configuración de Gemini y las categorías disponibles y vuelve a importar. No se eliminó la entrada.';
      await transactions.loadTransactions();
    } on PlatformException catch (e) {
      message = e.message;
      notifyListeners();
    }
  }

  Future<void> testReceipt() async {
    try {
      await _channel.invokeMethod<String>('test', {
        'currency': currency.selectedCurrency.code,
      });
      await refresh();
    } on CategoryReviewRequired {
      message =
          'Hay un gasto pendiente sin categoría. Comprueba la configuración de Gemini y las categorías disponibles y vuelve a importar. No se eliminó la entrada.';
      await transactions.loadTransactions();
    } on PlatformException catch (e) {
      message = e.message;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (!isIOS || !supported) return;
    // Coalesce overlapping resume, settings and auth requests, then reread.
    if (_running != null) {
      await _running;
      if (_uid != _readyOwner) return;
    }
    if (_running != null) return;
    final work = _refresh();
    _running = work;
    try {
      await work;
    } finally {
      _running = null;
    }
  }

  Future<void> _refresh() async {
    final owner = _readyOwner;
    if (owner == null || owner != _uid) return;
    busy = true;
    message = null;
    notifyListeners();
    try {
      final snapshot = await _channel.invokeMapMethod<String, dynamic>(
        'snapshot',
        {'owner': owner},
      );
      if (_uid != owner || _readyOwner != owner) return;
      final entries = (snapshot?['entries'] as List? ?? [])
          .map((e) => WalletEntry.fromMap(Map<Object?, Object?>.from(e as Map)))
          .toList();
      receiving = snapshot?['receiving'] == true;
      configuredCurrency = snapshot?['currency'] as String?;
      final last = snapshot?['lastReceived'] as num?;
      lastReceived = last == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch((last * 1000).round());
      pending = entries.where((e) => !e.isTest).length;
      for (final entry in entries.where((e) => e.isTest)) {
        await _acknowledge(owner, entry.id);
        message =
            'Prueba recibida correctamente: ${entry.amount} ${entry.currency}. No se creó ningún gasto.';
      }
      final imported = await WalletImporter().import(
        entries: entries,
        owner: owner,
        currency: currency.selectedCurrency.code,
        categories: categories.categories,
        save: transactions.importApplePay,
        acknowledge: (account, id) async {
          await _acknowledge(account, id);
          if (_uid == owner && pending > 0) pending--;
        },
        sessionIsCurrent: () => _uid == owner && _readyOwner == owner,
      );
      if (_uid != owner) return;
      if (imported > 0) {
        message = '$imported gasto(s) importado(s) desde Apple Pay/Atajos.';
        await transactions.loadTransactions();
      }
    } on CategoryReviewRequired {
      message =
          'Hay un gasto pendiente sin categoría. Comprueba la configuración de Gemini y las categorías disponibles y vuelve a importar. No se eliminó la entrada.';
      await transactions.loadTransactions();
    } on PlatformException catch (e) {
      message = e.message;
    } catch (e) {
      message = e is StateError
          ? e.message.toString()
          : 'Hay gastos pendientes. Comprueba tu conexión y vuelve a intentar; no se eliminó la entrada que falló.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _acknowledge(String owner, String id) =>
      _channel.invokeMethod<void>('acknowledge', {'owner': owner, 'id': id});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    currency.removeListener(_currencyChanged);
    super.dispose();
  }
}
