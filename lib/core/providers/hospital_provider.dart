import 'package:flutter/foundation.dart';
import '../models/hospital_model.dart';

enum HospitalStatus { initial, loading, loaded, error }

class HospitalProvider extends ChangeNotifier {
  HospitalStatus _status = HospitalStatus.initial;
  List<HospitalModel> _hospitals = [];
  String? _errorMessage;

  HospitalStatus get status => _status;
  List<HospitalModel> get hospitals => _hospitals;
  String? get errorMessage => _errorMessage;

  // Simulated API call - Replace with actual API call
  Future<void> fetchNearbyHospitals(double latitude, double longitude, {double radiusKm = 5.0}) async {
    _status = HospitalStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('http://your-api/api/hospitals/nearby?latitude=$latitude&longitude=$longitude&radius=$radiusKm')
      // );

      // Simulated hospital data for Mumbai area (19.0760, 72.8777)
      _hospitals = _generateMockHospitals(latitude, longitude);

      _status = HospitalStatus.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load hospitals: ${e.toString()}';
      _status = HospitalStatus.error;
      notifyListeners();
    }
  }

  // Mock data generator - Remove when API is ready
  List<HospitalModel> _generateMockHospitals(double userLat, double userLon) {
    final mockData = [
      {
        'id': 1,
        'name': 'Apollo Hospital',
        'address': 'Plot No. 13, Parsik Hill Road, Sector 23, CBD Belapur, Navi Mumbai',
        'latitude': 19.0176,
        'longitude': 73.0322,
        'phone': '+91 22 3989 8900',
        'emergencyPhone': '+91 22 3989 8901',
        'email': 'info@apollohospitals.com',
        'facilities': 'Emergency, ICU, Cardiology, Neurology, Orthopedics, Pediatrics',
        'hasEmergency': true,
        'hasAmbulance': true,
        'hasICU': true,
        'bedCount': 500,
        'rating': 4.5,
        'type': 'Multi-specialty',
        'available24x7': true,
      },
      {
        'id': 2,
        'name': 'Kokilaben Dhirubhai Ambani Hospital',
        'address': 'Rao Saheb Achutrao Patwardhan Marg, Four Bungalows, Andheri West, Mumbai',
        'latitude': 19.1258,
        'longitude': 72.8347,
        'phone': '+91 22 4269 6969',
        'emergencyPhone': '+91 22 4269 6900',
        'email': 'info@kokilabenhospital.com',
        'facilities': 'Emergency, ICU, Trauma Center, Cardiology, Neurology, Oncology',
        'hasEmergency': true,
        'hasAmbulance': true,
        'hasICU': true,
        'bedCount': 750,
        'rating': 4.7,
        'type': 'Multi-specialty',
        'available24x7': true,
      },
      {
        'id': 3,
        'name': 'Lilavati Hospital',
        'address': 'A-791, Bandra Reclamation, Bandra West, Mumbai',
        'latitude': 19.0544,
        'longitude': 72.8194,
        'phone': '+91 22 2640 0000',
        'emergencyPhone': '+91 22 2640 0111',
        'email': 'info@lilavatihospital.com',
        'facilities': 'Emergency, ICU, Cardiology, Neurosurgery, Orthopedics, Gastroenterology',
        'hasEmergency': true,
        'hasAmbulance': true,
        'hasICU': true,
        'bedCount': 323,
        'rating': 4.6,
        'type': 'Multi-specialty',
        'available24x7': true,
      },
      {
        'id': 4,
        'name': 'Hinduja Hospital',
        'address': 'Veer Savarkar Marg, Mahim, Mumbai',
        'latitude': 19.0433,
        'longitude': 72.8397,
        'phone': '+91 22 2444 9199',
        'emergencyPhone': '+91 22 2444 9222',
        'email': 'info@hindujahospital.com',
        'facilities': 'Emergency, ICU, Cardiology, Nephrology, Oncology, Orthopedics',
        'hasEmergency': true,
        'hasAmbulance': true,
        'hasICU': true,
        'bedCount': 450,
        'rating': 4.5,
        'type': 'Multi-specialty',
        'available24x7': true,
      },
      {
        'id': 5,
        'name': 'Nanavati Super Speciality Hospital',
        'address': 'S.V. Road, Vile Parle West, Mumbai',
        'latitude': 19.1076,
        'longitude': 72.8263,
        'phone': '+91 22 2626 7500',
        'emergencyPhone': '+91 22 2626 7600',
        'email': 'info@nanavatihospital.org',
        'facilities': 'Emergency, ICU, Cardiology, Neurology, Oncology, Transplant',
        'hasEmergency': true,
        'hasAmbulance': true,
        'hasICU': true,
        'bedCount': 350,
        'rating': 4.5,
        'type': 'Multi-specialty',
        'available24x7': true,
      },
    ];

    // Calculate distances and add to data
    return mockData.map((data) {
      final hospitalLat = data['latitude'] as double;
      final hospitalLon = data['longitude'] as double;
      final distance = _calculateDistance(userLat, userLon, hospitalLat, hospitalLon);
      
      data['distance'] = distance;
      return HospitalModel.fromJson(data);
    }).where((hospital) => hospital.distance! <= 5.0) // Filter within 5km
      .toList()
      ..sort((a, b) => a.distance!.compareTo(b.distance!)); // Sort by distance
  }

  // Haversine formula to calculate distance
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _degreesToRadians(lat1).cos() *
        _degreesToRadians(lat2).cos() *
        (dLon / 2).sin() *
        (dLon / 2).sin();
    
    final c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  void clearHospitals() {
    _hospitals = [];
    _status = HospitalStatus.initial;
    notifyListeners();
  }
}
