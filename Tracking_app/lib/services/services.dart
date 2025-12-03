import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

import '../models/activity_model.dart';

/// Service for handling GPS location operations
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check and request location permissions
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current location
  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      String? address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        altitude: position.altitude,
        speed: position.speed,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Stream of position updates for live tracking
  Stream<LocationData> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .asyncMap((position) async {
      String? address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        altitude: position.altitude,
        speed: position.speed,
      );
    });
  }

  /// Reverse geocoding to get address from coordinates
  Future<String?> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.street?.isNotEmpty ?? false) place.street!,
          if (place.locality?.isNotEmpty ?? false) place.locality!,
          if (place.country?.isNotEmpty ?? false) place.country!,
        ];
        return parts.join(', ');
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }

  /// Calculate distance between two locations
  double calculateDistance(LocationData from, LocationData to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Open location settings
  Future<void> openSettings() async {
    await Geolocator.openLocationSettings();
  }
}

/// Service for handling camera operations
class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _controller;
  final ImagePicker _imagePicker = ImagePicker();

  /// Initialize camera controller
  Future<CameraController?> initializeCamera(
      List<CameraDescription> cameras,
      ) async {
    if (cameras.isEmpty) return null;

    try {
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      return _controller;
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      return null;
    }
  }

  /// Capture image and save to local storage
  Future<String?> captureImage(CameraController controller) async {
    if (!controller.value.isInitialized) return null;

    try {
      final XFile file = await controller.takePicture();

      // Save to app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'activity_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = '${directory.path}/$fileName';

      await File(file.path).copy(savedPath);

      return savedPath;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (file == null) return null;

      // Copy to app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'activity_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = '${directory.path}/$fileName';

      await File(file.path).copy(savedPath);

      return savedPath;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Dispose camera controller
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  /// Delete local image file
  Future<void> deleteLocalImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
}