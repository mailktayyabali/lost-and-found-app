# Project Architecture and Folder Structure

This project follows a **Feature-Driven Architecture** (sometimes combining Clean Architecture principles). This structure is designed to be highly scalable, modular, and easy for a team of developers to understand without stepping on each other's toes.

Below is an explanation of the folder structure and a guide on the exact type of code you should write in each directory.

## High-Level Directory Tree

```
lib/
├── core/
├── features/
├── shared/
└── main.dart
```

---

## 1. `core/` (App-wide Configurations & Utilities)
The `core` directory is exclusively for application-wide infrastructure. It should **never** contain code specific to a single feature (like Login or Lost Items).

- **`constants/`**: Store global constants here. Things like standard dimensions, animation durations, API endpoint strings, or app-wide enumerations.
- **`theme/`**: All UI styling goes here. `ThemeData` configurations (Material 3), global color palettes (`colors.dart`), typography setups, and standard text styles.
- **`utils/`**: General helper files and extensions. For example: date formatters, email validation regex, string capitalization logic, or logging utilities.
- **`network/`**: Everything related to the core HTTP layer. (e.g., your Dio or HTTP client setup, interceptors, connectivity checkers).
- **`error/`**: Global error handling. Define your app's custom `Failure` classes or global exception models here.

---

## 2. `features/` (The Core Modules)
This is where 90% of your development will happen. Instead of grouping all screens together and all controllers together (which scales poorly), we group code by **Feature** (e.g., `auth`, `home`, `profile`, `items`). 

Each feature is fully self-contained. Inside a feature, we typically organize by layers:

### `presentation/` (UI Layer)
- **What goes here:** Flutter code. Your Screens, layout Widgets, and State Management controllers specific to this feature.
- **Examples:** `login_screen.dart`, `login_form_widget.dart`, `auth_bloc.dart` (or `auth_provider.dart`), `forgot_password_sheet.dart`.

### `domain/` (Business Rules Layer)
- **What goes here:** The pure business rules. Entities (plain dart objects), Use Cases (actions the user can perform), and Repository Abstract Interfaces. **Zero** Flutter UI imports should exist here.
- **Examples:** `user_entity.dart`, `auth_repository.dart` (interface), `login_usecase.dart`.

### `data/` (Data & External Layer)
- **What goes here:** The actual implementation of how data is fetched or stored. API calls, local database (SQLite/Hive/SharedPreferences) interactions, building JSON models, and Data Transfer Objects (DTOs).
- **Examples:** `auth_remote_data_source.dart`, `user_model.dart` (fromJSON logic), `auth_repository_impl.dart` (the class that implements the domain interface).

---

## 3. `shared/` (Cross-Feature Reusable UI/Data)
Code in this folder is shared across multiple features, but differs from `core/` because it usually directly returns Widgets or application common logic.

- **`widgets/`**: Reusable custom UI components. If you design a beautiful custom button (`PrimaryButton`), a standard `AppTextField`, or a global loading overlay, place it here so all features can import it rather than rewriting it.
- **`models/`**: Base data models that features share heavily (e.g., generic `PaginationResponse` or standard `ApiResponse`).

---

## 🚀 Workflow Example: Building a "Profile" Feature
If you are assigned to build the **User Profile** page:
1. Create the base folder: `lib/features/profile/`.
2. Place the visual UI in `lib/features/profile/presentation/profile_screen.dart`.
3. If it requires updating a user's picture over an API, write that API call in `lib/features/profile/data/profile_api_client.dart`.
4. If you need a primary stylized button inside the profile screen, import the button from `lib/shared/widgets/primary_button.dart`. DO NOT build a new button inside the profile folder unless it is *completely unique* to just the profile page.
5. Do **not** place the profile screen in `core/`!
