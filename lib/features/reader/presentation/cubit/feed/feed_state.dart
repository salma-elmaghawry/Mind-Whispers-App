import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/category.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';

enum FeedAction { loadCategories, loadPosts }

class FeedState extends BaseState {
  final List<Category> categories;
  final String? selectedCategorySlug;
  final String searchQuery;
  final List<Post> posts;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;
  final FeedAction? action;

  const FeedState({
    super.status = Status.initial,
    super.message,
    this.categories = const [],
    this.selectedCategorySlug,
    this.searchQuery = '',
    this.posts = const [],
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
    this.action,
  });

  bool get isInitialLoad => isLoading && posts.isEmpty && categories.isEmpty;

  FeedState copyWith({
    Status? status,
    String? message,
    List<Category>? categories,
    String? selectedCategorySlug,
    bool clearSelectedCategory = false,
    String? searchQuery,
    List<Post>? posts,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    Failure? failure,
    FeedAction? action,
  }) {
    return FeedState(
      status: status ?? this.status,
      message: message,
      categories: categories ?? this.categories,
      selectedCategorySlug: clearSelectedCategory
          ? null
          : (selectedCategorySlug ?? this.selectedCategorySlug),
      searchQuery: searchQuery ?? this.searchQuery,
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: failure,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    categories,
    selectedCategorySlug,
    searchQuery,
    posts,
    currentPage,
    hasMore,
    isLoadingMore,
    failure,
    action,
  ];
}
