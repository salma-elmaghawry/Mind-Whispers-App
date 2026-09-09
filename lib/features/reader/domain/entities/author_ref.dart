import 'package:equatable/equatable.dart';

/// The small author summary embedded on a [Post] or [Comment] — matches
/// `author` in API_CONTRACT.md's Post/Comment shapes: `{ id, name, avatar_url }`.
class AuthorRef extends Equatable {
  final int id;
  final String name;
  final String? avatarUrl;

  const AuthorRef({required this.id, required this.name, this.avatarUrl});

  @override
  List<Object?> get props => [id, name, avatarUrl];
}
