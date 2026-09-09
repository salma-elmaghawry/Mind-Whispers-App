import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/comment.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';

enum PostDetailAction { loadPost, loadComments, addComment, deleteComment }

class PostDetailState extends BaseState {
  final Post? post;
  final List<Comment> comments;
  final int currentPage;
  final bool hasMoreComments;
  final bool isLoadingMoreComments;
  final bool isSubmittingComment;
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
    failure,
    action,
  ];
}
