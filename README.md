# Writiva

**Read • Write • Be Heard**

Writiva is a place where readers discover new worlds and writers share their voices. It's a Flutter app that turns ideas into stories, built around three roles: **Reader**, **Author**, and **Admin**.

> The Flutter package and internal class names still use the working codename `mind_whispers_app`; the product-facing brand is Writiva.

## Brand pillars

| Pillar | Meaning |
|---|---|
| 📖 Read | Explore stories |
| ✒️ Write | Share your voice |
| 🤝 Connect | Build a community |

## Features

- **Home feed** — search, category filters (Fiction, Non-Fiction, Self-Dev, ...), and trending stories.
- **Write** — an author workspace with Drafts and Published tabs for managing stories.
- **Role-based experience** — separate flows for Reader, Author, and Admin, chosen at sign-in and persisted across sessions.
- **Localization** — English and Arabic out of the box, with full RTL support via `easy_localization`.
- **Light/dark theming** — user preference persisted locally and restored on launch.
- **Animated UI** — consistent entrance/stagger animations powered by `flutter_animate`.

## Brand identity

**Typography:** Playfair Display for headings, Inter for body text.

**Voice:** Calm · Creative · Friendly · Modern · Inspirational

**Color palette:**

| Swatch | Hex | Role |
|---|---|---|
| 🟩 | `#2E6F5B` | Primary |
| 🟪 | `#A78BFA` | Secondary |
| 🔳 | `#EBDFFB` | Accent |
| ⬜ | `#FAF8F6` | Background |
| ⬛ | `#2E2E2E` | Text |

See `docs/branding/writiva_brand_board.png` for the full brand moodboard (logo, icon, imagery, and screen references). This palette is implemented in `lib/core/theme/app_colors.dart`, and the app icon across Android/iOS/web is generated from `assets/images/logo.png` via `flutter_launcher_icons`.

## Architecture

The project follows a feature-first Clean Architecture layout:

```
lib/
├── core/            # Shared infrastructure: DI, routing, networking, theming,
│                    # error handling, auth, animations, and common widgets
└── features/        # One folder per feature (intro, reader, author, admin, ...)
```

State management uses **Cubit** (`flutter_bloc`), dependency injection uses `get_it`, and error handling uses `dartz`'s `Either` for typed success/failure results instead of exceptions.

## Tech stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` / `equatable` |
| Dependency injection | `get_it` |
| Error handling | `dartz` |
| Localization | `easy_localization` |
| Networking | `dio` |
| Local storage | `shared_preferences` |
| Responsive layout | `flutter_screenutil` |
| Animations | `flutter_animate` |
| Config | `flutter_dotenv` |

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK `^3.12.2`).
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Create a `.env` file in the project root with any required environment variables (loaded via `flutter_dotenv` at startup).
4. Run the app:
   ```
   flutter run
   ```

## Localization

Translation strings live in `assets/translations/en.json` and `assets/translations/ar.json`. Add new keys to both files to keep locales in sync.
