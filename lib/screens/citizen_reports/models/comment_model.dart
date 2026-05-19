class CommentModel {
  final int id;
  final String commentText;
  final String createdAt;
  final String userName;
  final String userProfile;

  CommentModel({
    required this.id,
    required this.commentText,
    required this.createdAt,
    required this.userName,
    required this.userProfile,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      commentText: json['comment_text'] ?? "",
      createdAt: json['created_at'] ?? "",
      userName: json['user_name'] ?? "مواطن",
      userProfile: json['user_profile'] ?? "",
    );
  }
}
