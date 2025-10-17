// home_screen.dart
import 'package:flutter/material.dart';
import 'data_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track which posts have been "purchased"
  Map<int, bool> purchasedItems = {};

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

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
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

              // Image placeholder
              Container(
                height: 250,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    post.isReel ? Icons.play_circle_filled : Icons.image,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                ),
              ),

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
}