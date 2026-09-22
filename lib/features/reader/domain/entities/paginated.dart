import 'package:equatable/equatable.dart';

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
