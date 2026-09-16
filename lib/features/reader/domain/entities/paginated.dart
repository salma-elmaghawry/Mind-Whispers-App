import 'package:equatable/equatable.dart';

/// Matches the Laravel paginator envelope the live API actually returns for
/// list endpoints (`GET /posts`, `GET /categories`): `{ data: [...], meta:
/// { current_page, per_page, total, last_page } }` — confirmed by running
/// the app against https://mind-whispers.laravel.cloud/api. Notably,
/// api-1.json's OpenAPI schema documents these same endpoints as returning
/// a bare array; the live backend doesn't match its own spec here, so this
/// app follows what it actually sends.
class Paginated<T> extends Equatable {
  final List<T> items;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const Paginated({
    required this.items,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [items, currentPage, perPage, total, lastPage];
}
