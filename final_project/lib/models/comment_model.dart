import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final String userProfilePicture;
  final String text;
  final int likes;
  final bool isLiked;
  final String? parentCommentId;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    this.userProfilePicture = '',
    required this.text,
    this.likes = 0,
    this.isLiked = false,
    this.parentCommentId,
    this.repliesCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ==================== FROM MAP (Firestore → Dart) ====================
  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      projectId: map['projectId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfilePicture: map['userProfilePicture'] ?? '',
      text: map['text'] ?? '',
      likes: map['likes']?.toInt() ?? 0,
      isLiked: map['isLiked'] ?? false,
      parentCommentId: map['parentCommentId'],
      repliesCount: map['repliesCount']?.toInt() ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  // ==================== TO MAP (Dart → Firestore) ====================
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'userProfilePicture': userProfilePicture,
      'text': text,
      'likes': likes,
      'parentCommentId': parentCommentId,
      'repliesCount': repliesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ==================== COPY WITH ====================
  CommentModel copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? userName,
    String? userProfilePicture,
    String? text,
    int? likes,
    bool? isLiked,
    String? parentCommentId,
    int? repliesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
      text: text ?? this.text,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== HELPER METHOD ====================
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  // ==================== TIME AGO ====================
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Check if this is a reply
  bool get isReply => parentCommentId != null;

  @override
  String toString() {
    return 'CommentModel(id: $id, userId: $userId, text: $text)';
  }
}