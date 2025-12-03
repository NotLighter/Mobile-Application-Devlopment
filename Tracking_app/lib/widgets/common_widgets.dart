import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/activity_model.dart';

/// Responsive layout builder
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
  });

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    return isTablet(context) ? tablet : mobile;
  }
}

/// Activity card widget
class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool compact;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onDelete,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = activity.imageUrl != null ||
        activity.localImagePath != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: compact ? _buildCompact(context) : _buildFull(context, hasImage),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Thumbnail
          if (activity.imageUrl != null || activity.localImagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ActivityImage(
                imageUrl: activity.imageUrl,
                localPath: activity.localImagePath,
                width: 50,
                height: 50,
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.location.address ?? 'Unknown location',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  activity.formattedDateTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Sync indicator
          Icon(
            activity.isSynced ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: activity.isSynced ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context, bool hasImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section
        if (hasImage)
          SizedBox(
            height: 150,
            width: double.infinity,
            child: ActivityImage(
              imageUrl: activity.imageUrl,
              localPath: activity.localImagePath,
            ),
          ),
        // Content section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activity.location.address ?? 'Unknown location',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Description
              if (activity.description != null) ...[
                Text(
                  activity.description!,
                  style: TextStyle(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              // Footer
              Row(
                children: [
                  // Timestamp
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    activity.formattedDateTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  // Sync status
                  Icon(
                    activity.isSynced ? Icons.cloud_done : Icons.cloud_off,
                    size: 16,
                    color: activity.isSynced ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activity.isSynced ? 'Synced' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: activity.isSynced ? Colors.green : Colors.orange,
                    ),
                  ),
                  // Delete button
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 20,
                      color: Colors.red,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Activity image widget with fallback
class ActivityImage extends StatelessWidget {
  final String? imageUrl;
  final String? localPath;
  final double? width;
  final double? height;

  const ActivityImage({
    super.key,
    this.imageUrl,
    this.localPath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Prefer local path
    if (localPath != null && File(localPath!).existsSync()) {
      return Image.file(
        File(localPath!),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    // Fallback to network image
    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildLoading(),
        errorWidget: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// Custom loading indicator
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(message!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}