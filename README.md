 Gabe Mobile Auto

Gabe Mobile Auto is a Flutter application for coordinating automotive service work between customers and the team handling it. The app includes role-based experiences for customers, technicians, HR, and administrators, with Firebase services supporting authentication and cloud data.

## Features

The codebase is organized around these app areas:

- **Authentication and profiles** for signing in and role-aware access.
- **Service bookings** for customer requests and booking workflows.
- **Customer dashboard** for accessing customer-facing app features.
- **Technician tools** for technician workflows.
- **Administration and HR dashboards** for team operations.
- **Chat, invoicing, and tracking** feature areas.
- **Firebase integration** using Firebase Authentication and Cloud Firestore.

> Feature availability and setup requirements may change as development continues. Refer to the current source code and project notes for implementation details.

## Technology

- Flutter and Dart
- Firebase Core, Firebase Authentication, and Cloud Firestore
- Provider for state management
- GoRouter for navigation
- Google Sign-In
- Geolocator and permission_handler for location-related functionality

## Getting started

### Requirements

- Flutter SDK compatible with the Dart SDK constraint in `pubspec.yaml`
- A configured Firebase project
- Android Studio or Xcode for running on a mobile device or emulator

### Setup

1. Clone the repository and open the project directory:

   ```bash
   git clone https://github.com/Lastchapter88/gabe-mobile-auto.git
   cd gabe-mobile-auto
   ```

2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase for the platforms you want to run. Generate the FlutterFire options file (`lib/firebase_options.dart`) with the FlutterFire CLI, and make sure the corresponding Android/iOS Firebase app configuration is in place.

4. Enable the authentication providers used by your Firebase project, and configure any required Google Sign-In settings.

5. Start the app on a connected device or emulator:

   ```bash
   flutter run
   ```

## Project structure

```text
lib/
  main.dart                 App startup, Firebase initialization, and role routing
  src/
    config/                 App configuration and theme
    features/               Authentication, booking, dashboards, chat, invoicing,
                            profiles, technician tools, and tracking
    models/                 App data models
    providers/              Shared app state
    utils/                  Utilities
    widgets/                Reusable UI components
```

## Development checks

Run the analyzer and test suite with:

```bash
flutter analyze
flutter test
```

## Project notes

Additional booking and Firestore implementation notes and booking test instructions are available in the repository root:

- `BOOKING_FIX_SUMMARY.md`
- `FIRESTORE_IMPLEMENTATION_CHECKLIST.md`
- `HOW_TO_TEST_BOOKING.md`
