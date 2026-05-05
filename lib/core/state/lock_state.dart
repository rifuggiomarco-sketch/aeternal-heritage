// v2.3 — Stato globale di lock dell'app (Riverpod).
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LockController extends StateNotifier<bool> {
  // state == true  → unlocked
  // state == false → locked
  LockController() : super(false);

  void unlock() => state = true;
  void lock() => state = false;
}

/// `true` se l'app è sbloccata.
final lockProvider = StateNotifierProvider<LockController, bool>(
  (ref) => LockController(),
);
