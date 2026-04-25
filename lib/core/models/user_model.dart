class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? bloodGroup;
  final int? age;
  final String? gender;
  final List<String> allergies;
  final List<String> conditions;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.bloodGroup,
    this.age,
    this.gender,
    this.allergies = const [],
    this.conditions = const [],
    this.emergencyContact,
    this.emergencyPhone,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'],
      bloodGroup: json['bloodGroup'],
      age: json['age'],
      gender: json['gender'],
      allergies: List<String>.from(json['allergies'] ?? []),
      conditions: List<String>.from(json['conditions'] ?? []),
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'bloodGroup': bloodGroup,
      'age': age,
      'gender': gender,
      'allergies': allergies,
      'conditions': conditions,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'address': address,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? bloodGroup,
    int? age,
    String? gender,
    List<String>? allergies,
    List<String>? conditions,
    String? emergencyContact,
    String? emergencyPhone,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      address: address ?? this.address,
    );
  }
}
