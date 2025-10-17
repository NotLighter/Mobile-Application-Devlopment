// recipes_screen.dart
import 'package:flutter/material.dart';
import 'data_models.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  Widget _buildListView() {
    return ListView.builder(
      itemCount: AppState.tutorials.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final tutorial = AppState.tutorials[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          child: ExpansionTile(
            leading: Icon(
              tutorial.isTextOnly ? Icons.text_snippet : Icons.video_library,
              color: Colors.deepOrange,
              size: 30,
            ),
            title: Text(
              tutorial.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text('${tutorial.steps.length} steps'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Steps:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...tutorial.steps.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}. ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            Expanded(
                              child: Text(entry.value),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (!tutorial.isTextOnly) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Watch Tutorial'),
                        onPressed: () {},
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: AppState.tutorials.length,
      itemBuilder: (context, index) {
        final tutorial = AppState.tutorials[index];
        return Card(
          elevation: 3,
          child: InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[300],
                    child: Icon(
                      tutorial.isTextOnly
                          ? Icons.text_snippet
                          : Icons.video_library,
                      size: 60,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutorial.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tutorial.steps.length} steps',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return _buildListView();
        } else {
          return _buildGridView();
        }
      },
    );
  }
}