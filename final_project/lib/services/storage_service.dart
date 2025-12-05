import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ==================== IMAGE PICKER ====================

  // Pick single image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick multiple images
  Future<List<File>> pickMultipleImages({int maxImages = 10}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (images.length > maxImages) {
        return images.take(maxImages).map((xFile) => File(xFile.path)).toList();
      }

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  // Pick video from gallery
  Future<File?> pickVideoFromGallery({Duration? maxDuration}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration ?? const Duration(minutes: 5),
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking video from gallery: $e');
      return null;
    }
  }

  // ==================== UPLOAD OPERATIONS (FILE - Mobile) ====================

  // Upload profile picture
  Future<String?> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_pictures').child(fileName);

      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return null;
    }
  }

  // Upload project image (File - for mobile)
  Future<String?> uploadProjectImage(String projectId, File imageFile, int index) async {
    try {
      final String fileName = 'project_${projectId}_$index.jpg';
      final Reference ref = _storage.ref().child('project_images').child(projectId).child(fileName);

      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading project image: $e');
      return null;
    }
  }

  // Upload project video (File - for mobile)
  Future<String?> uploadProjectVideo(String projectId, File videoFile) async {
    try {
      final String fileName = 'project_${projectId}_video.mp4';
      final Reference ref = _storage.ref().child('project_videos').child(fileName);

      final UploadTask uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(contentType: 'video/mp4'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading project video: $e');
      return null;
    }
  }

  // ==================== UPLOAD OPERATIONS (BYTES - Web) ====================

  // Upload profile picture from bytes (Web)
  Future<String?> uploadProfilePictureBytes(String userId, Uint8List bytes, String fileName) async {
    try {
      final String storagePath = 'profile_pictures/profile_$userId.jpg';
      final Reference ref = _storage.ref().child(storagePath);

      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture bytes: $e');
      return null;
    }
  }

  // Upload project image from bytes (Web)
  Future<String?> uploadProjectImageBytes(String projectId, Uint8List bytes, int index, String fileName) async {
    try {
      // Get file extension
      String extension = 'jpg';
      if (fileName.contains('.')) {
        extension = fileName.split('.').last.toLowerCase();
      }

      final String storagePath = 'project_images/$projectId/project_${projectId}_$index.$extension';
      final Reference ref = _storage.ref().child(storagePath);

      String contentType = 'image/jpeg';
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }

      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Uploaded image to: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading project image bytes: $e');
      return null;
    }
  }

  // Upload project video from bytes (Web)
  Future<String?> uploadProjectVideoBytes(String projectId, Uint8List bytes, String fileName) async {
    try {
      String extension = 'mp4';
      if (fileName.contains('.')) {
        extension = fileName.split('.').last.toLowerCase();
      }

      final String storagePath = 'project_videos/project_${projectId}_video.$extension';
      final Reference ref = _storage.ref().child(storagePath);

      String contentType = 'video/mp4';
      if (extension == 'webm') {
        contentType = 'video/webm';
      } else if (extension == 'mov') {
        contentType = 'video/quicktime';
      }

      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading project video bytes: $e');
      return null;
    }
  }

  // Upload multiple project images
  Future<List<String>> uploadProjectImages(String projectId, List<File> imageFiles) async {
    try {
      final List<String> downloadUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final String? url = await uploadProjectImage(projectId, imageFiles[i], i);
        if (url != null) {
          downloadUrls.add(url);
        }
      }

      return downloadUrls;
    } catch (e) {
      debugPrint('Error uploading project images: $e');
      return [];
    }
  }

  // Upload product image
  Future<String?> uploadProductImage(String productId, File imageFile, int index) async {
    try {
      final String fileName = 'product_${productId}_$index.jpg';
      final Reference ref = _storage.ref().child('product_images').child(productId).child(fileName);

      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading product image: $e');
      return null;
    }
  }

  // ==================== DELETE OPERATIONS ====================

  // Delete profile picture
  Future<bool> deleteProfilePicture(String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_pictures').child(fileName);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting profile picture: $e');
      return false;
    }
  }

  // Delete project images folder
  Future<bool> deleteProjectImages(String projectId) async {
    try {
      final Reference ref = _storage.ref().child('project_images').child(projectId);
      final ListResult result = await ref.listAll();

      for (final Reference fileRef in result.items) {
        await fileRef.delete();
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting project images: $e');
      return false;
    }
  }

  // Delete single file by URL
  Future<bool> deleteFileByUrl(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }
}