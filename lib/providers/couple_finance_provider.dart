import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/couple_finance.dart';
import '../services/couple_finance_storage.dart';
import '../services/couple_sync_service.dart';

class CoupleFinanceProvider extends ChangeNotifier {
  CoupleFinanceProvider._() : _storage = CoupleFinanceStorage();

  static final CoupleFinanceProvider instance = CoupleFinanceProvider._();

  factory CoupleFinanceProvider() => instance;

  final CoupleFinanceStorage _storage;
  static const _uuid = Uuid();

  CoupleLink? _link;
  List<SharedWallet> _wallets = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  bool get isLinked => _link != null;
  CoupleLink? get link => _link;
  List<SharedWallet> get wallets => List.unmodifiable(_wallets);

  Future<void> initialize() async {
    _link = await _storage.loadLink();
    _wallets = await _storage.loadWallets();
    _isLoaded = true;
    notifyListeners();
  }

  Future<String> createPairingQr({
    required String myName,
    required String partnerName,
  }) async {
    final credentials = CoupleSyncService.generateCredentials();
    _link = CoupleLink(
      spaceId: credentials.spaceId,
      secret: credentials.secret,
      myName: myName.trim(),
      partnerName: partnerName.trim(),
      linkedAt: DateTime.now(),
    );
    await _storage.saveLink(_link);
    notifyListeners();

    return CoupleSyncService.createPairingPayload(
      spaceId: credentials.spaceId,
      secret: credentials.secret,
      myName: myName.trim(),
      partnerName: partnerName.trim(),
    );
  }

  Future<String?> acceptPairing({
    required String payload,
    required String myName,
  }) async {
    final result = CoupleSyncService.parse(payload, expectedMyName: myName);
    if (result == null || result.type != CoupleSyncType.pairing) {
      return 'invalid';
    }

    _link = result.link;
    await _storage.saveLink(_link);
    notifyListeners();
    return null;
  }

  Future<SharedWallet> createWallet({
    required String title,
    required double budget,
    required String holderName,
  }) async {
    final now = DateTime.now();
    final wallet = SharedWallet(
      id: _uuid.v4(),
      title: title.trim(),
      budget: budget,
      holderName: holderName.trim(),
      senderName: _link?.myName ?? 'Yo',
      createdAt: now,
      updatedAt: now,
      expenses: const [],
    );

    _wallets = [wallet, ..._wallets];
    await _storage.saveWallets(_wallets);
    notifyListeners();
    return wallet;
  }

  Future<void> addExpense({
    required String walletId,
    required String title,
    required double amount,
    required String spentBy,
  }) async {
    final index = _wallets.indexWhere((wallet) => wallet.id == walletId);
    if (index == -1) return;

    final wallet = _wallets[index];
    final expense = SharedWalletExpense(
      id: _uuid.v4(),
      title: title.trim(),
      amount: amount,
      spentBy: spentBy.trim(),
      date: DateTime.now(),
    );

    final updated = wallet.copyWith(
      expenses: [expense, ...wallet.expenses],
      updatedAt: DateTime.now(),
    );

    _wallets[index] = updated;
    await _storage.saveWallets(_wallets);
    notifyListeners();
  }

  SharedWallet? walletById(String id) {
    try {
      return _wallets.firstWhere((wallet) => wallet.id == id);
    } catch (_) {
      return null;
    }
  }

  String buildSyncQr() {
    if (_link == null) return '';
    return CoupleSyncService.createSyncPayload(
      link: _link!,
      wallets: _wallets,
    );
  }

  Future<String?> mergeSyncPayload(String payload) async {
    if (_link == null) return 'not_linked';

    final json = CoupleSyncService.decodeRaw(payload);
    if (json == null ||
        json['type'] != 'sync' ||
        !CoupleSyncService.validateSync(link: _link!, payload: json)) {
      return 'invalid';
    }

    final decoded = CoupleSyncService.parse(payload);
    if (decoded == null || decoded.type != CoupleSyncType.sync) {
      return 'invalid';
    }

    _wallets = CoupleSyncService.mergeWallets(
      local: _wallets,
      incoming: decoded.wallets,
    );
    await _storage.saveWallets(_wallets);
    notifyListeners();
    return null;
  }

  Future<void> unlink() async {
    _link = null;
    _wallets = [];
    await _storage.clearAll();
    notifyListeners();
  }

  void updateMyName(String name) {
    if (_link == null) return;
    _link = CoupleLink(
      spaceId: _link!.spaceId,
      secret: _link!.secret,
      myName: name.trim(),
      partnerName: _link!.partnerName,
      linkedAt: _link!.linkedAt,
    );
    _storage.saveLink(_link);
    notifyListeners();
  }
}
