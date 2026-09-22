
class ApiEndpoints {
  ApiEndpoints._();

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  static const String posts = '/posts';
  static String post(int id) => '/posts/$id';
  static const String postsManage = '/posts/manage';
  static String postComments(int postId) => '/posts/$postId/comments';

  static const String categories = '/categories';
  static String category(int id) => '/categories/$id';

  static const String tags = '/tags';
  static String tag(int id) => '/tags/$id';

  static const String users = '/users';
  static String user(int id) => '/users/$id';
  static const String roles = '/roles';
}
