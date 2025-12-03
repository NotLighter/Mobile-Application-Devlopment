import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/activity_provider.dart';
import '../widgets/common_widgets.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  String? _capturedImagePath;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _mapController?.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ActivityProvider>().refreshLocation();
            },
            tooltip: 'Refresh Location',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<ActivityProvider>().syncPending();
            },
            tooltip: 'Sync Pending',
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          return ResponsiveLayout(
            mobile: _buildMobileLayout(provider),
            tablet: _buildTabletLayout(provider),
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildMobileLayout(ActivityProvider provider) {
    return Column(
      children: [
        // Map Section
        Expanded(
          flex: 3,
          child: _buildMapSection(provider),
        ),
        // Info Section
        Expanded(
          flex: 2,
          child: _buildInfoSection(provider),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(ActivityProvider provider) {
    return Row(
      children: [
        // Map Section
        Expanded(
          flex: 2,
          child: _buildMapSection(provider),
        ),
        // Info Section
        Expanded(
          child: _buildInfoSection(provider),
        ),
      ],
    );
  }

  Widget _buildMapSection(ActivityProvider provider) {
    if (!provider.hasLocation) {
      return _buildLocationLoading(provider);
    }

    final location = provider.currentLocation!;
    final position = LatLng(location.latitude, location.longitude);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: position,
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          markers: {
            Marker(
              markerId: const MarkerId('current'),
              position: position,
              infoWindow: InfoWindow(
                title: 'Current Location',
                snippet: location.address ?? 'Unknown address',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        // Location indicator
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildLocationCard(location),
        ),
        // Center on location button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'center_location',
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(position),
              );
            },
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(dynamic location) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    location.address ?? 'Getting address...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Lat: ${location.latitude.toStringAsFixed(6)}, '
                        'Lng: ${location.longitude.toStringAsFixed(6)}',
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
  }

  Widget _buildLocationLoading(ActivityProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (provider.isTracking) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Getting your location...'),
          ] else ...[
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Location not available'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => provider.startLocationTracking(),
              icon: const Icon(Icons.location_on),
              label: const Text('Enable Location'),
            ),
            TextButton(
              onPressed: () => provider.openLocationSettings(),
              child: const Text('Open Settings'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(ActivityProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Captured Image Preview
                  if (_capturedImagePath != null) ...[
                    _buildImagePreview(),
                    const SizedBox(height: 16),
                  ],
                  // Description Input
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Activity Description',
                      hintText: 'What are you doing?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit_note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  // Recent Activities
                  if (provider.recentActivities.isNotEmpty) ...[
                    const Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...provider.recentActivities.take(3).map(
                          (activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ActivityCard(
                          activity: activity,
                          compact: true,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_capturedImagePath!),
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filled(
            onPressed: () {
              setState(() => _capturedImagePath = null);
            },
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Camera button
            FloatingActionButton(
              heroTag: 'camera',
              onPressed: provider.hasLocation ? _openCamera : null,
              backgroundColor: provider.hasLocation ? null : Colors.grey,
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(height: 16),
            // Log activity button
            FloatingActionButton.extended(
              heroTag: 'log',
              onPressed: provider.hasLocation && !provider.isLoading
                  ? () => _logActivity(provider)
                  : null,
              backgroundColor: provider.hasLocation ? null : Colors.grey,
              icon: provider.isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.add_location_alt),
              label: Text(provider.isLoading ? 'Saving...' : 'Log Activity'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCamera() async {
    final imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );

    if (imagePath != null) {
      setState(() => _capturedImagePath = imagePath);
    }
  }

  Future<void> _logActivity(ActivityProvider provider) async {
    final success = await provider.createActivity(
      imagePath: _capturedImagePath,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );

    if (success && mounted) {
      setState(() => _capturedImagePath = null);
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.successMessage ?? 'Activity logged!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (provider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}