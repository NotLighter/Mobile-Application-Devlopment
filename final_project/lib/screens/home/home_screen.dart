import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project_model.dart';
import 'project_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIY Social'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('No projects yet. Create one!'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final projectId = docs[index].id;
              final images = List<String>.from(data['images'] ?? []);
              final title = data['title'] ?? 'Untitled';
              final description = data['description'] ?? '';
              final userName = data['userName'] ?? 'Unknown';
              final category = data['category'] ?? '';
              final likes = data['likes'] ?? 0;

              return Card(
                margin: const EdgeInsets.all(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    final project = ProjectModel(
                      id: projectId,
                      userId: data['userId'] ?? '',
                      userName: userName,
                      userProfilePicture: data['userProfilePicture'] ?? '',
                      title: title,
                      description: description,
                      category: category,
                      difficulty: data['difficulty'] ?? 'Medium',
                      images: images,
                      materials: List<String>.from(data['materials'] ?? []),
                      tools: List<String>.from(data['tools'] ?? []),
                      steps: [],
                      tags: [],
                      likes: likes,
                      commentsCount: data['commentsCount'] ?? 0,
                      views: data['views'] ?? 0,
                      createdAt: DateTime.now(),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(project: project),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'U'),
                            ),
                            const SizedBox(width: 12),
                            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      // Image
                      if (images.isNotEmpty)
                        Image.network(
                          images.first,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Image error: $error');
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error, size: 40),
                                    Text('Failed to load image'),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.image, size: 50)),
                        ),

                      // Title & description
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.favorite, size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Text('$likes'),
                                const SizedBox(width: 16),
                                Chip(label: Text(category)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}