import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;

  List<AppointmentModel> get upcomingAppointments => _appointments
      .where((a) =>
          a.dateTime.isAfter(DateTime.now()) &&
          a.status != AppointmentStatus.cancelled)
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<AppointmentModel> get pastAppointments => _appointments
      .where((a) =>
          a.dateTime.isBefore(DateTime.now()) ||
          a.status == AppointmentStatus.completed)
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  Future<void> loadAppointments(String userId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _appointments = _getMockAppointments(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> bookAppointment(AppointmentModel appointment) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _appointments.add(appointment);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = AppointmentModel(
        id: _appointments[index].id,
        doctorId: _appointments[index].doctorId,
        doctorName: _appointments[index].doctorName,
        doctorSpecialization: _appointments[index].doctorSpecialization,
        doctorImage: _appointments[index].doctorImage,
        userId: _appointments[index].userId,
        dateTime: _appointments[index].dateTime,
        status: AppointmentStatus.cancelled,
        type: _appointments[index].type,
        notes: _appointments[index].notes,
        fee: _appointments[index].fee,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  List<AppointmentModel> _getMockAppointments(String userId) {
    final now = DateTime.now();
    return [
      AppointmentModel(
        id: 'apt001',
        doctorId: 'd001',
        doctorName: 'Dr. Priya Mehta',
        doctorSpecialization: 'Cardiologist',
        userId: userId,
        dateTime: now.add(const Duration(days: 2, hours: 3)),
        status: AppointmentStatus.confirmed,
        type: AppointmentType.inPerson,
        fee: 800,
        notes: 'Regular checkup and ECG',
      ),
      AppointmentModel(
        id: 'apt002',
        doctorId: 'd003',
        doctorName: 'Dr. Ananya Singh',
        doctorSpecialization: 'Pediatrician',
        userId: userId,
        dateTime: now.add(const Duration(days: 5, hours: 1)),
        status: AppointmentStatus.pending,
        type: AppointmentType.online,
        fee: 600,
        meetingLink: 'https://meet.jeevanpath.in/apt002',
      ),
      AppointmentModel(
        id: 'apt003',
        doctorId: 'd002',
        doctorName: 'Dr. Rajesh Kumar',
        doctorSpecialization: 'Neurologist',
        userId: userId,
        dateTime: now.subtract(const Duration(days: 7)),
        status: AppointmentStatus.completed,
        type: AppointmentType.inPerson,
        fee: 1000,
        prescription: 'Prescribed Aspirin 75mg, Atorvastatin 20mg',
      ),
    ];
  }
}
