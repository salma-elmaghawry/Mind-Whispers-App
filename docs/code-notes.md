# Code notes

Background that used to live in code comments. The code carries no explanatory comments, so anything non-obvious is recorded here.

## Routing

- `AppRouter.generateRoute` returns `null` for anything it does not match. Flutter probes `/` before the real `initialRoute` (`/splash`). A real route returned for that probe would sit under the splash screen and resurface on back navigation.
- `AppRouter.onUnknownRoute` is the only "page not found" handler, so it only runs for genuine unmatched navigations.
- The role guard reads the `user_role` key from SharedPreferences directly, not `AuthCubit.state`. Route generation is synchronous and must not depend on the cubit having rebuilt. `AuthRepositoryImpl` keeps the key in sync on every login, register, me and logout.
- New screens are registered in the `generateRoute` switch. Arguments travel in `settings.arguments`.

Route arguments:

| Route | Argument |
| --- | --- |
| `Routes.resetPassword` | `String` email the OTP was sent to |
| `Routes.postDetail` | `int` post id |
| `Routes.comingSoon` | `ComingSoonArgs` |

## Auth and roles

- The API reports roles as a list on `UserResource.roles`. `AppRole` is the app's single-role model. `AppRole.fromRoles` picks the highest-privilege recognised role. `AppRole.fromWire` reads back the single value the app itself persists.
- Laravel/Spatie gives new accounts the `subscriber` role. It is treated as an alias of `reader` so those accounts land on the reader home instead of `Routes.unauthorized`.
- `AuthCubit.checkAuthStatus` runs once at boot from the splash screen. A Sanctum token can outlive the app (24h by default, 30 days with `remember`), so it is confirmed against `/auth/me` first.
- `BaseState` has only initial, loading, success and failure. "No session yet" is `Status.failure` with no user and no message. It is an expected outcome on every signed-out launch, so listeners must not show it as an error.
- Registration: a 422 on `email` that survived client-side format validation is Laravel's uniqueness rule, so the friendlier pre-translated failure is shown.
- Login: Laravel attaches "these credentials do not match" to `email`, so a 422 on that field means invalid credentials.
- Logout is a local intent as much as a server call. If the revoke request fails, the session is still forgotten on the device. The server-side token then expires naturally.
- Password reset is two steps. Step 1 emails a 6-digit OTP valid for 10 minutes. Unknown emails and resend throttling both return a 422 on `email`. Step 2 sets the new password. It does not sign the user in, so the flow drops the recovery stack and lands on login.
- On step 2 a 422 can land on `otp`, `email` or `password`. Field errors are kept intact. `otp` and `password` show inline. Anything else goes to a snackbar. Errors are cleared on every submit.
- `AuthCubit` is app-wide and the forgot-password screen stays in the stack under the reset screen. The reset screen's resend also emits `forgotPassword`. The forgot-password screen reacts only while it is on top, so a resend does not push a second reset screen.

## Networking

- The live API has no `/v1` segment, unlike the draft in `API_CONTRACT.md`. See the `servers` entry in `api-1.json`.
- The Sanctum token key lives in the network layer so the auth feature and `DioClient` agree on it without a dependency between them.
- List endpoints return a Laravel paginator envelope: `data` plus `meta` with `current_page`, `per_page`, `total`, `last_page`. The OpenAPI file documents a bare array, but the live backend sends the envelope, and the app follows the backend.
- `getComments` only surfaces the `data` array. "No more pages" is inferred from receiving fewer items than a full page.

## Error handling

- `ErrorMapper` parses the Laravel error envelope (`message` plus `errors`). A 422 carries field-level errors. Every other status carries the server message when present.
- Unexpected exceptions such as a bad model cast or a null field fall into the generic `unexpected_error` branch. In debug builds the real exception is logged there so it stays diagnosable.

## API models

- `PostResource` always has `excerpt`, `featured_image`, `status`, `is_premium`, `published_at` and `created_at` as keys. Some are nullable. `author`, `categories` and `comments_count` are guaranteed only on the single-post endpoints, so they are parsed defensively.
- `Post.content` is `null` for a premium post when the caller has no premium access. The API sends `null`, not a 403. The UI renders a locked state (`Post.isLocked`). `excerpt` is always shown.
- `Post.coverImageUrl` maps from the wire field `featured_image`. `Post.primaryCategory` is the first category, used wherever there is room for one badge.
- `CommentResource` has no `post_id`. Callers track the post from the endpoint they used. Replies nest one level only. A reply's `parent_id` must point at a top-level comment on the same post.
- `AuthorRef` is the small author summary embedded on posts and comments: `id`, `name`, `avatar_url`.
- Login and register return `user`, `token` and `expires_at` at the top level, not wrapped in `data`.
- `HexColor.toColor` on `String` accepts `#RRGGBB` or `#AARRGGBB` and fall back to a default so a malformed API colour never crashes the UI.

## Reader feature

- Post detail keeps a separate `commentsLoadFailed` flag. `BaseState.status` only tracks the post fetch. Without the flag, a failed comments fetch looked the same as a post with no comments.
- The comments loading flag is set for the initial load too. Otherwise a post with comments briefly flashed the "no comments yet" empty state.
- `retryLoadComments` exists separately from `loadMoreComments` because that method guards on `hasMoreComments`, which is still false after a first failed fetch.
- Comments are posted as whoever the Bearer token identifies. Every route into post detail is behind sign-in.
- The feed search is debounced so typing does not fire a request per keystroke. `FeedState.isInitialLoad` is true before categories and posts have ever resolved, and drives full-screen skeletons.
- Explore, Write and Notifications have no backend endpoints yet. Their lists are static sample data and are not wired to `ReaderRepository`. Tapping a notification only flips local read state.
- Post like counts are a deterministic per-session value seeded from the post id. The API has no likes concept yet. Nothing is persisted.
- Write and the other tabs render inside `AdaptiveScaffold`, which already draws the shared app bar. They must not add their own `AppBar`.
- The explore shelf uses `IntrinsicHeight` instead of a fixed height so it survives Arabic text, font-scale settings and copy edits without clipping.
- The comment composer submits only through the send button. `AppTextField` has no field-submitted callback, so the keyboard action key stays at its default.
- The comment tile has no delete action because the API has no delete-comment endpoint.

## Widgets

- `RichHtmlText` renders a small subset of HTML: headings, paragraphs, blockquotes, bold, italic, links and lists. It is hand-written on purpose. `flutter_html` 3.0.0 does not compile against this SDK because of a `csslib`/`html` conflict that only `flutter test` catches. `flutter_widget_from_html` pulls in about 55 transitive packages for content that needs none of them.
- Bold, italic and link styling in `RichHtmlText` layer on top of the passed-in style. This is the one place that is allowed to use `copyWith` for weight, style and decoration.
- `AdaptiveScaffold` is a bottom bar on phones and a `NavigationRail` on wide screens. A destination with its own icon widget, such as the raised compose "+" circle, is drawn larger and lifted. It still carries a label.
- `AppButton` is the one button for every screen. `isLoading` swaps the label for a spinner and disables tap.
- `AppCard` is the themed card with built-in tap feedback.
- `ErrorStateView` takes `state.message`, already localised by `ErrorMapper`, never a raw exception string.
- `UnauthorizedScreen` mirrors a 403. The session is still valid, so its "OK" returns to the user's own home instead of signing out.
- `ComingSoonScreen` is the destination for taps on features that are not built yet, instead of a snackbar that is easy to miss.
- `RoleHomePlaceholder` is the shared shell for the role homes until each gets real screens.
- `formatRelativeDate` shows "Today", "Yesterday", or "N days ago" within the last week, otherwise a localised absolute date.

## Text styles and tests

- Widgets use `AppTextStyles` only. `AppTheme` still builds its `textTheme` from it so Material buttons and text fields match.
- Primary text color is inherited from the theme. Secondary text uses `AppTextStyles.x.secondary(context)`.
- Widget tests must wrap the app in `ScreenUtilInit` with a `designSize` equal to the test surface, because `AppTextStyles` uses `.sp`.

## Misc

- `DeviceIdProvider` builds a version 4 UUID: byte 6 high nibble is `0x4`, byte 8 top bits are `10`.
- `AppColors` keeps the like-heart red outside the read/write brand pair because "liked" is a universal red, not a role colour.
- Admin and author homes are placeholders until those experiences land.
