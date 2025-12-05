import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _userId;
  String _currentProfilePicture = '';

  // New image selected
  Uint8List? _newImageBytes;
  String? _newImageName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      _userId = user.uid;

      // Load from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _currentProfilePicture = data['profilePicture'] ?? '';
      } else {
        // Use Firebase Auth data if Firestore document doesn't exist
        _nameController.text = user.displayName ?? '';
        _usernameController.text = user.email?.split('@')[0] ?? '';
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading user: $e');
      setState(() => _isLoading = false);
      _showMessage('Error loading profile: $e', isError: true);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _newImageBytes = bytes;
          _newImageName = image.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showMessage('Error picking image: $e', isError: true);
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _newImageBytes = bytes;
          _newImageName = image.name;
        });
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      _showMessage('Error taking photo: $e', isError: true);
    }
  }

  void _removeNewImage() {
    setState(() {
      _newImageBytes = null;
      _newImageName = null;
    });
  }

  Future<void> _removeCurrentProfilePicture() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Profile Picture?'),
        content: const Text('Are you sure you want to remove your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete from storage if exists
        if (_currentProfilePicture.isNotEmpty) {
          try {
            await FirebaseStorage.instance.refFromURL(_currentProfilePicture).delete();
          } catch (e) {
            debugPrint('Error deleting old image: $e');
          }
        }

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({'profilePicture': ''});

        setState(() {
          _currentProfilePicture = '';
          _newImageBytes = null;
          _newImageName = null;
        });

        _showMessage('Profile picture removed');
      } catch (e) {
        _showMessage('Error removing picture: $e', isError: true);
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              if (_currentProfilePicture.isNotEmpty || _newImageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    if (_newImageBytes != null) {
                      _removeNewImage();
                    } else {
                      _removeCurrentProfilePicture();
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _uploadProfileImage() async {
    if (_newImageBytes == null) return null;

    setState(() => _isUploadingImage = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$_userId.jpg');

      // Delete old image if exists
      if (_currentProfilePicture.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(_currentProfilePicture).delete();
        } catch (e) {
          debugPrint('Error deleting old image: $e');
        }
      }

      // Upload new image
      final uploadTask = ref.putData(
        _newImageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout');
        },
      );

      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() => _isUploadingImage = false);
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      setState(() => _isUploadingImage = false);
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Not logged in');
      }

      String? newProfilePictureUrl;

      // Upload new image if selected
      if (_newImageBytes != null) {
        _showMessage('Uploading image...');
        newProfilePictureUrl = await _uploadProfileImage();

        if (newProfilePictureUrl == null) {
          _showMessage('Image upload failed, saving without image change', isError: true);
        }
      }

      // Update display name in Firebase Auth
      await user.updateDisplayName(_nameController.text.trim());

      // Prepare update data
      final updateData = {
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim().toLowerCase(),
        'bio': _bioController.text.trim(),
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add profile picture URL if uploaded successfully
      if (newProfilePictureUrl != null) {
        updateData['profilePicture'] = newProfilePictureUrl;
      }

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));

      // Also update userName and userProfilePicture in all user's projects
      final projectsSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (var doc in projectsSnapshot.docs) {
        final projectUpdate = {
          'userName': _nameController.text.trim(),
        };

        if (newProfilePictureUrl != null) {
          projectUpdate['userProfilePicture'] = newProfilePictureUrl;
        }

        await doc.reference.update(projectUpdate);
      }

      setState(() => _isSaving = false);
      _showMessage('Profile updated successfully!');

      // Go back
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      setState(() => _isSaving = false);
      _showMessage('Error saving profile: $e', isError: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving || _isUploadingImage)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _showImageOptions,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _newImageBytes != null
                          ? MemoryImage(_newImageBytes!)
                          : (_currentProfilePicture.isNotEmpty
                          ? NetworkImage(_currentProfilePicture)
                          : null) as ImageProvider?,
                      child: (_newImageBytes == null && _currentProfilePicture.isEmpty)
                          ? Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _showImageOptions,
                child: const Text('Change Photo'),
              ),
              if (_newImageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'New image selected (${(_newImageBytes!.length / 1024).toStringAsFixed(1)} KB)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.contains(' ')) {
                    return 'Username cannot have spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bio Field
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 150,
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isSaving || _isUploadingImage) ? null : _saveProfile,
                  child: (_isSaving || _isUploadingImage)
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Saving...'),
                    ],
                  )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}