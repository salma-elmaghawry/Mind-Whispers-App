import 'package:equatable/equatable.dart';

/// Matches the `Category` resource in API_CONTRACT.md: `{ id, name, slug }`.
class Category extends Equatable {
  final int id;
  final String name;
  final String slug;

  const Category({required this.id, required this.name, required this.slug});

  @override
  List<Object?> get props => [id, name, slug];
}
