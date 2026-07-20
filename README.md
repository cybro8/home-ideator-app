# 🏠 Home Ideator App

> **An IoT-powered Flutter application for real-time home electrical device monitoring and smart component replacement recommendations.**

Home Ideator connects to IoT sensor boards (e.g. ESP8266 / Arduino with a current + voltage sensor) installed on home appliances. It reads live **Voltage**, **Current**, and **Power** data from Firebase Realtime Database, visualises them on animated circular gauges, and intelligently recommends replacement components via an integrated Shop — all within a clean, cross-platform mobile app.

---

## 📋 Table of Contents

- [What It Does](#-what-it-does)
- [System Architecture](#-system-architecture)
- [App Flow](#-app-flow)
- [Firebase Data Structure](#-firebase-data-structure)
- [Project Structure](#-project-structure)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Setup & Installation](#-setup--installation)
- [Running the App](#-running-the-app)
- [Rating Generator Tool](#-rating-generator-tool)
- [Testing](#-testing)
- [Bug Fixes Applied](#-bug-fixes-applied)
- [Screens Overview](#-screens-overview)

---

## 🎯 What It Does

| Feature | Description |
|---------|-------------|
| **Live Sensor Monitoring** | Reads Voltage (V), Current (A), and Power (W) from IoT boards in real-time via Firebase Realtime Database |
| **Visual Gauges** | Animated circular progress indicators display each sensor reading as a percentage of its safe operating range |
| **Multi-Device Support** | Each user account can have multiple IoT boards (Device1, Device2 …) |
| **Component Shop** | Browse replacement components for your devices, fetched from Cloud Firestore, with product images, ratings, cost, and direct buy links |
| **Smart Rating Generator** | A companion Python script analyses historical usage CSV data and generates a health rating (1–9) for each device |
| **Secure Auth** | Firebase email/password authentication with email verification on sign-up |

---

## 🏗 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       USER'S HOME                               │
│                                                                 │
│  ┌──────────────┐    Serial/WiFi    ┌─────────────────────┐    │
│  │  Appliance   │ ◄────────────────► │  IoT Sensor Board   │   │
│  │  (CFL, Fan,  │                   │  (ESP8266 / Arduino) │   │
│  │   AC, etc.)  │                   │  - Voltage Sensor    │   │
│  └──────────────┘                   │  - Current Sensor    │   │
│                                     └──────────┬────────────┘   │
└─────────────────────────────────────────────────┼───────────────┘
                                                  │ HTTPS / WiFi
                                                  ▼
                                    ┌─────────────────────────┐
                                    │   Firebase Realtime DB   │
                                    │                          │
                                    │  user/                   │
                                    │   └─ {uid}/              │
                                    │       └─ Device1/        │
                                    │           ├─ Voltage: "" │
                                    │           ├─ Current: "" │
                                    │           ├─ Power:   "" │
                                    │           ├─ Name:    "" │
                                    │           └─ Website: "" │
                                    └──────────┬──────────────┘
                                               │ Real-time listener
                                               ▼
                              ┌────────────────────────────────┐
                              │     Home Ideator Flutter App    │
                              │                                 │
                              │  ┌──────────┐  ┌───────────┐  │
                              │  │ Home Tab │  │ Shop Tab  │  │
                              │  │ (gauges) │  │(Firestore)│  │
                              │  └──────────┘  └───────────┘  │
                              └────────────────────────────────┘
```

---

## 🔄 App Flow

```
App Launch
    │
    ▼
┌──────────────┐       5 sec        ┌──────────────────┐
│  Splash      │ ─────────────────► │   Welcome Page   │
│  Screen      │                    │                  │
└──────────────┘                    └────────┬─────────┘
                                             │
                          ┌──────────────────┴───────────────────┐
                          │                                       │
                          ▼                                       ▼
                  ┌───────────────┐                    ┌────────────────┐
                  │  Sign In      │                    │   Sign Up      │
                  │               │                    │                │
                  │ • Email       │                    │ • Email        │
                  │ • Password    │                    │ • Password     │
                  └──────┬────────┘                    └───────┬────────┘
                         │                                     │
                         │ Firebase Auth                       │ Create account
                         │ signIn()                            │ + email verify
                         │                                     │ + init DB node
                         └──────────────┬──────────────────────┘
                                        │
                                        ▼
                               ┌─────────────────┐
                               │   Dashboard      │
                               │                  │
                               │  ┌────┐ ┌─────┐ │
                               │  │Home│ │Shop │ │  ◄─ BubbleBottomBar
                               │  └────┘ └─────┘ │
                               └────────┬─────────┘
                                        │
                     ┌──────────────────┴────────────────────┐
                     │                                        │
                     ▼                                        ▼
          ┌─────────────────────┐               ┌────────────────────────┐
          │  Home Tab           │               │  Shop Tab              │
          │                     │               │                        │
          │  FirebaseAnimated   │               │  Cloud Firestore        │
          │  List (per device)  │               │  'shop' collection      │
          │                     │               │                        │
          │  ┌───────────────┐  │               │  • Product Name        │
          │  │ Device Card   │  │               │  • Image               │
          │  │               │  │               │  • Rating              │
          │  │ ⬤ Voltage    │  │               │  • Cost                │
          │  │ ⬤ Current    │  │               │  • E-commerce Link     │
          │  │ ⬤ Power      │  │               │                        │
          │  │               │  │               │  Tap → Opens buy URL   │
          │  │ [Replace]     │  │               └────────────────────────┘
          │  └───────────────┘  │
          └─────────────────────┘
```

---

## 🔥 Firebase Data Structure

### Realtime Database

```
{
  "user": {
    "<Firebase UID>": {
      "Device1": {
        "Name":    "Living Room Fan",
        "Voltage": "220",
        "Current": "0.8",
        "Power":   "176",
        "Website": "https://example.com/buy-component"
      },
      "Device2": {
        "Name":    "Bedroom CFL",
        "Voltage": "230",
        "Current": "0.2",
        "Power":   "46",
        "Website": "https://example.com/buy-cfl"
      }
    }
  }
}
```

> **Note:** The IoT board writes to this path. The app listens using `onChildAdded` and `onChildChanged` streams.

### Cloud Firestore — `shop` collection

```
shop/
  └─ <doc-id>/
       ├─ Name:   "Crompton LED Bulb"
       ├─ Image:  "https://..."         ← product image URL
       ├─ Rating: "4.5 ★"
       ├─ Cost:   "249"
       ├─ Ecom:   "https://..."         ← e-commerce logo URL
       └─ Website:"https://amazon.in/..." ← buy link
```

---

## 📁 Project Structure

```
home-ideator-app/
│
├── lib/
│   ├── main.dart                   # App entry point, splash screen
│   ├── dashboard.dart              # Bottom navigation host (Home + Shop tabs)
│   │
│   ├── Setup/
│   │   ├── welcome_page.dart       # Landing page with Sign In / Sign Up buttons
│   │   ├── signin.dart             # Firebase email/password sign-in
│   │   └── signup.dart             # Firebase account creation + DB initialisation
│   │
│   ├── Pages/
│   │   ├── home.dart               # Real-time device monitoring dashboard
│   │   └── shop_page.dart          # Component shop (Firestore-powered)
│   │
│   └── model/
│       └── board.dart              # Board data model (maps to Firebase node)
│
├── Rating Generator/
│   └── code.py                     # Offline device health rating tool (Python)
│
├── images/
│   ├── icon.png                    # App logo shown in AppBar + auth screens
│   └── splash.png                  # Splash screen graphic
│
├── android/                        # Android build configuration
├── ios/                            # iOS build configuration
└── pubspec.yaml                    # Flutter dependencies
```

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Mobile Framework** | Flutter (Dart) |
| **Authentication** | Firebase Auth (email/password) |
| **Real-time Data** | Firebase Realtime Database |
| **Product Catalogue** | Cloud Firestore |
| **IoT Hardware** | ESP8266 / Arduino + voltage + current sensors |
| **Data Analysis** | Python 3 + Pandas |
| **Navigation** | BubbleBottomBar |
| **Gauges** | percent_indicator |
| **URL Handling** | url_launcher |
| **Splash Screen** | splashscreen |

---

## ✅ Prerequisites

Before you begin, make sure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `>=2.7.0 <3.0.0`
- [Android Studio](https://developer.android.com/studio) **or** [Xcode](https://developer.apple.com/xcode/) (for iOS)
- A [Firebase project](https://console.firebase.google.com/) with:
  - **Firebase Authentication** enabled (Email/Password provider)
  - **Firebase Realtime Database** created
  - **Cloud Firestore** database created
  - `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) downloaded
- **Python 3.8+** and `pandas` (for the Rating Generator tool only)

---

## 🚀 Setup & Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/home-ideator-app.git
cd home-ideator-app
```

### 2. Configure Firebase

#### Android
```bash
# Place the file at:
android/app/google-services.json
```

#### iOS
```bash
# Place the file at:
ios/Runner/GoogleService-Info.plist
```

### 3. Set Firebase Realtime Database Rules

In the Firebase Console → Realtime Database → Rules:

```json
{
  "rules": {
    "user": {
      "$uid": {
        ".read":  "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

### 4. Set Firestore Rules

In Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /shop/{document=**} {
      allow read: if request.auth != null;
    }
  }
}
```

### 5. Install Flutter Dependencies

```bash
flutter pub get
```

### 6. Populate the Shop (Firestore)

In Cloud Firestore, create a collection named `shop`. Add documents with these fields:

| Field | Type | Example |
|-------|------|---------|
| `Name` | String | `"Crompton LED 9W"` |
| `Image` | String | `"https://..."` |
| `Rating` | String | `"4.3 ★"` |
| `Cost` | String | `"199"` |
| `Ecom` | String | `"https://amazon-logo.png"` |
| `Website` | String | `"https://amazon.in/..."` |

---

## ▶️ Running the App

```bash
# Check connected devices
flutter devices

# Run on Android or iOS
flutter run

# Run on a specific device
flutter run -d <device-id>

# Build release APK (Android)
flutter build apk --release

# Build release IPA (iOS)
flutter build ios --release
```

---

## 🐍 Rating Generator Tool

The `Rating Generator/code.py` script is a **standalone Python tool** that reads a historical CSV log from an IoT sensor board and produces a health rating (1–9) for the device.

### What It Does

It reads a `crompton_CFL_records.csv` file with columns including `Voltage`, `Current`, and `Time Stamp` (format `HH:MM:SS`), filters out zero-reading rows, sums total device runtime, and assigns a rating:

| Total Runtime | Rating |
|---------------|--------|
| < 24 hours | **1** — Very new |
| Exactly 1 day | **2** — Just started |
| 2 – 89 days | **4** — Moderate use |
| 90 – 183 days | **8** — Heavy use |
| > 183 days | **9** — Replace soon |
| > 1 year | **9** — Critical |

### Running Tests

```bash
cd "home-ideator-app/Rating Generator"

# Create a virtual environment (first time only)
python3 -m venv venv
source venv/bin/activate        # macOS/Linux
venv\Scripts\activate           # Windows

pip install pandas

# Run the built-in test suite (10 tests, all boundaries covered)
python3 code.py
```

Expected output:
```
=== Running Rating Generator Tests ===

  [PASS] 0 minutes  → 0 hrs → ≤23 branch → rating 1
  [PASS] 30 min     → 0 hrs → ≤23 branch → rating 1
  [PASS] 1380 min   → 23 hrs → boundary, still rating 1
  [PASS] 1440 min   → exactly 1 day → rating 2 (was broken by == bug)
  [PASS] 2880 min   → 2 days → less than 90 days → rating 4
  [PASS] 128160 min → 89 days → still <90 → rating 4
  [PASS] 129600 min → 90 days → rating 8
  [PASS] 263520 min → 183 days boundary → rating 8
  [PASS] 264960 min → 184 days → rating 9
  [PASS] 527040 min → 366 days (over 1 year) → rating 9

Results: 10 passed, 0 failed out of 10 tests.
```

### Running Against a Real CSV

Inside `code.py`, uncomment the last line:

```python
if __name__ == '__main__':
    _run_tests()
    run_from_csv("crompton_CFL_records.csv")   # ← uncomment this
```

Your CSV must have at least these columns:

```
Time Stamp, Voltage, Current, ...
08:30:45,   220,     0.8, ...
```

---

## 🐛 Bug Fixes Applied

16 bugs were identified and fixed across the codebase. Key highlights:

| # | File | Bug | Severity |
|---|------|-----|----------|
| 1 | `main.dart` | `ErrorWidget.builder` silenced **all** errors → masked every other bug | 🔴 Critical |
| 2 | `dashboard.dart` | Nested `MaterialApp` broke all `Navigator.push()` calls | 🔴 Critical |
| 3 | `home.dart` | Spurious `void main()` at file top re-bootstrapped the app | 🔴 Critical |
| 4 | `home.dart` | `e.print("Fine")` — invalid Dart, crashed the catch block | 🔴 Critical |
| 5 | `home.dart` | Same nested `MaterialApp` issue as dashboard | 🔴 Critical |
| 6 | `home.dart` | `singleWhere` threw `StateError` when key not found | 🟠 High |
| 7 | `home.dart` | Gauge percentages hardcoded (0.25 / 0.5 / 0.01) — never showed real data | 🟠 High |
| 8 | `home.dart` | No null-check on `currentUser()` → crash when not signed in | 🟠 High |
| 9 | `signup.dart` | Button label said "Sign in" on the Sign Up screen | 🟡 Medium |
| 10 | `signup.dart` | Firebase initial values `'O'` (letter O) instead of `'0'` (zero) | 🔴 Critical |
| 11 | `signup.dart` | `pop()` + `push()` navigation pattern could crash | 🟠 High |
| 12 | `signin.dart` | `e.message` crashes for non-Firebase exceptions | 🟡 Medium |
| 13 | `code.py` | `rating == 2` (comparison, not assignment) → `NameError` | 🔴 Critical |
| 14 | `code.py` | `rating` undefined for 0-minute input → `NameError` | 🟠 High |
| 15 | `code.py` | `df['Time Stamp'][time]` `KeyError` after filtered index | 🟡 Medium |
| 16 | `code.py` | `int(least_time[2])` `IndexError` on short timestamp strings | 🟡 Medium |

---

## 📱 Screens Overview

| Screen | Description |
|--------|-------------|
| **Splash Screen** | App logo displayed for 5 seconds before navigating to Welcome |
| **Welcome Page** | Landing page with Sign In and Sign Up buttons |
| **Sign In** | Email + password login with format validation and loading state |
| **Sign Up** | New account creation, email verification, and Firebase DB initialisation |
| **Dashboard** | Host widget with animated bubble bottom navigation bar |
| **Home Tab** | Real-time animated circular gauges per IoT device (Voltage / Current / Power) |
| **Shop Tab** | Firestore-powered product list with images, ratings, costs, and buy links |

---

## 🧪 Testing

The project includes a comprehensive test suite covering unit tests, widget tests, and logic tests across all layers of the app.

### Test Structure

```
test/
├── all_tests.dart                     ← Master runner (runs all suites)
│
├── model/
│   └── board_test.dart                ← Board model unit tests
│
├── setup/
│   ├── signin_test.dart               ← LoginPage widget tests
│   ├── signup_test.dart               ← SignUp widget tests
│   └── welcome_page_test.dart         ← WelcomePage widget tests
│
└── pages/
    └── sensor_logic_test.dart         ← Sensor gauge + rating logic unit tests
```

### Test Coverage by File

#### `test/model/board_test.dart` — Board Model (10 groups, 40+ cases)

| Group | What is tested |
|-------|----------------|
| Primary constructor | All 6 fields stored correctly, key not null, empty strings allowed |
| `fromSnapshot` | Complete map parsed, each field null → empty string fallback, int values → string |
| `toJson` | Correct keys produced, `key` field excluded, round-trip with `boardFromMap` |
| `copyWith` | No overrides = same values; partial overrides; original not mutated |
| Equality (`==`) | Same key → equal; different key → not equal; null/type safety |
| `hashCode` | Equal boards have same hash; usable as `Map` key |
| `toString` | Contains key, name, voltage, current, power; non-empty for defaults |
| Sensor edge cases | Zero strings, max values, non-numeric `'O'` bug artifact, int-typed values |
| Email validator | Null, empty, missing `@`, missing TLD, valid formats, regex boundaries |
| Password validator | Null, empty, 5-char fails, 6-char passes, long passwords |
| Board list ops | Add, `firstWhere` with `orElse`, safe null return, update in-place, `Set` dedup |

#### `test/setup/signin_test.dart` — Sign In Screen (5 groups, 15+ cases)

| Group | What is tested |
|-------|----------------|
| AppBar & structure | Title "Sign in", Email-ID label, Password label, 2× TextFormField, RaisedButton |
| Email validation | Empty → required error; no `@` → format error; missing domain → format error |
| Password validation | < 6 chars → error; 6+ chars → no error |
| Combined form | Both empty → both errors shown; no errors on initial render |
| Loading state | No spinner on initial render; button text visible before loading |

#### `test/setup/signup_test.dart` — Sign Up Screen (5 groups, 15+ cases)

| Group | What is tested |
|-------|----------------|
| AppBar & structure | Title "Sign Up", labels, 2× TextFormField, RaisedButton |
| **Bug fix verify** | Button says **"Sign Up"** not "Sign in" — confirms the label bug is fixed |
| Email validation | Empty, missing `@`, missing TLD, valid email → no errors |
| Password validation | < 6 chars → error; 6+ chars → passes; `obscureText = true` |
| Combined & loading | Both empty → both errors; no errors on initial render; no spinner initially |

#### `test/setup/welcome_page_test.dart` — Welcome Page (4 groups, 6 cases)

| Group | What is tested |
|-------|----------------|
| AppBar | Title is "Home Ideator" |
| Buttons | "Sign In" present, "SignUp" present, exactly 2 CupertinoButtons |
| Navigation | Tap Sign In → navigates to Sign In screen; Tap SignUp → navigates to Sign Up screen |
| Layout | Column layout present; no overflow errors on iPhone 375×812 |

#### `test/pages/sensor_logic_test.dart` — Sensor & Rating Logic (7 groups, 40+ cases)

| Group | What is tested |
|-------|----------------|
| `parsePercent` — null/empty | `null`, `''`, whitespace → `0.0` |
| `parsePercent` — non-numeric | `'O'` (old bug), `'N/A'`, `'?'`, `'12abc'` → `0.0` (no crash) |
| Voltage (max 240V) | 0V→0.0; 120V→0.5; 240V→1.0; 300V clamped→1.0; 220V, 230V typical |
| Current (max 16A) | 0A→0.0; 8A→0.5; 16A→1.0; 20A clamped→1.0; 0.18A CFL, 0.5A fan |
| Power (max 3840W) | 0W→0.0; 1920W→0.5; 3840W→1.0; 9W CFL, 75W fan, 1500W AC |
| Generic boundaries | All results ∈ [0.0, 1.0]; 50% midpoints; default max=100; small positive |
| `computeRating` | All 10 boundary conditions (mirrors Python tests, confirms `rating=2` bug fix) |

#### `Rating Generator/code.py` — Python (1 suite, 10 cases)

The Python rating generator has its own built-in test runner:

```
=== Running Rating Generator Tests ===

  [PASS] 0 minutes  → 0 hrs → ≤23 branch → rating 1
  [PASS] 1380 min   → 23 hrs → boundary, still rating 1
  [PASS] 1440 min   → exactly 1 day → rating 2  ← was broken (rating == 2 bug)
  [PASS] 2880 min   → 2 days → less than 90 days → rating 4
  [PASS] 128160 min → 89 days → still <90 → rating 4
  [PASS] 129600 min → 90 days → rating 8
  [PASS] 263520 min → 183 days boundary → rating 8
  [PASS] 264960 min → 184 days → rating 9
  [PASS] 527040 min → 366 days (over 1 year) → rating 9

Results: 10 passed, 0 failed out of 10 tests.
```

---

### Running the Tests

#### Run all Flutter tests

```bash
flutter test
```

#### Run a specific test file

```bash
# Board model unit tests
flutter test test/model/board_test.dart

# Sign In widget tests
flutter test test/setup/signin_test.dart

# Sign Up widget tests
flutter test test/setup/signup_test.dart

# Welcome Page widget tests
flutter test test/setup/welcome_page_test.dart

# Sensor gauge + rating logic unit tests
flutter test test/pages/sensor_logic_test.dart
```

#### Run the Python rating generator tests

```bash
# Create a virtual environment (first time only)
python3 -m venv venv
source venv/bin/activate      # macOS / Linux
venv\Scripts\activate         # Windows
pip install pandas

# Run the built-in test suite
python3 "Rating Generator/code.py"
```

#### Run tests with verbose output

```bash
flutter test --reporter expanded
```

#### Run tests with coverage report

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 📄 License

This project is open source. See [LICENSE](LICENSE) for details.
