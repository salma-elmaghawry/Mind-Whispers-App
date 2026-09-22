import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/post_detail/post_detail_state.dart';
import 'package:mind_whispers_app/features/reader/repository/reader_repository.dart';

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

  Future<void> retryLoadComments() async {
    await _loadComments(page: 1, replace: true);
  }

  Future<void> _loadComments({required int page, required bool replace}) async {
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
