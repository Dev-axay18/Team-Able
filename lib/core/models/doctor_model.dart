class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String qualification;
  final String hospital;
  final String? profileImage;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double consultationFee;
  final bool isAvailable;
  final bool isOnline;
  final List<String> availableDays;
  final List<String> availableSlots;
  final String? about;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phone;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.qualification,
    required this.hospital,
    this.profileImage,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.consultationFee,
    this.isAvailable = true,
    this.isOnline = false,
    this.availableDays = const [],
    this.availableSlots = const [],
    this.about,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      qualification: json['qualification'] ?? '',
      hospital: json['hospital'] ?? '',
      profileImage: json['profileImage'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      experienceYears: json['experienceYears'] ?? 0,
      consultationFee: (json['consultationFee'] ?? 0.0).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      isOnline: json['isOnline'] ?? false,
      availableDays: List<String>.from(json['availableDays'] ?? []),
      availableSlots: List<String>.from(json['availableSlots'] ?? []),
      about: json['about'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialization': specialization,
        'qualification': qualification,
        'hospital': hospital,
        'profileImage': profileImage,
        'rating': rating,
        'reviewCount': reviewCount,
        'experienceYears': experienceYears,
        'consultationFee': consultationFee,
        'isAvailable': isAvailable,
        'isOnline': isOnline,
        'availableDays': availableDays,
        'availableSlots': availableSlots,
        'about': about,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
      };
}
