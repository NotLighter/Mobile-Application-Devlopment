import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/activity_provider.dart';
import '../models/activity_model.dart';
import '../widgets/common_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ActivityProvider>().loadActivities();
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          // Show messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showMessages(provider);
          });

          if (provider.isLoading && provider.activities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.activities.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: provider.loadActivities,
            child: ResponsiveLayout(
              mobile: _buildListView(provider),
              tablet: _buildGridView(provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by location or description...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            context.read<ActivityProvider>().searchActivities('');
          },
        )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      onChanged: (value) {
        context.read<ActivityProvider>().searchActivities(value);
        setState(() {});
      },
    );
  }

  Widget _buildEmptyState() {
    final query = context.read<ActivityProvider>().searchQuery;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            query.isEmpty ? Icons.history : Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'No activities yet'
                : 'No activities match "$query"',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          if (query.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Start tracking to log your first activity!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListView(ActivityProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.activities.length,
      itemBuilder: (context, index) {
        final activity = provider.activities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ActivityCard(
            activity: activity,
            onDelete: () => _confirmDelete(activity),
            onTap: () => _showActivityDetails(activity),
          ),
        );
      },
    );
  }

  Widget _buildGridView(ActivityProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.activities.length,
      itemBuilder: (context, index) {
        final activity = provider.activities[index];
        return ActivityCard(
          activity: activity,
          onDelete: () => _confirmDelete(activity),
          onTap: () => _showActivityDetails(activity),
        );
      },
    );
  }

  void _confirmDelete(ActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text(
          'Are you sure you want to delete this activity? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ActivityProvider>().deleteActivity(activity.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(ActivityModel activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return ActivityDetailsSheet(
            activity: activity,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  void _showMessages(ActivityProvider provider) {
    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      provider.clearError();
    }

    if (provider.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.successMessage!),
          backgroundColor: Colors.green,
        ),
      );
      provider.clearSuccess();
    }
  }
}

/// Activity details bottom sheet
class ActivityDetailsSheet extends StatelessWidget {
  final ActivityModel activity;
  final ScrollController scrollController;

  const ActivityDetailsSheet({
    super.key,
    required this.activity,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Image
          if (activity.imageUrl != null || activity.localImagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ActivityImage(
                imageUrl: activity.imageUrl,
                localPath: activity.localImagePath,
                height: 250,
              ),
            ),
          const SizedBox(height: 24),
          // Date & Time
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Date & Time',
            value: activity.formattedDateTime,
          ),
          const SizedBox(height: 16),
          // Location
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Location',
            value: activity.location.address ?? 'Unknown location',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.gps_fixed,
            label: 'Coordinates',
            value: '${activity.location.latitude.toStringAsFixed(6)}, '
                '${activity.location.longitude.toStringAsFixed(6)}',
          ),
          if (activity.location.altitude != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.height,
              label: 'Altitude',
              value: '${activity.location.altitude!.toStringAsFixed(1)} m',
            ),
          ],
          // Description
          if (activity.description != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.description,
              label: 'Description',
              value: activity.description!,
            ),
          ],
          // Sync Status
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: activity.isSynced ? Icons.cloud_done : Icons.cloud_off,
            label: 'Sync Status',
            value: activity.isSynced ? 'Synced' : 'Pending sync',
            valueColor: activity.isSynced ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}