import 'package:equatable/equatable.dart';

class AuthorRef extends Equatable {
  final int id;
  final String name;
  final String? avatarUrl;

  const AuthorRef({required this.id, required this.name, this.avatarUrl});

  @override
  List<Object?> get props => [id, name, avatarUrl];
}
