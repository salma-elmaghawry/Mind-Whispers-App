import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/comment.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';

enum PostDetailAction { loadPost, loadComments, addComment }

class PostDetailState extends BaseState {
  final Post? post;
  final List<Comment> comments;
  final int currentPage;
  final bool hasMoreComments;
  final bool isLoadingMoreComments;
  final bool isSubmittingComment;

  /// True when the most recent comments fetch (initial load or "load more")
  /// failed. Kept separate from [BaseState.status]/[isFailure], which only
  /// tracks the *post* fetch — without this, a failed `GET
  /// /posts/{post}/comments` left [comments] empty with no signal that
  /// anything went wrong, so the UI rendered the same "no comments yet"
  /// empty state as a post that genuinely has none.
  final bool commentsLoadFailed;
  final Failure? failure;
  final PostDetailAction? action;

  const PostDetailState({
    super.status = Status.initial,
    super.message,
    this.post,
    this.comments = const [],
    this.currentPage = 1,
    this.hasMoreComments = false,
    this.isLoadingMoreComments = false,
    this.isSubmittingComment = false,
    this.commentsLoadFailed = false,
    this.failure,
    this.action,
  });

  PostDetailState copyWith({
    Status? status,
    String? message,
    Post? post,
    List<Comment>? comments,
    int? currentPage,
    bool? hasMoreComments,
    bool? isLoadingMoreComments,
    bool? isSubmittingComment,
    bool? commentsLoadFailed,
    Failure? failure,
    PostDetailAction? action,
  }) {
    return PostDetailState(
      status: status ?? this.status,
      message: message,
      post: post ?? this.post,
      comments: comments ?? this.comments,
      currentPage: currentPage ?? this.currentPage,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      isLoadingMoreComments: isLoadingMoreComments ?? this.isLoadingMoreComments,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
      commentsLoadFailed: commentsLoadFailed ?? this.commentsLoadFailed,
      failure: failure,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    post,
    comments,
    currentPage,
    hasMoreComments,
    isLoadingMoreComments,
    isSubmittingComment,
    commentsLoadFailed,
    failure,
    action,
  ];
}
