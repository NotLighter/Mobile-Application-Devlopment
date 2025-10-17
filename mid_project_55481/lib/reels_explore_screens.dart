// reels_explore_screens.dart
import 'package:flutter/material.dart';
import 'data_models.dart';

// REELS SCREEN - Explicit Animation
class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set up AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Set up Tween for scaling
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start repeating animation
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reelPosts = AppState.posts.where((post) => post.isReel).toList();

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Main reel content with AnimatedBuilder
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 100,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      reelPosts.isNotEmpty
                          ? reelPosts[0].description
                          : 'DIY Reels',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Side action buttons
          Positioned(
            right: 10,
            bottom: 100,
            child: Column(
              children: [
                _buildActionButton(Icons.favorite_border, '${reelPosts.isNotEmpty ? reelPosts[0].likes : 0}'),
                const SizedBox(height: 20),
                _buildActionButton(Icons.comment, '${reelPosts.isNotEmpty ? reelPosts[0].comments : 0}'),
                const SizedBox(height: 20),
                _buildActionButton(Icons.share, 'Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// EXPLORE SCREEN - AnimatedCrossFade
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool showTrending = true;

  final List<String> trendingProjects = [
    'Pallet Furniture Makeover',
    'Smart Home Lighting Install',
    'Vertical Garden Wall',
    'Concrete Countertops DIY',
    'Upcycled Window Frames',
  ];

  final List<String> newTools = [
    'Cordless Impact Driver',
    'Laser Level Pro',
    'Multi-Tool Oscillator',
    'Router Table Combo',
    'Digital Caliper Set',
  ];

  Widget _buildListView(List<String> items, IconData icon) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepOrange,
              child: Icon(icon, color: Colors.white),
            ),
            title: Text(
              items[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              showTrending ? 'Trending Now' : 'New Arrival',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Filter buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      showTrending ? Colors.deepOrange : Colors.grey[300],
                      foregroundColor:
                      showTrending ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        showTrending = true;
                      });
                    },
                    child: const Text('Trending Projects'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      !showTrending ? Colors.deepOrange : Colors.grey[300],
                      foregroundColor:
                      !showTrending ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        showTrending = false;
                      });
                    },
                    child: const Text('New Tools'),
                  ),
                ),
              ],
            ),
          ),

          // AnimatedCrossFade between two views
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 500),
            crossFadeState: showTrending
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildListView(trendingProjects, Icons.trending_up),
            secondChild: _buildListView(newTools, Icons.construction),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}