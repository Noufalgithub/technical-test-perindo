# Technical Test: Register Offline (Member Perindo)

A robust Flutter application designed for offline-first member registration, featuring local draft management, automatic synchronization, and secure authentication.

## Key Features

- **Offline-First Workflow**: Save member data locally in a "Draft" state when internet is unavailable.
- **Bulk Synchronization**: One-tap "Upload Semua" feature with sequential async processing and error tracking.
- **User Isolation**: Local data is filtered by `userId`, ensuring multi-user privacy on the same device.
- **Dynamic Form Validation**: Real-time validation for NIK (ID Number), required fields, and multi-part image uploads.
- **Media Management**: Integrated camera capture with automatic compression using `flutter_image_compress`.
- **Global Auth Handling**: Automatic redirect to login on `401 Unauthorized` responses via custom `AuthInterceptor`.
- **Interactive UI**: Tabbed navigation between "Draft" and "Sudah Di-upload" with real-time status updates.

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **State Management** | `flutter_bloc` (BLoC Pattern) |
| **Database** | `sqflite` (SQLite) with multi-version migration |
| **Networking** | `dio` + `PrettyDioLogger` |
| **DI / Service Locator** | `get_it` |
| **Security** | `flutter_secure_storage` |
| **Functional Programming** | `dartz` (Either type for Error Handling) |

## Architecture (Clean Architecture)

The project follows a modular structure based on Clean Architecture principles:

- **Core**: Cross-cutting concerns like API interceptors, error handling, themes, and service locator.
- **Data**: Data sources (Local/Remote) and repository implementations.
- **Domain**: Pure business logic (Entities and Repository interfaces).
- **Presentation**: UI layer consisting of BLoCs, Pages, and reusable Widgets.

## Project Structure
```text
lib/
├── core/
│   ├── api/          # Dio config, Interceptors, & Auth management
│   ├── error/        # Failures & Error handlers
│   ├── theme/        # App color schemes and styles
│   └── utils/        # Constants, Validation, & Service locator
├── data/
│   ├── datasources/  # Member (SQLite/Rest) & Location data sources
│   ├── models/       # Data models (optional/entities)
│   └── repositories/ # Concrete implementation of repositories
├── domain/
│   ├── entities/     # Member, User, & Location business objects
│   └── repositories/ # Abstract contracts for data access
└── presentation/
    ├── bloc/         # BLoCs: Member (Sync), Auth, Location, Profile
    ├── pages/        # Login, Main Dashboard, Member Form, Profile
    └── widgets/      # Member List, Location Dropdowns, Info Banners
```

## Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the App**:
   ```bash
   flutter run
   ```

## Recent Updates
- **v3 Migration**: Added `user_id` column to SQLite for multi-account support.
- **Enhanced Sync**: Refactored `SyncAllMembers` logic to handle large batches reliably.
- **Auth Polish**: Implemented global `navigatorKey` for instant 401 redirects and token trimming to fix sensitivity issues.
- **Validation**: Added `*` indicators and mandatory field checks for "Nama Lengkap".
- **Reset Feature**: Added "Clear Database" functionality with confirmation dialog for developers.
