# Calc Pro

A full-featured mobile calculator built with **Kivy** for Android, with a web version also available.

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

## Screenshots

Coming soon.

## Tech Stack

- **Python 3** with **Kivy** 2.2+ for the mobile/desktop app
- **HTML/CSS/JS** for the web version (`index.html`)
- **Buildozer** for Android APK packaging

## Project Structure

```
calculator/
├── main.py          # Kivy mobile/desktop app (1249 lines)
├── curses_calc.py   # Terminal-based version (curses)
├── term_calc.py     # Simple terminal calculator
├── index.html       # Web-based calculator
├── buildozer.spec   # Buildozer config for Android APK
├── requirements.txt # Python dependencies
└── .gitignore
```

## Installation

### Mobile/Desktop (Kivy)

```bash
pip install -r requirements.txt
python main.py
```

### Android APK (Buildozer)

```bash
pip install buildozer
buildozer android debug
```

### Web

Open `index.html` in any modern browser.

## Usage

- Tap numbers and operators to build expressions
- Toggle between **Basic** and **Scientific** tabs
- Use **AC** to clear all, **⌫** to backspace
- Press **±** to negate the current value
- Long-press or tap **M** for memory functions
- Tap **📋** to view calculation history
- Toggle **🌙/☀️** for dark/light theme
- Switch **DEG/RAD** for angle mode

## License

MIT
