class HospitalModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? emergencyPhone;
  final String? email;
  final String? facilities;
  final bool hasEmergency;
  final bool hasAmbulance;
  final bool hasICU;
  final int? bedCount;
  final double? rating;
  final String? type;
  final String? imageUrl;
  final bool available24x7;
  final double? distance; // Distance in kilometers

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.emergencyPhone,
    this.email,
    this.facilities,
    required this.hasEmergency,
    required this.hasAmbulance,
    required this.hasICU,
    this.bedCount,
    this.rating,
    this.type,
    this.imageUrl,
    required this.available24x7,
    this.distance,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      phone: json['phone'],
      emergencyPhone: json['emergencyPhone'],
      email: json['email'],
      facilities: json['facilities'],
      hasEmergency: json['hasEmergency'] ?? false,
      hasAmbulance: json['hasAmbulance'] ?? false,
      hasICU: json['hasICU'] ?? false,
      bedCount: json['bedCount'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      type: json['type'],
      imageUrl: json['imageUrl'],
      available24x7: json['available24x7'] ?? false,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'emergencyPhone': emergencyPhone,
      'email': email,
      'facilities': facilities,
      'hasEmergency': hasEmergency,
      'hasAmbulance': hasAmbulance,
      'hasICU': hasICU,
      'bedCount': bedCount,
      'rating': rating,
      'type': type,
      'imageUrl': imageUrl,
      'available24x7': available24x7,
      'distance': distance,
    };
  }

  List<String> get facilitiesList {
    if (facilities == null || facilities!.isEmpty) return [];
    return facilities!.split(',').map((f) => f.trim()).toList();
  }
}
