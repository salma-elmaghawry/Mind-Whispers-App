/// Endpoint paths. Auth matches the live OpenAPI spec in api-1.json at the
/// repo root; everything else still matches the draft in API_CONTRACT.md
/// pending its own backend work. Relative to the Dio instance's `baseUrl`
/// (configured in [DioClient] from the `API_BASE_URL` .env value) — pass to
/// Dio as-is.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth (see api-1.json)
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Profile
  static const String profile = '/profile';

  // Users (admin)
  static const String users = '/users';
  static String user(int id) => '/users/$id';

  // Categories
  static const String categories = '/categories';
  static String category(int id) => '/categories/$id';

  // Posts
  static const String posts = '/posts';
  static String post(int id) => '/posts/$id';
  static const String myPosts = '/posts/mine';
  static const String adminPosts = '/posts/admin';

  // Comments
  static String postComments(int postId) => '/posts/$postId/comments';
  static String comment(int id) => '/comments/$id';
}
