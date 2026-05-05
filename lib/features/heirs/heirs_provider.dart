// Bug #8 fix: gestione errori con AsyncValue e try/catch in ogni operazione.
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logger.dart';
import '../../shared/models/heir.dart';

final heirsProvider =
    AsyncNotifierProvider<HeirsNotifier, List<Heir>>(HeirsNotifier.new);

class HeirsNotifier extends AsyncNotifier<List<Heir>> {
  static const _key = 'aeterna_heirs';

  @override
  Future<List<Heir>> build() => _load();

  Future<List<Heir>> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Heir.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('HeirsNotifier._load', e, st);
      rethrow;
    }
  }

  Future<void> _save(List<Heir> heirs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(heirs.map((h) => h.toJson()).toList()));
  }

  Future<void> addHeir(Heir heir) async {
    try {
      final current = await future;
      final updated = [...current, heir];
      await _save(updated);
      state = AsyncData(updated);
    } catch (e, st) {
      AppLogger.error('HeirsNotifier.addHeir', e, st);
      state = AsyncError(e, st);
    }
  }

  Future<void> removeHeir(String id) async {
    try {
      final current = await future;
      final updated = current.where((h) => h.id != id).toList();
      await _save(updated);
      state = AsyncData(updated);
    } catch (e, st) {
      AppLogger.error('HeirsNotifier.removeHeir', e, st);
      state = AsyncError(e, st);
    }
  }
}
