import 'package:flutter/services.dart';

/// Zentrale Verwaltung für haptisches Feedback
/// Gibt der App ein hochprofessionelles, "teueres" Gefühl
class HapticFeedback {
  /// Leichtes Tippen - für Button-Presses
  static Future<void> lightTap() async {
    await HapticFeedbackService.performHapticFeedback(
      HapticFeedbackType.light,
    );
  }

  /// Mittleres Tippen - für wichtige Aktionen
  static Future<void> mediumTap() async {
    await HapticFeedbackService.performHapticFeedback(
      HapticFeedbackType.medium,
    );
  }

  /// Starkes Tippen - für kritische Aktionen
  static Future<void> heavyTap() async {
    await HapticFeedbackService.performHapticFeedback(
      HapticFeedbackType.heavy,
    );
  }

  /// Erfolgreiche Aktion - doppeltes Tap
  static Future<void> success() async {
    await HapticFeedbackService.performHapticFeedback(
      HapticFeedbackType.success,
    );
  }

  /// Fehler/Warnung
  static Future<void> error() async {
    await HapticFeedbackService.performHapticFeedback(
      HapticFeedbackType.error,
    );
  }

  /// Warnung/Ablehnung
  static Future<void> warning() async {
    await HapticFeedbackService.performHapticFeedback(
      HapticFeedbackType.warning,
    );
  }

  /// Auswahl/Bestätigung
  static Future<void> selection() async {
    await HapticFeedbackService.performHapticFeedback(
      HapticFeedbackType.selection,
    );
  }
}

/// Interner Service für Haptic Feedback
class HapticFeedbackService {
  static Future<void> performHapticFeedback(
    HapticFeedbackType type,
  ) async {
    try {
      switch (type) {
        case HapticFeedbackType.light:
          await SystemChannels.platform.invokeMethod(
            'HapticFeedback.vibrate',
          );
          break;
        case HapticFeedbackType.medium:
          await SystemChannels.platform.invokeMethod(
            'HapticFeedback.mediumImpact',
          );
          break;
        case HapticFeedbackType.heavy:
          await SystemChannels.platform.invokeMethod(
            'HapticFeedback.heavyImpact',
          );
          break;
        case HapticFeedbackType.success:
          await SystemChannels.platform.invokeMethod(
            'HapticFeedback.selectionClick',
          );
          break;
        case HapticFeedbackType.error:
          for (int i = 0; i < 2; i++) {
            await Future.delayed(const Duration(milliseconds: 50));
            await SystemChannels.platform.invokeMethod(
              'HapticFeedback.heavyImpact',
            );
            await Future.delayed(const Duration(milliseconds: 100));
          }
          break;
        case HapticFeedbackType.warning:
          await SystemChannels.platform.invokeMethod(
            'HapticFeedback.mediumImpact',
          );
          await Future.delayed(const Duration(milliseconds: 100));
          await SystemChannels.platform.invokeMethod(
            'HapticFeedback.mediumImpact',
          );
          break;
        case HapticFeedbackType.selection:
          await SystemChannels.platform.invokeMethod(
            'HapticFeedback.selectionClick',
          );
          break;
      }
    } catch (e) {
      // Haptic Feedback nicht verfügbar auf dieser Plattform
    }
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  success,
  error,
  warning,
  selection,
}
