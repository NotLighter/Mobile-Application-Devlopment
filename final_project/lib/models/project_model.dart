import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String userId;
  final String userName;
  final String userProfilePicture;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final List<String> images;
  final String? videoUrl;
  final List<String> materials;
  final List<String> tools;
  final List<ProjectStep> steps;
  final List<String> tags;
  int likes;
  int commentsCount;
  int views;
  int shares;
  bool isLiked;
  bool isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfilePicture = '',
    required this.title,
    required this.description,
    required this.category,
    this.difficulty = 'Medium',
    this.images = const [],
    this.videoUrl,
    this.materials = const [],
    this.tools = const [],
    this.steps = const [],
    this.tags = const [],
    this.likes = 0,
    this.commentsCount = 0,
    this.views = 0,
    this.shares = 0,
    this.isLiked = false,
    this.isSaved = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ==================== FROM MAP (Firestore → Dart) ====================
  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfilePicture: map['userProfilePicture'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      images: List<String>.from(map['images'] ?? []),
      videoUrl: map['videoUrl'],
      materials: List<String>.from(map['materials'] ?? []),
      tools: List<String>.from(map['tools'] ?? []),
      steps: (map['steps'] as List<dynamic>?)
          ?.map((step) => ProjectStep.fromMap(step))
          .toList() ??
          [],
      tags: List<String>.from(map['tags'] ?? []),
      likes: map['likes']?.toInt() ?? 0,
      commentsCount: map['commentsCount']?.toInt() ?? 0,
      views: map['views']?.toInt() ?? 0,
      shares: map['shares']?.toInt() ?? 0,
      isLiked: map['isLiked'] ?? false,
      isSaved: map['isSaved'] ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  // ==================== TO MAP (Dart → Firestore) ====================
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfilePicture': userProfilePicture,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'images': images,
      'videoUrl': videoUrl,
      'materials': materials,
      'tools': tools,
      'steps': steps.map((step) => step.toMap()).toList(),
      'tags': tags,
      'likes': likes,
      'commentsCount': commentsCount,
      'views': views,
      'shares': shares,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ==================== COPY WITH ====================
  ProjectModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfilePicture,
    String? title,
    String? description,
    String? category,
    String? difficulty,
    List<String>? images,
    String? videoUrl,
    List<String>? materials,
    List<String>? tools,
    List<ProjectStep>? steps,
    List<String>? tags,
    int? likes,
    int? commentsCount,
    int? views,
    int? shares,
    bool? isLiked,
    bool? isSaved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      materials: materials ?? this.materials,
      tools: tools ?? this.tools,
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      views: views ?? this.views,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
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

  // ==================== FORMATTED TIME ====================
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

  @override
  String toString() {
    return 'ProjectModel(id: $id, title: $title, userId: $userId)';
  }
}

// ==================== PROJECT STEP CLASS ====================
class ProjectStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? imageUrl;

  ProjectStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  factory ProjectStep.fromMap(Map<String, dynamic> map) {
    return ProjectStep(
      stepNumber: map['stepNumber']?.toInt() ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}