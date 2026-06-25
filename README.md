# Calc Pro

A full-featured calculator app built with **Flutter** (cross-platform) and **Kivy** (Android).

| Platform | Tech | Build |
|----------|------|-------|
| Android / iOS / Web | Flutter | `flutter/` |
| Android (legacy) | Kivy + Buildozer | `main.py` |
| Web (legacy) | HTML/CSS/JS | `index.html` |
| Terminal | Python | `term_calc.py` |

## Features

- **Basic operations**: addition, subtraction, multiplication, division, percentage
- **Scientific functions**: sin, cos, tan, arcsin, arccos, arctan, log, ln, sqrt, cbrt, square, cube, power, factorial, reciprocal, exponent, absolute value
- **Constants**: π, e
- **Dark & Light themes** with toggle
- **Calculation history** with tap-to-restore
- **Memory functions**: MC, MR, M+, M-, MS
- **Parentheses support** for complex expressions
- **Degree/Radian mode** toggle for trig functions
- **Number formatting** with thousands separators
- **Keyboard support** (desktop)

## Flutter App (recommended)

```bash
cd flutter
flutter pub get
flutter run
```

### Build APK (local)

```bash
flutter build apk --release
# APK at build/app/outputs/flutter-apk/app-release.apk
```

### Download pre-built APK

Every push to `main` builds the APK via GitHub Actions. Grab it from the [Actions tab](https://github.com/mathan0310E/calculator/actions).

## Legacy Versions

### Kivy (Python)

```bash
pip install -r requirements.txt
python main.py
```

### Terminal

```bash
python3 term_calc.py
```

### Web

Open `index.html` in any modern browser.

## Project Structure

```
calculator/
├── flutter/               # Flutter cross-platform app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── logic/         # Calculator engine, history, themes
│   │   └── ui/            # Screens and widgets
│   └── pubspec.yaml
├── main.py                # Kivy mobile/desktop app (legacy)
├── curses_calc.py         # Terminal version (curses)
├── term_calc.py           # Simple terminal calculator
├── index.html             # Web-based calculator (legacy)
├── buildozer.spec         # Buildozer config for Android APK
├── requirements.txt       # Python dependencies
└── .github/workflows/     # CI: automatic APK builds
```

## Usage

- Tap numbers and operators to build expressions
- Toggle between **Basic** and **Scientific** tabs
- Use **AC** to clear all, **⌫** to backspace
- Press **±** to negate the current value
- Tap **M** for memory functions
- Tap **📋** to view calculation history
- Toggle **🌙/☀️** for dark/light theme
- Switch **DEG/RAD** for angle mode

## License

MIT
