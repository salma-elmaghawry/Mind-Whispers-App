import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/feed/feed_state.dart';
import 'package:mind_whispers_app/features/reader/repository/reader_repository.dart';

class FeedCubit extends Cubit<FeedState> {
  final ReaderRepository _repository;
  Timer? _searchDebounce;

  FeedCubit(this._repository) : super(const FeedState());

  Future<void> loadInitial() async {
    emit(state.copyWith(status: Status.loading, action: FeedAction.loadCategories));
    final categoriesResult = await _repository.getCategories();
    categoriesResult.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: FeedAction.loadCategories,
        ),
      ),
      (categories) => emit(state.copyWith(categories: categories)),
    );
    await _loadPosts(page: 1, replace: true);
  }

  Future<void> refresh() => _loadPosts(page: 1, replace: true);

  Future<void> selectCategory(int? categoryId) async {
    if (state.selectedCategoryId == categoryId) return;
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        clearSelectedCategory: categoryId == null,
      ),
    );
    await _loadPosts(page: 1, replace: true);
  }

  /// Debounced so typing doesn't fire a request per keystroke.
  void search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      emit(state.copyWith(searchQuery: query));
      _loadPosts(page: 1, replace: true);
    });
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;
    await _loadPosts(page: state.currentPage + 1, replace: false);
  }

  Future<void> _loadPosts({required int page, required bool replace}) async {
    if (replace) {
      emit(state.copyWith(status: Status.loading, action: FeedAction.loadPosts));
    } else {
      emit(state.copyWith(isLoadingMore: true));
    }

    final result = await _repository.getPosts(
      categoryId: state.selectedCategoryId,
      search: state.searchQuery,
      page: page,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: replace ? Status.failure : state.status,
          isLoadingMore: false,
          message: failure.message,
          failure: failure,
          action: FeedAction.loadPosts,
        ),
      ),
      (paginated) => emit(
        state.copyWith(
          status: Status.success,
          isLoadingMore: false,
          posts: replace ? paginated.items : [...state.posts, ...paginated.items],
          currentPage: paginated.currentPage,
          hasMore: paginated.hasMore,
          action: FeedAction.loadPosts,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
