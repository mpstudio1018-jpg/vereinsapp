# ⚡ QUICK-START: 5-Minuten Integration

## TL;DR (Nur die wichtigsten Schritte)

### Schritt 1: Copy-Paste diese Imports oben in `lib/main.dart`

Finde die erste Zeile wo `import ...` steht (ca. Zeile 1-20) und ADD diese Zeilen:

```dart
import 'constants/app_theme.dart';
import 'services/navigation_service.dart';
import 'widgets/modern_components.dart';
```

### Schritt 2: Ersetze alten Theme (Finde diese Zeile, ca. Zeile 830)

```dart
// ❌ ALT - LÖSCHEN:
// theme: ThemeData(
//   brightness: Brightness.dark,
//   primaryColor: kPrimaryColor,
//   ...
// ),

// ✅ NEU - ERSETZEN mit:
theme: AppTheme.buildTheme(),
```

### Schritt 3: Test

```bash
flutter run
```

**Fertig! Die App sieht jetzt modern aus.** 🎉

---

## Das war's schon!

Die wichtigsten Dinge sind JETZT live:
- ✅ Modernes Theme (Dunkelblau + Orange)
- ✅ Elegante Schatten & Abrundungen
- ✅ Intelligente Navigation (Subview-Reset)
- ✅ Haptic Feedback bei Buttons

---

## Optional: Moderne Buttons einbauen (2 Minuten)

Wenn du 2 mehr Minuten Zeit hast, ersetze 1-2 Buttons mit `ModernButton`:

```dart
// ❌ ALT:
ElevatedButton(
  onPressed: () { saveData(); },
  child: Text('Speichern'),
)

// ✅ NEU:
ModernButton(
  label: 'Speichern',
  onPressed: () async {
    await HapticFeedback.lightTap();
    saveData();
    await HapticFeedback.success();
  },
)
```

---

## Wenn Fehler auftauchen:

```bash
# Clean & Rebuild
flutter clean
flutter pub get
flutter analyze
```

---

**Alles klar? Los geht's!** 🚀
