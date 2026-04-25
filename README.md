# Technical Test: Register Offline

A Flutter application for offline-first member registration.

## Features
- **Offline-First Architecture**: Save member data locally to SQLite when offline.
- **State Management**: Implemented using **BLoC** (Business Logic Component).
- **Media Management**: Camera integration with automatic image compression using `flutter_image_compress`.
- **Bulk Sync**: Sync all local "Draft" members to the server once online.
- **Secure Authentication**: Secure token storage and auth-aware API requests.

## Tech Stack
- **Framework**: Flutter
- **State Management**: `flutter_bloc`
- **Database**: `sqflite` (SQLite)
- **Networking**: `dio`
- **Dependency Injection**: `get_it`
- **Local Storage**: `flutter_secure_storage`

## Project Structure
```text
lib/
├── core/
│   ├── api/          # Dio configuration & Auth interceptor
│   ├── database/     # SQLite configuration
│   ├── error/        # Failure & Exception classes
│   ├── utils/        # Constants & Service locator
├── data/
│   ├── datasources/  # Remote & Local data sources
│   ├── repositories/ # Repository implementations
├── domain/
│   ├── entities/     # Member entity
│   ├── repositories/ # Repository interfaces
└── presentation/
    ├── bloc/         # Auth, Member, and Profile BLoCs
    ├── pages/        # Main screens (Login, Dashboard, Form, Profile)
    └── widgets/      # Reusable UI components
```

## How to Run
1. Ensure you have Flutter installed (Stable channel).
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.
4. Run the app:
   ```bash
   flutter run
   ```

## Key Highlights
- **Clean Architecture**: Separation of concerns between Data, Domain, and Presentation layers.
- **Image Optimization**: Images are compressed before being saved/uploaded to reduce storage and bandwidth usage.
- **Error Handling**: Uses `dartz` for functional error handling with the `Either` type.
