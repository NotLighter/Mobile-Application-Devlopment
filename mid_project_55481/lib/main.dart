// main.dart
import 'package:flutter/material.dart';
import 'data_models.dart';
import 'home_screen.dart';
import 'recipes_screen.dart';
import 'reels_explore_screens.dart';
import 'user_interaction_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIY Social Hub',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DIYSocialHub(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DIYSocialHub extends StatefulWidget {
  const DIYSocialHub({Key? key}) : super(key: key);

  @override
  State<DIYSocialHub> createState() => _DIYSocialHubState();
}

class _DIYSocialHubState extends State<DIYSocialHub> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReelsScreen(),
    const CreateScreen(),
    const ExploreScreen(),
    const RecipesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize interaction states using a loop
    for (var post in AppState.posts) {
      // Reset likes to demonstrate loop initialization
      if (post.likes > 0) {
        // Keep original likes but ensure isLiked is false initially
        post.isLiked = false;
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIY Social Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const ProfileDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Tutorials',
          ),
        ],
      ),
    );
  }
}