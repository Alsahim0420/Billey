import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/couple_finance.dart';

class CoupleFinanceStorage {
  static const _linkKey = 'couple_finance_link';
  static const _walletsKey = 'couple_finance_wallets';

  Future<CoupleLink?> loadLink() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_linkKey);
    if (raw == null) return null;
    return CoupleLink.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveLink(CoupleLink? link) async {
    final prefs = await SharedPreferences.getInstance();
    if (link == null) {
      await prefs.remove(_linkKey);
      return;
    }
    await prefs.setString(_linkKey, jsonEncode(link.toJson()));
  }

  Future<List<SharedWallet>> loadWallets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_walletsKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => SharedWallet.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveWallets(List<SharedWallet> wallets) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(wallets.map((wallet) => wallet.toJson()).toList());
    await prefs.setString(_walletsKey, encoded);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_linkKey);
    await prefs.remove(_walletsKey);
  }
}
