// home_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'data_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track which posts have been "purchased"
  Map<int, bool> purchasedItems = {};
  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();

    // Initialize video controllers for posts that have video URLs
    for (int i = 0; i < AppState.posts.length; i++) {
      final post = AppState.posts[i];
      if (post.videoUrl != null) {
        final controller = VideoPlayerController.network(post.videoUrl!)
          ..initialize().then((_) {
            setState(() {}); // Refresh when video is ready
          });
        _videoControllers[i] = controller;
      }
    }
  }

  @override
  void dispose() {
    // Dispose of all video controllers
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handlePurchase(int index) {
    setState(() {
      purchasedItems[index] = true;
    });

    // Reset after animation completes
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          purchasedItems[index] = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: AppState.posts.length,
      itemBuilder: (context, index) {
        final post = AppState.posts[index];
        final isPurchased = purchasedItems[index] ?? false;
        final controller = _videoControllers[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with username
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepOrange,
                      child: Text(
                        post.username[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (post.isSponsored)
                            const Text(
                              'Sponsored',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // ✅ Image or Video Section
              if (post.videoUrl != null && controller != null)
                _buildVideoSection(controller)
              else if (post.imageUrl != null)
                _buildImageSection(post.imageUrl!)
              else
                _buildPlaceholderSection(post.isReel),

              // Action buttons row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.isLiked ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          post.toggleLikeStatus();
                        });
                      },
                    ),
                    Text('${post.likes}'),
                    const SizedBox(width: 15),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {},
                    ),
                    Text('${post.comments}'),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Shared!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  post.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              // Buy Component Button (AnimatedContainer)
              if (post.isSponsored)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isPurchased ? Colors.green : Colors.deepOrange,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: (isPurchased ? Colors.green : Colors.deepOrange)
                              .withOpacity(0.5),
                          spreadRadius: isPurchased ? 3 : 1,
                          blurRadius: isPurchased ? 10 : 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () => _handlePurchase(index),
                      child: Text(
                        isPurchased ? 'Added to Cart! ✓' : 'Buy Component',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ✅ Video widget with play/pause overlay
  Widget _buildVideoSection(VideoPlayerController controller) {
    return GestureDetector(
      onTap: () {
        setState(() {
          controller.value.isPlaying ? controller.pause() : controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: controller.value.isInitialized
                ? controller.value.aspectRatio
                : 16 / 9,
            child: controller.value.isInitialized
                ? VideoPlayer(controller)
                : const Center(child: CircularProgressIndicator()),
          ),
          if (!controller.value.isPlaying)
            const Icon(Icons.play_circle_fill, size: 70, color: Colors.white),
        ],
      ),
    );
  }

  // ✅ Image widget with network loading and error handling
  Widget _buildImageSection(String imageUrl) {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[300],
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) =>
        const Center(child: Icon(Icons.broken_image, size: 60)),
      ),
    );
  }

  // ✅ Placeholder for posts without media
  Widget _buildPlaceholderSection(bool isReel) {
    return Container(
      height: 250,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          isReel ? Icons.play_circle_filled : Icons.image,
          size: 80,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
