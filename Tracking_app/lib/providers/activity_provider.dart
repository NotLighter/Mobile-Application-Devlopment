import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';
import '../services/services.dart';

/// State management for activities using ChangeNotifier
class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();
  final LocationService _locationService = LocationService();
  final Uuid _uuid = const Uuid();

  // State variables
  List<ActivityModel> _activities = [];
  List<ActivityModel> _filteredActivities = [];
  LocationData? _currentLocation;
  bool _isLoading = false;
  bool _isTracking = false;
  String? _errorMessage;
  String? _successMessage;
  String _searchQuery = '';

  // Getters
  List<ActivityModel> get activities => _filteredActivities;
  List<ActivityModel> get recentActivities =>
      _activities.take(5).toList();
  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  bool get isTracking => _isTracking;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get searchQuery => _searchQuery;
  bool get hasLocation => _currentLocation != null;

  /// Initialize provider
  Future<void> initialize() async {
    await loadActivities();
    await startLocationTracking();
  }

  /// Load activities from API
  Future<void> loadActivities() async {
    _setLoading(true);
    _clearMessages();

    final response = await _repository.fetchActivities(
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (response.success && response.data != null) {
      _activities = response.data!;
      _applySearch();
      if (response.message != null) {
        _successMessage = response.message;
      }
    } else {
      _errorMessage = response.message ?? 'Failed to load activities';
      // Load from cache
      _activities = _repository.getLocalActivities();
      _applySearch();
    }

    _setLoading(false);
  }

  /// Search activities
  void searchActivities(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  /// Apply search filter
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredActivities = List.from(_activities);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredActivities = _activities.where((activity) {
        final address = activity.location.address?.toLowerCase() ?? '';
        final description = activity.description?.toLowerCase() ?? '';
        final date = activity.formattedDateTime.toLowerCase();

        return address.contains(query) ||
            description.contains(query) ||
            date.contains(query);
      }).toList();
    }
  }

  /// Start live location tracking
  Future<void> startLocationTracking() async {
    final hasPermission = await _locationService.checkPermissions();
    if (!hasPermission) {
      _errorMessage = 'Location permission denied';
      notifyListeners();
      return;
    }

    _isTracking = true;
    notifyListeners();

    // Get initial location
    _currentLocation = await _locationService.getCurrentLocation();
    notifyListeners();

    // Listen to location updates
    _locationService.getLocationStream().listen(
          (location) {
        _currentLocation = location;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Location stream error: $e');
      },
    );
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _isTracking = false;
    notifyListeners();
  }

  /// Refresh current location
  Future<void> refreshLocation() async {
    _currentLocation = await _locationService.getCurrentLocation();
    notifyListeners();
  }

  /// Create new activity
  Future<bool> createActivity({
    String? imagePath,
    String? description,
  }) async {
    if (_currentLocation == null) {
      _errorMessage = 'Location not available';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearMessages();

    final activity = ActivityModel(
      id: _uuid.v4(),
      location: _currentLocation!,
      localImagePath: imagePath,
      timestamp: DateTime.now(),
      description: description,
      isSynced: false,
    );

    final response = await _repository.createActivity(activity);

    if (response.success) {
      _successMessage = response.message ?? 'Activity logged successfully';
      await loadActivities(); // Refresh list
      _setLoading(false);
      return true;
    } else {
      _errorMessage = response.message ?? 'Failed to save activity';
      _setLoading(false);
      return false;
    }
  }

  /// Delete activity
  Future<bool> deleteActivity(String id) async {
    _setLoading(true);
    _clearMessages();

    final response = await _repository.deleteActivity(id);

    if (response.success) {
      _activities.removeWhere((a) => a.id == id);
      _applySearch();
      _successMessage = response.message ?? 'Activity deleted';
      _setLoading(false);
      return true;
    } else {
      _errorMessage = response.message ?? 'Failed to delete activity';
      _setLoading(false);
      return false;
    }
  }

  /// Sync pending activities
  Future<void> syncPending() async {
    _setLoading(true);
    _clearMessages();

    final count = await _repository.syncPendingActivities();

    if (count > 0) {
      _successMessage = 'Synced $count activities';
      await loadActivities();
    } else {
      _successMessage = 'All activities are synced';
    }

    _setLoading(false);
  }

  /// Clear all local data
  Future<void> clearLocalData() async {
    await _repository.clearLocalCache();
    _activities.clear();
    _filteredActivities.clear();
    notifyListeners();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await _locationService.openSettings();
  }

  // ============ PRIVATE HELPERS ============

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}