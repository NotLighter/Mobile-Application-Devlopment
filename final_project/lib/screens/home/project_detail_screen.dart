import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../models/comment_model.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../main.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoadingComments = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _incrementViews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final comments = await databaseService.getComments(widget.project.id);

      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _incrementViews() async {
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      await databaseService.incrementProjectViews(widget.project.id);
    } catch (e) {
      debugPrint('Error incrementing views: $e');
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final currentUser = await authService.getCurrentUserData();

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to comment')),
        );
        return;
      }

      final comment = CommentModel(
        id: '',
        projectId: widget.project.id,
        userId: currentUser.id,
        userName: currentUser.name,
        userProfilePicture: currentUser.profilePicture,
        text: text,
      );

      final commentId = await databaseService.addComment(comment);

      if (commentId != null) {
        setState(() {
          _comments.insert(0, comment.copyWith(id: commentId));
        });
        _commentController.clear();

        // Update comment count in AppState
        Provider.of<AppState>(context, listen: false)
            .incrementCommentCount(widget.project.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.project.images.isNotEmpty
                  ? Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.project.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.project.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                  // Image Indicator
                  if (widget.project.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.project.images.length,
                              (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentImageIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 64),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  widget.project.isSaved ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () {
                  Provider.of<AppState>(context, listen: false)
                      .toggleSave(widget.project.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: widget.project.userProfilePicture.isNotEmpty
                            ? NetworkImage(widget.project.userProfilePicture)
                            : null,
                        child: widget.project.userProfilePicture.isEmpty
                            ? Text(
                          widget.project.userName.isNotEmpty
                              ? widget.project.userName[0].toUpperCase()
                              : 'U',
                        )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.project.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.project.timeAgo,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Follow'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.project.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stats Row
                  Row(
                    children: [
                      _buildStat(Icons.favorite, '${widget.project.likes}'),
                      const SizedBox(width: 16),
                      _buildStat(Icons.chat_bubble, '${widget.project.commentsCount}'),
                      const SizedBox(width: 16),
                      _buildStat(Icons.visibility, '${widget.project.views}'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category and Difficulty
                  Row(
                    children: [
                      _buildChip(widget.project.category, Colors.blue),
                      const SizedBox(width: 8),
                      _buildChip(widget.project.difficulty, _getDifficultyColor()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.project.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Materials Section
                  if (widget.project.materials.isNotEmpty) ...[
                    _buildSectionHeader('Materials', Icons.inventory),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.project.materials.map((material) {
                        return Chip(
                          label: Text(material),
                          backgroundColor: Colors.green[50],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Tools Section
                  if (widget.project.tools.isNotEmpty) ...[
                    _buildSectionHeader('Tools', Icons.build),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.project.tools.map((tool) {
                        return Chip(
                          label: Text(tool),
                          backgroundColor: Colors.orange[50],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Steps Section
                  if (widget.project.steps.isNotEmpty) ...[
                    _buildSectionHeader('Steps', Icons.format_list_numbered),
                    const SizedBox(height: 8),
                    ...widget.project.steps.map((step) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                child: Text('${step.stepNumber}'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(step.description),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Comments Section
                  _buildSectionHeader('Comments', Icons.chat),
                  const SizedBox(height: 8),

                  // Comment Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _addComment,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Comments List
                  if (_isLoadingComments)
                    const Center(child: CircularProgressIndicator())
                  else if (_comments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No comments yet. Be the first!',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return _buildCommentItem(comment);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Like FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<AppState>(context, listen: false)
              .toggleLike(widget.project.id);
        },
        child: Icon(
          widget.project.isLiked ? Icons.favorite : Icons.favorite_border,
          color: widget.project.isLiked ? Colors.red : null,
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.project.difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            backgroundImage: comment.userProfilePicture.isNotEmpty
                ? NetworkImage(comment.userProfilePicture)
                : null,
            child: comment.userProfilePicture.isEmpty
                ? Text(
              comment.userName.isNotEmpty
                  ? comment.userName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(fontSize: 12),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}