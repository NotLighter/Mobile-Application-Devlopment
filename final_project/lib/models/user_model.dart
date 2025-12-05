import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String username;
  final String profilePicture;
  final String bio;
  final int followers;
  final int following;
  final int projectsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> savedProjects;
  final List<String> likedProjects;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    this.profilePicture = '',
    this.bio = '',
    this.followers = 0,
    this.following = 0,
    this.projectsCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.savedProjects = const [],
    this.likedProjects = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ==================== FROM MAP (Firestore → Dart) ====================
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      bio: map['bio'] ?? '',
      followers: map['followers']?.toInt() ?? 0,
      following: map['following']?.toInt() ?? 0,
      projectsCount: map['projectsCount']?.toInt() ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      savedProjects: List<String>.from(map['savedProjects'] ?? []),
      likedProjects: List<String>.from(map['likedProjects'] ?? []),
    );
  }

  // ==================== TO MAP (Dart → Firestore) ====================
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'profilePicture': profilePicture,
      'bio': bio,
      'followers': followers,
      'following': following,
      'projectsCount': projectsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'savedProjects': savedProjects,
      'likedProjects': likedProjects,
    };
  }

  // ==================== COPY WITH (For updating fields) ====================
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? username,
    String? profilePicture,
    String? bio,
    int? followers,
    int? following,
    int? projectsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? savedProjects,
    List<String>? likedProjects,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      projectsCount: projectsCount ?? this.projectsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      savedProjects: savedProjects ?? this.savedProjects,
      likedProjects: likedProjects ?? this.likedProjects,
    );
  }

  // ==================== HELPER METHOD ====================
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  // ==================== EMPTY USER ====================
  static UserModel empty() {
    return UserModel(
      id: '',
      email: '',
      name: '',
      username: '',
    );
  }

  // ==================== CHECK IF EMPTY ====================
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, username: $username, email: $email)';
  }
}