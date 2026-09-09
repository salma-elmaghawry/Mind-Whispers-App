# Mind Whispers — API Contract (v1 draft)

Handoff spec for the backend team building the Laravel API alongside the Flutter UI. Scope matches the Core-only MVP: auth & roles, posts, categories, comments, profile. Stripe subscriptions, premium/free gating, and newsletters are **Phase 2** and intentionally excluded here — see the note at the bottom.

Flutter ships against fake datasources that mirror these shapes exactly, so when a real endpoint goes live, only the datasource implementation is swapped — no UI or Cubit changes.

> **Auth is live.** The `/auth/*` section below is superseded by the real OpenAPI spec at `api-1.json` (repo root) and is already integrated in `lib/features/auth/`. It differs from the original draft in a few ways: no `/v1` prefix on the base URL, a required `device_name` per request (Sanctum, one token per device), `remember` for a 30-day vs. 24-hour token, and `roles` as an array rather than a single `role` string. Posts/Categories/Comments/Profile/Users below are still the draft — not yet implemented against a real backend.

## Conventions

- Base URL: `/api/v1` for the draft endpoints below. The live auth server is `https://mind-whispers.laravel.cloud/api` (no `/v1` — see api-1.json).
- Auth: Laravel Sanctum, bearer token — `Authorization: Bearer {token}`
- Content type: `application/json`
- Roles: `admin` | `author` | `reader`
- Pagination: Laravel's default paginator shape (see envelope below)

### Success envelope

Single resource:
```json
{ "data": { /* resource */ } }
```

Paginated list:
```json
{
  "data": [ /* resources */ ],
  "meta": { "current_page": 1, "per_page": 15, "total": 42, "last_page": 3 }
}
```

### Error envelope

```json
{
  "message": "The given data was invalid.",
  "errors": { "email": ["The email field is required."] }
}
```

| Status | Meaning |
|---|---|
| 401 | Not authenticated (missing/expired token) |
| 403 | Authenticated but role doesn't allow this action |
| 422 | Validation failure (`errors` populated) |
| 404 | Resource not found |
| 500 | Server error |

---

## Resource shapes

**User** (draft shape below — the real, live shape from api-1.json's `UserResource` is `{ id, name, email, email_verified_at, roles: string[], created_at }`; no `avatar_url`/`bio`/`is_active` yet)
```json
{
  "id": 1,
  "name": "Maryam Eid",
  "email": "author@example.com",
  "role": "author",
  "avatar_url": "https://.../avatar.jpg",
  "bio": "Writes about product design.",
  "is_active": true,
  "created_at": "2026-09-01T10:00:00Z"
}
```

**Category**
```json
{ "id": 3, "name": "Product", "slug": "product" }
```

**Post**
```json
{
  "id": 42,
  "title": "On writing slowly",
  "slug": "on-writing-slowly",
  "body": "<p>...</p>",
  "excerpt": "A short teaser...",
  "cover_image_url": "https://.../cover.jpg",
  "status": "published",
  "category": { "id": 3, "name": "Product", "slug": "product" },
  "author": { "id": 1, "name": "Maryam Eid", "avatar_url": "https://.../avatar.jpg" },
  "comments_count": 5,
  "created_at": "2026-09-10T09:00:00Z",
  "published_at": "2026-09-10T09:15:00Z"
}
```

**Comment**
```json
{
  "id": 100,
  "body": "Great read!",
  "author": { "id": 7, "name": "A Reader", "avatar_url": null },
  "post_id": 42,
  "created_at": "2026-09-10T12:00:00Z"
}
```

---

## Endpoints

### Auth — live (see api-1.json, not the draft columns below)

| Method | Path | Auth | Body | Returns |
|---|---|---|---|---|
| POST | `/auth/register` | – | `name, email, password, password_confirmation, device_name` | 201 `{ user, token, expires_at }` |
| POST | `/auth/login` | – | `email, password, device_name, remember?` | 200 `{ user, token, expires_at }` |
| POST | `/auth/logout` | ✓ | `device_name` (must match the one used to log in) | `{ message }` |
| GET | `/auth/me` | ✓ | – | `{ user }` |

`device_name` is a stable per-install identifier (the app generates and persists a UUID — see `DeviceIdProvider`). Without `remember: true` the token expires in 24 hours; with it, 30 days. A new account's `email_verified_at` stays `null` until the verification email's link is opened, but the app doesn't block usage on that.

### Profile

| Method | Path | Auth | Body | Returns |
|---|---|---|---|---|
| PATCH | `/profile` | ✓ (self) | `name?, bio?, avatar?` | `user` |

### Users (admin)

| Method | Path | Auth | Query/Body | Returns |
|---|---|---|---|---|
| GET | `/users` | admin | `?role=&search=&page=` | paginated `user[]` |
| GET | `/users/{id}` | admin | – | `user` |
| PATCH | `/users/{id}` | admin | `role?, is_active?` | `user` |

### Categories

| Method | Path | Auth | Body | Returns |
|---|---|---|---|---|
| GET | `/categories` | – | – | `category[]` |
| POST | `/categories` | admin | `name` | `category` |
| PATCH | `/categories/{id}` | admin | `name` | `category` |
| DELETE | `/categories/{id}` | admin | – | 204 |

### Posts

| Method | Path | Auth | Query/Body | Returns |
|---|---|---|---|---|
| GET | `/posts` | – | `?category_id=&search=&page=` (published only) | paginated `post[]` |
| GET | `/posts/{id}` | – | – | `post` |
| GET | `/posts/mine` | author | `?status=draft\|published&page=` | paginated `post[]` (own) |
| POST | `/posts` | author | `title, body, category_id, cover_image, status` | `post` |
| PATCH | `/posts/{id}` | owner or admin | any post field | `post` |
| DELETE | `/posts/{id}` | owner or admin | – | 204 |
| GET | `/posts/admin` | admin | `?status=&category_id=&author_id=&page=` (all statuses/authors) | paginated `post[]` |

### Comments

| Method | Path | Auth | Body | Returns |
|---|---|---|---|---|
| GET | `/posts/{id}/comments` | – | `?page=` | paginated `comment[]` |
| POST | `/posts/{id}/comments` | ✓ | `body` | `comment` |
| DELETE | `/comments/{id}` | owner, post author, or admin | – | 204 |

---

## Out of scope for this handoff (Phase 2)

Not part of the 15-day core MVP — flag if the backend wants to stub these early, but the Flutter app will not call them yet:

- Stripe checkout + subscription management (`/subscriptions/*`)
- Premium vs free post gating (`Post.is_premium`, paywall responses)
- Newsletters (`/newsletters/*`)
- Admin analytics/metrics endpoints (view counts, charts data)
