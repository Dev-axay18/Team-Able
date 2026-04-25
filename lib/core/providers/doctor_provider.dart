import 'package:flutter/foundation.dart';
import '../models/doctor_model.dart';

class DoctorProvider extends ChangeNotifier {
  List<DoctorModel> _doctors = [];
  List<DoctorModel> _filteredDoctors = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedSpecialization = 'All';

  List<DoctorModel> get doctors => _filteredDoctors;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedSpecialization => _selectedSpecialization;

  final List<String> specializations = [
    'All',
    'General',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedic',
    'Pediatrician',
    'Gynecologist',
    'Psychiatrist',
    'Ophthalmologist',
    'ENT',
    'Dentist',
  ];

  Future<void> loadDoctors() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _doctors = _getMockDoctors();
    _filteredDoctors = _doctors;
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterBySpecialization(String specialization) {
    _selectedSpecialization = specialization;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredDoctors = _doctors.where((doctor) {
      final matchesSearch = _searchQuery.isEmpty ||
          doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doctor.specialization.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doctor.hospital.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesSpecialization = _selectedSpecialization == 'All' ||
          doctor.specialization == _selectedSpecialization;

      return matchesSearch && matchesSpecialization;
    }).toList();
    notifyListeners();
  }

  DoctorModel? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  List<DoctorModel> _getMockDoctors() {
    return [
      DoctorModel(
        id: 'd001',
        name: 'Dr. Priya Mehta',
        specialization: 'Cardiologist',
        qualification: 'MBBS, MD (Cardiology)',
        hospital: 'Apollo Hospital, Mumbai',
        rating: 4.9,
        reviewCount: 312,
        experienceYears: 15,
        consultationFee: 800,
        isAvailable: true,
        isOnline: true,
        availableDays: ['Mon', 'Wed', 'Fri'],
        availableSlots: ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM'],
        about:
            'Dr. Priya Mehta is a renowned cardiologist with 15 years of experience in treating complex heart conditions. She specializes in interventional cardiology and has performed over 2000 successful procedures.',
        address: 'Apollo Hospital, Juhu, Mumbai - 400049',
        phone: '+91 98765 11111',
      ),
      DoctorModel(
        id: 'd002',
        name: 'Dr. Rajesh Kumar',
        specialization: 'Neurologist',
        qualification: 'MBBS, DM (Neurology)',
        hospital: 'AIIMS, New Delhi',
        rating: 4.8,
        reviewCount: 245,
        experienceYears: 12,
        consultationFee: 1000,
        isAvailable: true,
        isOnline: false,
        availableDays: ['Tue', 'Thu', 'Sat'],
        availableSlots: ['10:00 AM', '11:00 AM', '12:00 PM', '04:00 PM'],
        about:
            'Dr. Rajesh Kumar is a leading neurologist specializing in stroke management, epilepsy, and movement disorders. He has published over 50 research papers in international journals.',
        address: 'AIIMS, Ansari Nagar, New Delhi - 110029',
        phone: '+91 98765 22222',
      ),
      DoctorModel(
        id: 'd003',
        name: 'Dr. Ananya Singh',
        specialization: 'Pediatrician',
        qualification: 'MBBS, MD (Pediatrics)',
        hospital: 'Fortis Hospital, Bangalore',
        rating: 4.9,
        reviewCount: 428,
        experienceYears: 10,
        consultationFee: 600,
        isAvailable: true,
        isOnline: true,
        availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        availableSlots: ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM', '04:00 PM'],
        about:
            'Dr. Ananya Singh is a compassionate pediatrician dedicated to child health and development. She has special expertise in neonatal care and childhood immunization programs.',
        address: 'Fortis Hospital, Bannerghatta Road, Bangalore - 560076',
        phone: '+91 98765 33333',
      ),
      DoctorModel(
        id: 'd004',
        name: 'Dr. Vikram Patel',
        specialization: 'Orthopedic',
        qualification: 'MBBS, MS (Orthopaedics)',
        hospital: 'Kokilaben Hospital, Mumbai',
        rating: 4.7,
        reviewCount: 189,
        experienceYears: 18,
        consultationFee: 900,
        isAvailable: false,
        isOnline: false,
        availableDays: ['Mon', 'Wed', 'Sat'],
        availableSlots: ['11:00 AM', '12:00 PM', '03:00 PM', '05:00 PM'],
        about:
            'Dr. Vikram Patel is an expert orthopedic surgeon specializing in joint replacement, sports injuries, and spine surgery. He has performed over 3000 successful joint replacement surgeries.',
        address: 'Kokilaben Dhirubhai Ambani Hospital, Andheri West, Mumbai - 400053',
        phone: '+91 98765 44444',
      ),
      DoctorModel(
        id: 'd005',
        name: 'Dr. Sunita Rao',
        specialization: 'Dermatologist',
        qualification: 'MBBS, MD (Dermatology)',
        hospital: 'Manipal Hospital, Chennai',
        rating: 4.6,
        reviewCount: 156,
        experienceYears: 8,
        consultationFee: 700,
        isAvailable: true,
        isOnline: true,
        availableDays: ['Tue', 'Thu', 'Fri', 'Sat'],
        availableSlots: ['10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM', '04:00 PM'],
        about:
            'Dr. Sunita Rao is a skilled dermatologist with expertise in cosmetic dermatology, hair disorders, and skin cancer treatment. She is known for her patient-centric approach.',
        address: 'Manipal Hospital, Anna Nagar, Chennai - 600040',
        phone: '+91 98765 55555',
      ),
      DoctorModel(
        id: 'd006',
        name: 'Dr. Arun Nair',
        specialization: 'General',
        qualification: 'MBBS, MD (General Medicine)',
        hospital: 'City Medical Center, Kochi',
        rating: 4.5,
        reviewCount: 302,
        experienceYears: 20,
        consultationFee: 400,
        isAvailable: true,
        isOnline: true,
        availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        availableSlots: ['08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'],
        about:
            'Dr. Arun Nair is a highly experienced general physician providing comprehensive primary care. He is known for his thorough diagnosis and holistic treatment approach.',
        address: 'City Medical Center, MG Road, Kochi - 682016',
        phone: '+91 98765 66666',
      ),
    ];
  }
}
