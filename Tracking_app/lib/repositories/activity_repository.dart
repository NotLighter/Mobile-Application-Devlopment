import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../models/activity_model.dart';

/// Repository for managing activities (API + Local Storage)
class ActivityRepository {
  // API Configuration - Change this to your server URL
  static const String _baseUrl = 'http://10.0.2.2:3000/api'; // For Android emulator
  // static const String _baseUrl = 'http://localhost:3000/api'; // For iOS simulator

  static const int _maxLocalActivities = 5;

  final Box<ActivityModel> _localBox = Hive.box<ActivityModel>('activities');
  final http.Client _client = http.Client();

  // ============ API OPERATIONS ============

  /// Fetch all activities from API
  Future<ApiResponse<List<ActivityModel>>> fetchActivities({
    String? searchQuery,
  }) async {
    try {
      String url = '$_baseUrl/activities';
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url += '?search=${Uri.encodeComponent(searchQuery)}';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final activities = data
            .map((json) => ActivityModel.fromJson(json))
            .toList();

        // Cache recent activities locally
        await _cacheRecentActivities(activities);

        return ApiResponse.success(activities);
      } else {
        return ApiResponse.error(
          'Failed to fetch activities',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      // Return cached activities when offline
      final cached = getLocalActivities();
      return ApiResponse.success(cached, message: 'Showing cached data (offline)');
    } catch (e) {
      debugPrint('Fetch activities error: $e');
      final cached = getLocalActivities();
      return ApiResponse.success(cached, message: 'Showing cached data');
    }
  }

  /// Create new activity on API
  Future<ApiResponse<ActivityModel>> createActivity(ActivityModel activity) async {
    try {
      // Upload image if exists
      String? imageUrl;
      if (activity.localImagePath != null) {
        imageUrl = await _uploadImage(activity.localImagePath!);
      }

      final activityWithImage = activity.copyWith(
        imageUrl: imageUrl,
        isSynced: true,
      );

      final response = await _client.post(
        Uri.parse('$_baseUrl/activities'),
        headers: _getHeaders(),
        body: json.encode(activityWithImage.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final created = ActivityModel.fromJson(data);

        // Update local cache
        await _addToLocalCache(created);

        return ApiResponse.success(created, message: 'Activity saved successfully');
      } else {
        // Save locally for later sync
        await _addToLocalCache(activity);
        return ApiResponse.error(
          'Failed to sync, saved locally',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      // Save locally when offline
      await _addToLocalCache(activity);
      return ApiResponse.success(activity, message: 'Saved locally (offline)');
    } catch (e) {
      debugPrint('Create activity error: $e');
      await _addToLocalCache(activity);
      return ApiResponse.success(activity, message: 'Saved locally');
    }
  }

  /// Delete activity from API
  Future<ApiResponse<bool>> deleteActivity(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/activities/$id'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local cache
        await _removeFromLocalCache(id);
        return ApiResponse.success(true, message: 'Activity deleted');
      } else {
        return ApiResponse.error(
          'Failed to delete activity',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } catch (e) {
      debugPrint('Delete activity error: $e');
      return ApiResponse.error('Error deleting activity');
    }
  }

  /// Upload image to server
  Future<String?> _uploadImage(String localPath) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', localPath));

      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['url'] as String?;
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
    }
    return null;
  }

  // ============ LOCAL STORAGE OPERATIONS ============

  /// Get cached activities from local storage
  List<ActivityModel> getLocalActivities() {
    return _localBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Cache recent activities (max 5)
  Future<void> _cacheRecentActivities(List<ActivityModel> activities) async {
    await _localBox.clear();

    final recent = activities.take(_maxLocalActivities).toList();
    for (final activity in recent) {
      await _localBox.put(activity.id, activity);
    }
  }

  /// Add activity to local cache
  Future<void> _addToLocalCache(ActivityModel activity) async {
    await _localBox.put(activity.id, activity);

    // Keep only recent 5
    if (_localBox.length > _maxLocalActivities) {
      final allActivities = _localBox.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      for (int i = _maxLocalActivities; i < allActivities.length; i++) {
        await _localBox.delete(allActivities[i].id);
      }
    }
  }

  /// Remove activity from local cache
  Future<void> _removeFromLocalCache(String id) async {
    await _localBox.delete(id);
  }

  /// Clear all local cache
  Future<void> clearLocalCache() async {
    await _localBox.clear();
  }

  /// Sync pending activities
  Future<int> syncPendingActivities() async {
    int synced = 0;
    final pending = _localBox.values.where((a) => !a.isSynced).toList();

    for (final activity in pending) {
      final result = await createActivity(activity);
      if (result.success && result.data?.isSynced == true) {
        synced++;
      }
    }

    return synced;
  }

  // ============ HELPERS ============

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  void dispose() {
    _client.close();
  }
}