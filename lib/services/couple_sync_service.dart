import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../models/couple_finance.dart';

enum CoupleSyncType { pairing, sync }

class CoupleSyncResult {
  const CoupleSyncResult({
    required this.type,
    this.link,
    this.wallets = const [],
    this.senderName,
  });

  final CoupleSyncType type;
  final CoupleLink? link;
  final List<SharedWallet> wallets;
  final String? senderName;
}

class CoupleSyncService {
  static const _prefix = 'billey://couple/v1/';
  static const _uuid = Uuid();

  static String createPairingPayload({
    required String spaceId,
    required String secret,
    required String myName,
    required String partnerName,
  }) {
    return _encode({
      'v': 1,
      'type': 'pairing',
      'spaceId': spaceId,
      'secret': secret,
      'ownerName': myName,
      'partnerName': partnerName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static ({String spaceId, String secret}) generateCredentials() {
    return (spaceId: _uuid.v4(), secret: _uuid.v4());
  }

  static String createSyncPayload({
    required CoupleLink link,
    required List<SharedWallet> wallets,
  }) {
    return _encode({
      'v': 1,
      'type': 'sync',
      'spaceId': link.spaceId,
      'secret': link.secret,
      'senderName': link.myName,
      'sentAt': DateTime.now().toIso8601String(),
      'wallets': wallets.map((wallet) => wallet.toJson()).toList(),
    });
  }

  static Map<String, dynamic>? decodeRaw(String raw) => _decode(raw);

  static CoupleSyncResult? parse(String raw, {String? expectedMyName}) {
    final json = _decode(raw);
    if (json == null) return null;

    final type = json['type'] as String?;
    if (type == 'pairing') {
      final ownerName = json['ownerName'] as String? ?? '';
      final partnerName = json['partnerName'] as String? ?? '';
      final myName = expectedMyName?.trim() ?? '';
      if (myName.isEmpty) return null;

      return CoupleSyncResult(
        type: CoupleSyncType.pairing,
        link: CoupleLink(
          spaceId: json['spaceId'] as String,
          secret: json['secret'] as String,
          myName: myName,
          partnerName: ownerName == myName ? partnerName : ownerName,
          linkedAt: DateTime.now(),
        ),
        senderName: ownerName,
      );
    }

    if (type == 'sync') {
      final walletsJson = json['wallets'] as List<dynamic>? ?? [];
      return CoupleSyncResult(
        type: CoupleSyncType.sync,
        wallets: walletsJson
            .map(
              (item) => SharedWallet.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        senderName: json['senderName'] as String?,
      );
    }

    return null;
  }

  static bool validateSync({
    required CoupleLink link,
    required Map<String, dynamic> payload,
  }) {
    return payload['spaceId'] == link.spaceId &&
        payload['secret'] == link.secret;
  }

  static List<SharedWallet> mergeWallets({
    required List<SharedWallet> local,
    required List<SharedWallet> incoming,
  }) {
    final byId = {for (final wallet in local) wallet.id: wallet};

    for (final remote in incoming) {
      final current = byId[remote.id];
      if (current == null) {
        byId[remote.id] = remote;
        continue;
      }

      final mergedExpenses = _mergeExpenses(
        current.expenses,
        remote.expenses,
      );
      final useRemote = remote.updatedAt.isAfter(current.updatedAt);
      byId[remote.id] = SharedWallet(
        id: current.id,
        title: useRemote ? remote.title : current.title,
        budget: useRemote ? remote.budget : current.budget,
        holderName: useRemote ? remote.holderName : current.holderName,
        senderName: useRemote ? remote.senderName : current.senderName,
        createdAt: current.createdAt.isBefore(remote.createdAt)
            ? current.createdAt
            : remote.createdAt,
        updatedAt: current.updatedAt.isAfter(remote.updatedAt)
            ? current.updatedAt
            : remote.updatedAt,
        expenses: mergedExpenses,
      );
    }

    final merged = byId.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return merged;
  }

  static List<SharedWalletExpense> _mergeExpenses(
    List<SharedWalletExpense> local,
    List<SharedWalletExpense> incoming,
  ) {
    final byId = {for (final expense in local) expense.id: expense};
    for (final expense in incoming) {
      byId[expense.id] = expense;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return merged;
  }

  static String fingerprint(String payload) {
    return sha256.convert(utf8.encode(payload)).toString();
  }

  static String _encode(Map<String, dynamic> json) {
    final bytes = utf8.encode(jsonEncode(json));
    return '$_prefix${base64Url.encode(bytes)}';
  }

  static Map<String, dynamic>? _decode(String raw) {
    try {
      final normalized = raw.trim();
      if (!normalized.startsWith(_prefix)) return null;
      final encoded = normalized.substring(_prefix.length);
      final decoded = utf8.decode(base64Url.decode(encoded));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
