enum AppointmentStatus { pending, confirmed, completed, cancelled }

enum AppointmentType { inPerson, online }

class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String? doctorImage;
  final String userId;
  final DateTime dateTime;
  final AppointmentStatus status;
  final AppointmentType type;
  final String? notes;
  final double fee;
  final String? meetingLink;
  final String? prescription;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    this.doctorImage,
    required this.userId,
    required this.dateTime,
    required this.status,
    required this.type,
    this.notes,
    required this.fee,
    this.meetingLink,
    this.prescription,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      doctorSpecialization: json['doctorSpecialization'] ?? '',
      doctorImage: json['doctorImage'],
      userId: json['userId'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      type: AppointmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppointmentType.inPerson,
      ),
      notes: json['notes'],
      fee: (json['fee'] ?? 0.0).toDouble(),
      meetingLink: json['meetingLink'],
      prescription: json['prescription'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorSpecialization': doctorSpecialization,
        'doctorImage': doctorImage,
        'userId': userId,
        'dateTime': dateTime.toIso8601String(),
        'status': status.name,
        'type': type.name,
        'notes': notes,
        'fee': fee,
        'meetingLink': meetingLink,
        'prescription': prescription,
      };

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
