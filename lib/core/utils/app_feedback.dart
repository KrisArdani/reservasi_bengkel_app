import 'package:flutter/services.dart';

class AppFeedback {
  static Future<void> playClick() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> playSuccess() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static Future<void> playError() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}
