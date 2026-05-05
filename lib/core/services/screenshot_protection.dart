// v2.4 — Protezione screenshot/preview (Android FLAG_SECURE).
// Su iOS lo "snapshot" del task switcher non è bloccabile via Flutter
// nativamente; richiederebbe un overlay nello AppDelegate.
// Qui usiamo MethodChannel; lato Android viene gestito in MainActivity.
import 'package:flutter/services.dart';

class ScreenshotProtection {
  static const _channel = MethodChannel('aeterna/screenshot');

  /// Attiva FLAG_SECURE: blocca screenshot e preview nel recents.
  static Future<void> enable() async {
    try {
      await _channel.invokeMethod('enable');
    } catch (_) {
      // su iOS / piattaforme non supportate ignoriamo silenziosamente
    }
  }

  static Future<void> disable() async {
    try {
      await _channel.invokeMethod('disable');
    } catch (_) {}
  }
}
