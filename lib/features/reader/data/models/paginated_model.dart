import 'package:mind_whispers_app/features/reader/domain/entities/paginated.dart';

/// Parses the Laravel paginator envelope: `{ data: [...], meta: {
/// current_page, per_page, total, last_page } }`. [fromJson] takes the item
/// mapper since `T` varies per endpoint.
class PaginatedModel<T> {
  final List<T> items;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginatedModel({
    required this.items,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginatedModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final meta = json['meta'] as Map<String, dynamic>?;
    return PaginatedModel(
      items: (json['data'] as List<dynamic>? ?? const [])
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      currentPage: meta?['current_page'] as int? ?? 1,
      perPage: meta?['per_page'] as int? ?? 0,
      total: meta?['total'] as int? ?? 0,
      lastPage: meta?['last_page'] as int? ?? 1,
    );
  }

  Paginated<E> toEntity<E>(E Function(T) toEntityT) {
    return Paginated<E>(
      items: items.map(toEntityT).toList(),
      currentPage: currentPage,
      perPage: perPage,
      total: total,
      lastPage: lastPage,
    );
  }
}
