# Writiva

<p align="center">
  <img src="assets/images/logo.png" alt="Writiva logo" width="140">
</p>

**Read • Write • Be Heard**

Writiva is a place where readers discover new worlds and writers share their voices. It's a Flutter app that turns ideas into stories, built around three roles: **Reader**, **Author**, and **Admin**.

> The Flutter package and internal class names still use the working codename `mind_whispers_app`; the product-facing brand is Writiva.

## Brand pillars

| Pillar | Meaning |
|---|---|
| 📖 Read | Explore stories |
| ✒️ Write | Share your voice |
| 🤝 Connect | Build a community |

## Screenshots

> Captures for the screens below aren't checked in yet — this session's tooling couldn't launch a simulator to take them. Drop PNGs into `docs/screenshots/` using the filenames in the table (e.g. `docs/screenshots/feed.png`) and they'll render here once added.

| Screen | File | What it shows |
|---|---|---|
| Splash | `docs/screenshots/splash.png` | Branded launch screen while a stored session is verified. |
| Login | `docs/screenshots/login.png` | Email/password sign-in with validation and a "remember me" option. |
| Sign up | `docs/screenshots/signup.png` | Account creation (name, email, password + confirmation). |
| Feed | `docs/screenshots/feed.png` | Search, category chips, a trending shelf, and the infinite-scroll post list. |
| Post detail | `docs/screenshots/post_detail.png` | Full post body plus its comment thread and composer. |
| Profile | `docs/screenshots/profile.png` | Signed-in identity, theme toggle, language toggle, and sign-out. |
| Role home (placeholder) | `docs/screenshots/role_placeholder.png` | Shared shell Author/Admin land on until their real screens ship. |

## Features

- **Authentication** — email/password login and sign-up against a live Laravel Sanctum API, with per-device tokens (`device_name`), an optional 30-day "remember me" session, and a splash-screen session check (`/auth/me`) on every cold start.
- **Role-based routing** — a signed-in user's role (`reader` / `author` / `admin`) picks their home screen and gates every role-scoped route; visiting a route your role doesn't own shows an Unauthorized screen instead of the content.
- **Reader home** — a Feed tab (search, category filters, a trending shelf, pull-to-refresh, infinite scroll, skeleton loading, and empty/error states) and a Profile tab, in a bottom-nav (phone) / navigation-rail (wide screen) shell that adapts at a 600px breakpoint.
- **Post detail & comments** — full post view with its comment thread: add a comment, and delete one you own (or, for post authors/admins, delete others' — mirroring the API's delete rule).
- **Author & Admin homes** — placeholder shells today (My Posts/moderation for Author, users/content moderation for Admin are next), already wired through the same adaptive layout, theming, and role guard the finished screens will use.
- **Localization** — English and Arabic out of the box, with full RTL support via `easy_localization`.
- **Light/dark theming** — user preference persisted locally and restored on launch, toggleable from Profile/Settings.
- **Animated UI** — consistent entrance/stagger animations and skeleton loaders powered by `flutter_animate`.

The Reader feed and post/comment data currently come from an in-app fake data source (`ReaderFakeDataSource`) that mirrors the real API's shapes exactly — see `API_CONTRACT.md` — so the Reader experience is fully explorable without a live backend, while Auth already talks to the real API (`api-1.json`).

## Brand identity

**Typography:** Playfair Display for headings, Inter for body text (via `google_fonts`).

**Voice:** Calm · Creative · Friendly · Modern · Inspirational

**Color palette:**

| Swatch | Hex | Role |
|---|---|---|
| 🟩 | `#2E6F5B` | Primary |
| 🟪 | `#A78BFA` | Secondary |
| 🔳 | `#EBDFFB` | Accent |
| ⬜ | `#FAF8F6` | Background (light) |
| ⬛ | `#2E2E2E` | Text (light) |

Role badges: Reader `#2E6F5B` · Author `#A78BFA` · Admin `#4A3B63`.

See `docs/branding/writiva_brand_board.png` for the full brand moodboard (logo, icon, imagery, and screen references). This palette is implemented in `lib/core/theme/app_colors.dart`, and the app icon across Android/iOS/web is generated from `assets/icon/icon.png` via `flutter_launcher_icons`.

## Architecture

The project follows a feature-first Clean Architecture layout:

```
lib/
├── core/            # Shared infrastructure: DI, routing, networking, theming,
│                    # error handling, auth, animations, and common widgets
└── features/        # One folder per feature (intro, auth, reader, author, admin, ...)
```

Each feature that talks to a backend follows the same three layers: a data source (fake or remote) → a repository (implementing an abstract contract, returning `Either<Failure, T>`) → a Cubit that the UI listens to. State management uses **Cubit** (`flutter_bloc`), dependency injection uses `get_it`, and error handling uses `dartz`'s `Either` for typed success/failure results instead of exceptions.

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
| Fonts | `google_fonts` |
| Vector assets | `flutter_svg` |
| Config | `flutter_dotenv` |

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK `^3.12.2`).
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Copy `.env.example` to `.env` (or create one) with the API base URL, loaded via `flutter_dotenv` at startup:
   ```
   API_BASE_URL=https://mind-whispers.laravel.cloud/api
   ```
4. Run the app:
   ```
   flutter run
   ```

Signing up or logging in requires that live API. Everything under the Reader role (feed, post detail, comments) works offline against the bundled fake data source once you're past auth.

## Localization

Translation strings live in `assets/translations/en.json` and `assets/translations/ar.json`. Add new keys to both files to keep locales in sync.

## API

`API_CONTRACT.md` is the handoff spec for the backend (auth, posts, categories, comments, profile). Auth is already live against the real endpoint set described in `api-1.json`; the rest of the contract is still a draft that the fake data source mirrors, so swapping in a real backend later only touches the data-source layer.
