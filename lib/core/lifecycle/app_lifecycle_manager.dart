// v2.3 — Auto-lock dopo inattività in background.
// Quando l'app va in `paused`/`inactive` parte un timer; se l'app non
// riprende entro `lockAfter` viene invocata `onLock`.
import 'dart:async';

import 'package:flutter/widgets.dart';

class AppLifecycleManager with WidgetsBindingObserver {
  final VoidCallback onLock;
  final Duration lockAfter;
  Timer? _timer;

  AppLifecycleManager({
    required this.onLock,
    this.lockAfter = const Duration(seconds: 30),
  });

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(lockAfter, onLock);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _startTimer();
        break;
      case AppLifecycleState.resumed:
        _cancelTimer();
        break;
      case AppLifecycleState.detached:
        // App killata: lock immediato per coerenza.
        onLock();
        break;
    }
  }
}
