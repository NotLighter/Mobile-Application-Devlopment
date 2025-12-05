import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../models/project_model.dart';
import '../../main.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Home Decor';
  String _selectedDifficulty = 'Medium';

  Uint8List? _imageBytes;
  String? _imageName;

  final List<String> _materials = [];
  final List<String> _tools = [];
  final List<Map<String, String>> _steps = [];

  final _materialController = TextEditingController();
  final _toolController = TextEditingController();
  final _stepTitleController = TextEditingController();
  final _stepDescController = TextEditingController();

  bool _isLoading = false;
  String _loadingMessage = '';
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Home Decor',
    'Furniture',
    'Garden',
    'Electronics',
    'Crafts',
    'Woodworking',
    'Sewing',
    'Jewelry',
    'Art',
    'Other',
  ];

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard', 'Expert'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _materialController.dispose();
    _toolController.dispose();
    _stepTitleController.dispose();
    _stepDescController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading, [String message = '']) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
        _loadingMessage = message;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 30,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = image.name;
        });
      }
    } catch (e) {
      _showMessage('Error picking image: $e', isError: true);
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
    });
  }

  void _addMaterial() {
    final text = _materialController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _materials.add(text);
        _materialController.clear();
      });
    }
  }

  void _removeMaterial(int index) {
    setState(() {
      _materials.removeAt(index);
    });
  }

  void _addTool() {
    final text = _toolController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tools.add(text);
        _toolController.clear();
      });
    }
  }

  void _removeTool(int index) {
    setState(() {
      _tools.removeAt(index);
    });
  }

  void _addStep() {
    final title = _stepTitleController.text.trim();
    final desc = _stepDescController.text.trim();
    if (title.isNotEmpty && desc.isNotEmpty) {
      setState(() {
        _steps.add({'title': title, 'description': desc});
        _stepTitleController.clear();
        _stepDescController.clear();
      });
    }
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true, 'Getting user info...');

    try {
      // Get current user
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.getCurrentUserData();

      if (user == null) {
        throw Exception('Please login first');
      }

      final projectId = DateTime.now().millisecondsSinceEpoch.toString();
      String? imageUrl;

      // Try to upload image (skip if fails)
      if (_imageBytes != null) {
        _setLoading(true, 'Uploading image...');

        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child('projects')
              .child('$projectId.jpg');

          final uploadTask = ref.putData(
            _imageBytes!,
            SettableMetadata(contentType: 'image/jpeg'),
          );

          // Wait max 30 seconds
          final snapshot = await uploadTask.timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Upload taking too long');
            },
          );

          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          debugPrint('Image upload failed: $e');
          // Continue without image
        }
      }

      _setLoading(true, 'Saving project...');

      // Prepare steps data
      final stepsData = _steps.asMap().entries.map((e) => {
        'stepNumber': e.key + 1,
        'title': e.value['title'],
        'description': e.value['description'],
      }).toList();

      // Create project data
      final projectData = {
        'userId': user.id,
        'userName': user.name,
        'userProfilePicture': user.profilePicture,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'images': imageUrl != null ? [imageUrl] : [],
        'videoUrl': null,
        'materials': _materials,
        'tools': _tools,
        'steps': stepsData,
        'tags': [],
        'likes': 0,
        'commentsCount': 0,
        'views': 0,
        'shares': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('projects')
          .add(projectData);

      // Create local model
      final project = ProjectModel(
        id: docRef.id,
        userId: user.id,
        userName: user.name,
        userProfilePicture: user.profilePicture,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        images: imageUrl != null ? [imageUrl] : [],
        materials: _materials,
        tools: _tools,
        steps: _steps.asMap().entries.map((e) => ProjectStep(
          stepNumber: e.key + 1,
          title: e.value['title'] ?? '',
          description: e.value['description'] ?? '',
        )).toList(),
        tags: [],
        likes: 0,
        commentsCount: 0,
        views: 0,
        createdAt: DateTime.now(),
      );

      // Add to app state
      Provider.of<AppState>(context, listen: false).addProject(project);

      _setLoading(false);
      _showMessage('🎉 Project created successfully!');
      _clearForm();

    } catch (e) {
      _setLoading(false);
      _showMessage('Error: $e', isError: true);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _materialController.clear();
    _toolController.clear();
    _stepTitleController.clear();
    _stepDescController.clear();
    setState(() {
      _imageBytes = null;
      _imageName = null;
      _materials.clear();
      _tools.clear();
      _steps.clear();
      _selectedCategory = 'Home Decor';
      _selectedDifficulty = 'Medium';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
      ),
      body: Stack(
        children: [
          // Main Form
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Project Title *',
                    hintText: 'Enter a catchy title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe your project',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.trim().length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category & Difficulty
                // Category & Difficulty
                Column(
                  children: [
                    // Category
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCategory = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Difficulty
                    DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.speed),
                      ),
                      items: _difficulties.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedDifficulty = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Image Section
                _buildSectionTitle('Image', Icons.image, optional: true),
                const SizedBox(height: 8),
                _buildImageSection(),
                const SizedBox(height: 24),

                // Materials Section
                _buildSectionTitle('Materials', Icons.inventory_2, optional: true),
                const SizedBox(height: 8),
                _buildMaterialsSection(),
                const SizedBox(height: 24),

                // Tools Section
                _buildSectionTitle('Tools', Icons.build, optional: true),
                const SizedBox(height: 8),
                _buildToolsSection(),
                const SizedBox(height: 24),

                // Steps Section
                _buildSectionTitle('Steps', Icons.format_list_numbered, optional: true),
                const SizedBox(height: 8),
                _buildStepsSection(),
                const SizedBox(height: 32),

                // Create Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createProject,
                    icon: const Icon(Icons.add_circle, size: 28),
                    label: const Text(
                      'Create Project',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          _loadingMessage,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => _setLoading(false),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {bool optional = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (optional)
          Text(
            ' (Optional)',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
      ],
    );
  }

  Widget _buildImageSection() {
    if (_imageBytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _imageBytes!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(_imageBytes!.length / 1024).toStringAsFixed(1)} KB',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: _pickImage,
      icon: const Icon(Icons.add_photo_alternate),
      label: const Text('Add Image'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: Colors.grey[400]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildMaterialsSection() {
    return Column(
      children: [
        if (_materials.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _materials.asMap().entries.map((e) {
              return Chip(
                label: Text(e.value),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeMaterial(e.key),
              );
            }).toList(),
          ),
        if (_materials.isNotEmpty) const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _materialController,
                decoration: InputDecoration(
                  hintText: 'e.g., Wood, Screws, Paint',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _addMaterial(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addMaterial,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolsSection() {
    return Column(
      children: [
        if (_tools.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tools.asMap().entries.map((e) {
              return Chip(
                label: Text(e.value),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTool(e.key),
              );
            }).toList(),
          ),
        if (_tools.isNotEmpty) const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _toolController,
                decoration: InputDecoration(
                  hintText: 'e.g., Hammer, Drill, Saw',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _addTool(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addTool,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      children: [
        if (_steps.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    step['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    step['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeStep(index),
                  ),
                ),
              );
            },
          ),
        if (_steps.isNotEmpty) const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _stepTitleController,
                  decoration: InputDecoration(
                    labelText: 'Step Title',
                    hintText: 'e.g., Prepare materials',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _stepDescController,
                  decoration: InputDecoration(
                    labelText: 'Step Description',
                    hintText: 'Describe what to do',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Step'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}