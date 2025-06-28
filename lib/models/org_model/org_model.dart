// models/organization_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Organization {
  final String? id;
  final String name;
  final String type;
  final String? latitude;
  final String? longitude;
  final DateTime createdAt;
  final String createdBy;
  final String? logoUrl;
  final GeoPoint? location;
  final bool active;


  Organization({
    this.id,
    required this.name,
    required this.type,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.createdBy,
    this.logoUrl,
    this.location,
    required this.active,
  });

  factory Organization.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Organization(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'school',
      latitude: data['latitude']?.toString(),
      longitude: data['longitude']?.toString(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      logoUrl: data['logoUrl'],
      location: data['location'],
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'logoUrl': logoUrl,
      'location': location,
      'active': active,
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? type,
    String? latitude,
    String? longitude,
    DateTime? createdAt,
    String? createdBy,
    String? logoUrl,
    GeoPoint? location,
    bool? active,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      logoUrl: logoUrl ?? this.logoUrl,
      location: location ?? this.location,
      active: active ?? this.active,
    );
  }
}