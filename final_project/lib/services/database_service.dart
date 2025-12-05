import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/product_model.dart';
import '../models/comment_model.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== COLLECTION REFERENCES ====================
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _projectsCollection => _firestore.collection('projects');
  CollectionReference get _productsCollection => _firestore.collection('products');

  // ==================== USER OPERATIONS ====================

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final query = await _usersCollection
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromMap(
          query.docs.first.data() as Map<String, dynamic>,
          query.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by username: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(userId).update(data);
      return true;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final snapshot = await _usersCollection
          .where('username', isGreaterThanOrEqualTo: queryLower)
          .where('username', isLessThanOrEqualTo: '$queryLower\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // ==================== PROJECT OPERATIONS ====================

  // Get all projects (paginated)
  Future<List<ProjectModel>> getProjects({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _projectsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting projects: $e');
      return [];
    }
  }

  // Get projects by user ID
  Future<List<ProjectModel>> getProjectsByUser(String userId) async {
    try {
      final snapshot = await _projectsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting user projects: $e');
      return [];
    }
  }

  // Get projects by category
  Future<List<ProjectModel>> getProjectsByCategory(String category) async {
    try {
      final snapshot = await _projectsCollection
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting projects by category: $e');
      return [];
    }
  }

  // Get single project by ID
  Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      final doc = await _projectsCollection.doc(projectId).get();
      if (doc.exists) {
        return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting project: $e');
      return null;
    }
  }

  // Create project
  Future<String?> createProject(ProjectModel project) async {
    try {
      final docRef = await _projectsCollection.add(project.toMap());

      // Update user's project count
      await _usersCollection.doc(project.userId).update({
        'projectsCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating project: $e');
      return null;
    }
  }

  // Update project
  Future<bool> updateProject(ProjectModel project) async {
    try {
      final data = project.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _projectsCollection.doc(project.id).update(data);
      return true;
    } catch (e) {
      debugPrint('Error updating project: $e');
      return false;
    }
  }

  // Delete project
  Future<bool> deleteProject(String projectId, String userId) async {
    try {
      await _projectsCollection.doc(projectId).delete();

      // Update user's project count
      await _usersCollection.doc(userId).update({
        'projectsCount': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      debugPrint('Error deleting project: $e');
      return false;
    }
  }

  // Like project
  Future<bool> likeProject(String projectId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Add to user's liked projects
      batch.update(_usersCollection.doc(userId), {
        'likedProjects': FieldValue.arrayUnion([projectId]),
      });

      // Increment project likes
      batch.update(_projectsCollection.doc(projectId), {
        'likes': FieldValue.increment(1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error liking project: $e');
      return false;
    }
  }

  // Unlike project
  Future<bool> unlikeProject(String projectId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Remove from user's liked projects
      batch.update(_usersCollection.doc(userId), {
        'likedProjects': FieldValue.arrayRemove([projectId]),
      });

      // Decrement project likes
      batch.update(_projectsCollection.doc(projectId), {
        'likes': FieldValue.increment(-1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error unliking project: $e');
      return false;
    }
  }

  // Save project
  Future<bool> saveProject(String projectId, String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'savedProjects': FieldValue.arrayUnion([projectId]),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving project: $e');
      return false;
    }
  }

  // Unsave project
  Future<bool> unsaveProject(String projectId, String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'savedProjects': FieldValue.arrayRemove([projectId]),
      });
      return true;
    } catch (e) {
      debugPrint('Error unsaving project: $e');
      return false;
    }
  }

  // Increment view count
  Future<void> incrementProjectViews(String projectId) async {
    try {
      await _projectsCollection.doc(projectId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing views: $e');
    }
  }

  // Search projects
  Future<List<ProjectModel>> searchProjects(String query) async {
    try {
      final queryLower = query.toLowerCase();

      // Search by title
      final snapshot = await _projectsCollection
          .orderBy('title')
          .startAt([queryLower])
          .endAt(['$queryLower\uf8ff'])
          .limit(30)
          .get();

      return snapshot.docs.map((doc) {
        return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error searching projects: $e');
      return [];
    }
  }

  // ==================== COMMENT OPERATIONS ====================

  // Get comments for a project
  Future<List<CommentModel>> getComments(String projectId) async {
    try {
      final snapshot = await _projectsCollection
          .doc(projectId)
          .collection('comments')
          .where('parentCommentId', isNull: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return CommentModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting comments: $e');
      return [];
    }
  }

  // Get replies for a comment
  Future<List<CommentModel>> getReplies(String projectId, String commentId) async {
    try {
      final snapshot = await _projectsCollection
          .doc(projectId)
          .collection('comments')
          .where('parentCommentId', isEqualTo: commentId)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        return CommentModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting replies: $e');
      return [];
    }
  }

  // Add comment
  Future<String?> addComment(CommentModel comment) async {
    try {
      final docRef = await _projectsCollection
          .doc(comment.projectId)
          .collection('comments')
          .add(comment.toMap());

      // Increment comment count
      await _projectsCollection.doc(comment.projectId).update({
        'commentsCount': FieldValue.increment(1),
      });

      // If this is a reply, increment parent's reply count
      if (comment.parentCommentId != null) {
        await _projectsCollection
            .doc(comment.projectId)
            .collection('comments')
            .doc(comment.parentCommentId)
            .update({
          'repliesCount': FieldValue.increment(1),
        });
      }

      return docRef.id;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return null;
    }
  }

  // Delete comment
  Future<bool> deleteComment(String projectId, String commentId) async {
    try {
      await _projectsCollection
          .doc(projectId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Decrement comment count
      await _projectsCollection.doc(projectId).update({
        'commentsCount': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }

  // ==================== PRODUCT OPERATIONS ====================

  // Get all products (paginated)
  Future<List<ProductModel>> getProducts({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _productsCollection
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      return [];
    }
  }

  // Get products by seller
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _productsCollection
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting seller products: $e');
      return [];
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _productsCollection
          .where('category', isEqualTo: category)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  // Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  // Create product
  Future<String?> createProduct(ProductModel product) async {
    try {
      final docRef = await _productsCollection.add(product.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating product: $e');
      return null;
    }
  }

  // Update product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      final data = product.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _productsCollection.doc(product.id).update(data);
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final queryLower = query.toLowerCase();

      final snapshot = await _productsCollection
          .where('isAvailable', isEqualTo: true)
          .orderBy('title')
          .startAt([queryLower])
          .endAt(['$queryLower\uf8ff'])
          .limit(30)
          .get();

      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // Toggle favorite product
  Future<bool> toggleFavoriteProduct(String productId, String userId, bool isFavorited) async {
    try {
      await _productsCollection.doc(productId).update({
        'favorites': FieldValue.increment(isFavorited ? -1 : 1),
      });
      return true;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  // ==================== FOLLOW OPERATIONS ====================

  // Follow user
  Future<bool> followUser(String currentUserId, String targetUserId) async {
    try {
      final batch = _firestore.batch();

      // Add to current user's following
      batch.set(
        _usersCollection.doc(currentUserId).collection('following').doc(targetUserId),
        {'followedAt': FieldValue.serverTimestamp()},
      );

      // Add to target user's followers
      batch.set(
        _usersCollection.doc(targetUserId).collection('followers').doc(currentUserId),
        {'followedAt': FieldValue.serverTimestamp()},
      );

      // Update counts
      batch.update(_usersCollection.doc(currentUserId), {
        'following': FieldValue.increment(1),
      });

      batch.update(_usersCollection.doc(targetUserId), {
        'followers': FieldValue.increment(1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error following user: $e');
      return false;
    }
  }

  // Unfollow user
  Future<bool> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      final batch = _firestore.batch();

      // Remove from current user's following
      batch.delete(
        _usersCollection.doc(currentUserId).collection('following').doc(targetUserId),
      );

      // Remove from target user's followers
      batch.delete(
        _usersCollection.doc(targetUserId).collection('followers').doc(currentUserId),
      );

      // Update counts
      batch.update(_usersCollection.doc(currentUserId), {
        'following': FieldValue.increment(-1),
      });

      batch.update(_usersCollection.doc(targetUserId), {
        'followers': FieldValue.increment(-1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error unfollowing user: $e');
      return false;
    }
  }

  // Check if following
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      final doc = await _usersCollection
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking follow status: $e');
      return false;
    }
  }

  // Get user's followers
  Future<List<String>> getFollowers(String userId) async {
    try {
      final snapshot = await _usersCollection
          .doc(userId)
          .collection('followers')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error getting followers: $e');
      return [];
    }
  }

  // Get user's following
  Future<List<String>> getFollowing(String userId) async {
    try {
      final snapshot = await _usersCollection
          .doc(userId)
          .collection('following')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error getting following: $e');
      return [];
    }
  }
}