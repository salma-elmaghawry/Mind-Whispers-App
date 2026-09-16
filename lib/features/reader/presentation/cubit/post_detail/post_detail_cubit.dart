import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/post_detail/post_detail_state.dart';
import 'package:mind_whispers_app/features/reader/repository/reader_repository.dart';

/// `GET /posts/{post}/comments` (see api-1.json) pages via `?page=` and, on
/// the live API, wraps its array in a Laravel paginator (`data` + `links` +
/// `meta`) — but [ReaderRemoteDataSource.getComments] only surfaces the
/// `data` array, not `meta.total`/`meta.last_page`, so "no more pages" is
/// inferred here from getting back fewer than a full page instead.
const int _commentsPageSize = 10;

class PostDetailCubit extends Cubit<PostDetailState> {
  final ReaderRepository _repository;
  final int postId;

  PostDetailCubit(this._repository, this.postId) : super(const PostDetailState());

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading, action: PostDetailAction.loadPost));
    final result = await _repository.getPost(postId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: PostDetailAction.loadPost,
        ),
      ),
      (post) => emit(
        state.copyWith(status: Status.success, post: post, action: PostDetailAction.loadPost),
      ),
    );
    if (state.isSuccess) {
      await _loadComments(page: 1, replace: true);
    }
  }

  Future<void> loadMoreComments() async {
    if (state.isLoadingMoreComments || !state.hasMoreComments) return;
    await _loadComments(page: state.currentPage + 1, replace: false);
  }

  /// Re-runs the initial (page 1) comments fetch after [commentsLoadFailed]
  /// — exposed separately from [loadMoreComments] because that guards on
  /// [PostDetailState.hasMoreComments], which is still false the first time
  /// a fetch fails and would otherwise make a retry a no-op.
  Future<void> retryLoadComments() async {
    await _loadComments(page: 1, replace: true);
  }

  Future<void> _loadComments({required int page, required bool replace}) async {
    // Set unconditionally, including for the initial (`replace: true`) load:
    // the screen treats "empty comments" and "still loading comments" as
    // the same `!isLoadingMoreComments` check, so leaving this false during
    // the first fetch made a post with real comments flash an incorrect
    // "no comments yet" empty state before they arrived.
    emit(state.copyWith(isLoadingMoreComments: true));
    final result = await _repository.getComments(postId, page: page);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMoreComments: false,
          commentsLoadFailed: true,
          message: failure.message,
          failure: failure,
          action: PostDetailAction.loadComments,
        ),
      ),
      (comments) => emit(
        state.copyWith(
          comments: replace ? comments : [...state.comments, ...comments],
          currentPage: page,
          hasMoreComments: comments.length >= _commentsPageSize,
          isLoadingMoreComments: false,
          commentsLoadFailed: false,
          action: PostDetailAction.loadComments,
        ),
      ),
    );
  }

  /// The comment's author is whoever the request's Bearer token identifies
  /// — reachable screens are always behind sign-in, so there's no signed-out
  /// path to guard against here.
  Future<void> addComment({required String content, int? parentId}) async {
    emit(state.copyWith(isSubmittingComment: true, action: PostDetailAction.addComment));
    final result = await _repository.addComment(postId: postId, content: content, parentId: parentId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmittingComment: false,
          message: failure.message,
          failure: failure,
          action: PostDetailAction.addComment,
        ),
      ),
      (comment) => emit(
        state.copyWith(
          isSubmittingComment: false,
          comments: [...state.comments, comment],
          post: state.post?.copyWith(commentsCount: state.post!.commentsCount + 1),
          action: PostDetailAction.addComment,
        ),
      ),
    );
  }
}
