import 'dart:convert';
import 'package:hive/hive.dart';


/// Location data model
@HiveType(typeId: 1)
class LocationData {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final String? address;

  @HiveField(3)
  final double? altitude;

  @HiveField(4)
  final double? speed;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.altitude,
    this.speed,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'altitude': altitude,
      'speed': speed,
    };
  }

  @override
  String toString() => 'LocationData(lat: $latitude, lng: $longitude)';
}

/// Main activity model
@HiveType(typeId: 0)
class ActivityModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final LocationData location;

  @HiveField(2)
  final String? imageUrl;

  @HiveField(3)
  final String? localImagePath;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final bool isSynced;

  ActivityModel({
    required this.id,
    required this.location,
    this.imageUrl,
    this.localImagePath,
    required this.timestamp,
    this.description,
    this.isSynced = false,
  });

  /// Create from JSON (API response)
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      location: LocationData.fromJson(json['location'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String?,
      localImagePath: json['localImagePath'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location.toJson(),
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'isSynced': isSynced,
    };
  }

  /// Create a copy with updated fields
  ActivityModel copyWith({
    String? id,
    LocationData? location,
    String? imageUrl,
    String? localImagePath,
    DateTime? timestamp,
    String? description,
    bool? isSynced,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Formatted date string
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  /// Formatted time string
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Formatted datetime string
  String get formattedDateTime => '$formattedDate at $formattedTime';

  @override
  String toString() => 'ActivityModel(id: $id, timestamp: $timestamp)';
}

/// API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
// GENERATED CODE - Hive TypeAdapters


class LocationDataAdapter extends TypeAdapter<LocationData> {
  @override
  final int typeId = 1;

  @override
  LocationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationData(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      address: fields[2] as String?,
      altitude: fields[3] as double?,
      speed: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.altitude)
      ..writeByte(4)
      ..write(obj.speed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LocationDataAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}

class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId = 0;

  @override
  ActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityModel(
      id: fields[0] as String,
      location: fields[1] as LocationData,
      imageUrl: fields[2] as String?,
      localImagePath: fields[3] as String?,
      timestamp: fields[4] as DateTime,
      description: fields[5] as String?,
      isSynced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.localImagePath)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ActivityModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}