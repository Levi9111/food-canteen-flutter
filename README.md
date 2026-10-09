# RTS Food Canteen - Flutter Mobile Application

[![Flutter CI](https://github.com/Levi9111/food-canteen-flutter/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/Levi9111/food-canteen-flutter/actions/workflows/flutter_ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg)
![License](https://img.shields.io/badge/License-Proprietary-red.svg)

Tactical mobile application for Recruit Training Squadron (RTS) and Permanent Staff (P-Staff) Canteen financial management, daily entry matrices, multi-period audit reporting, and official Air Force documentation.

---

## 📌 Key Capabilities

- **Military Role & Duty Management**:
  - **NCOIC**: Cpl Shanjid Ahmad (BD/472770, Trade: E&I Fitter).
  - Flexible login supporting BD Number (`472770`, `BD/472770`), Username (`ncoic`, `shanjid`), or password credentials.
  - Simplified **Canteen Duty Appointments** UI without technical database jargon; easy appointment and handover of JCOIC and NCOIC roles.
- **Permanent Staff (P-Staff) Canteen**:
  - Full room and office ledger tracking with individual credit limits.
  - Comprehensive 31-day **Monthly Matrix Ledger** with dark mode support.
  - **Direct PDF Export**: High-resolution landscape A4 audit matrix downloaded directly to device storage with 4-tier signature blocks.
- **Recruit Training Squadron (RTS) Canteen**:
  - Flight-wise ledger matrix with multi-item calculation.
- **Upgraded Tactical Cockpit Calculator**:
  - OLED bezel display with live formula rendering and luminous amber totals.
  - Rapid sales preset chips (`+10`, `+20`, `+50`, `+100`) and tactile squircle keys.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management**: [Flutter Riverpod](https://riverpod.dev)
- **Networking**: [Dio](https://pub.dev/packages/dio) with Bearer token authentication & automatic token refresh
- **Local Persistence**: `shared_preferences`
- **PDF Generation**: `pdf` & `printing`

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Android SDK / Xcode for mobile emulation or physical device testing

### Installation

```bash
# Clone the repository
git clone https://github.com/Levi9111/food-canteen-flutter.git
cd food-canteen-flutter

# Install dependencies
flutter pub get
```

### Static Analysis & Verification

```bash
# Run static code analysis
flutter analyze

# Run unit and widget test suite
flutter test
```

### Running the App

```bash
# Debug mode
flutter run

# Release build for Android
flutter build apk --release
```

---

## 👥 Duty In-Charge

- **NCOIC**: Cpl Shanjid Ahmad (`BD/472770`) - Trade: E&I Fitter
- **Supervision**: Recruit Training Squadron (RTS), Bangladesh Air Force
