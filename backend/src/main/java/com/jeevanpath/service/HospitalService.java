package com.jeevanpath.service;

import com.jeevanpath.dto.HospitalResponse;
import com.jeevanpath.model.Hospital;
import com.jeevanpath.repository.HospitalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HospitalService {
    
    private final HospitalRepository hospitalRepository;
    
    /**
     * Calculate distance between two coordinates using Haversine formula
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int EARTH_RADIUS_KM = 6371;
        
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return EARTH_RADIUS_KM * c;
    }
    
    /**
     * Convert Hospital entity to HospitalResponse DTO
     */
    private HospitalResponse toResponse(Hospital hospital, Double userLat, Double userLon) {
        HospitalResponse response = new HospitalResponse();
        response.setId(hospital.getId());
        response.setName(hospital.getName());
        response.setAddress(hospital.getAddress());
        response.setLatitude(hospital.getLatitude());
        response.setLongitude(hospital.getLongitude());
        response.setPhone(hospital.getPhone());
        response.setEmergencyPhone(hospital.getEmergencyPhone());
        response.setEmail(hospital.getEmail());
        response.setFacilities(hospital.getFacilities());
        response.setHasEmergency(hospital.getHasEmergency());
        response.setHasAmbulance(hospital.getHasAmbulance());
        response.setHasICU(hospital.getHasICU());
        response.setBedCount(hospital.getBedCount());
        response.setRating(hospital.getRating());
        response.setType(hospital.getType());
        response.setImageUrl(hospital.getImageUrl());
        response.setAvailable24x7(hospital.getAvailable24x7());
        
        // Calculate distance
        if (userLat != null && userLon != null) {
            double distance = calculateDistance(userLat, userLon, 
                                               hospital.getLatitude(), 
                                               hospital.getLongitude());
            response.setDistance(Math.round(distance * 10.0) / 10.0); // Round to 1 decimal
        }
        
        return response;
    }
    
    /**
     * Get hospitals within specified radius
     */
    public List<HospitalResponse> getHospitalsNearby(Double latitude, Double longitude, Double radiusKm) {
        List<Hospital> hospitals = hospitalRepository.findHospitalsWithinRadius(latitude, longitude, radiusKm);
        
        return hospitals.stream()
                .map(hospital -> toResponse(hospital, latitude, longitude))
                .collect(Collectors.toList());
    }
    
    /**
     * Get all hospitals
     */
    public List<HospitalResponse> getAllHospitals() {
        return hospitalRepository.findAll().stream()
                .map(hospital -> toResponse(hospital, null, null))
                .collect(Collectors.toList());
    }
    
    /**
     * Get hospital by ID
     */
    public HospitalResponse getHospitalById(Long id) {
        Hospital hospital = hospitalRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Hospital not found with id: " + id));
        return toResponse(hospital, null, null);
    }
    
    /**
     * Get emergency hospitals only
     */
    public List<HospitalResponse> getEmergencyHospitals() {
        return hospitalRepository.findByHasEmergencyTrue().stream()
                .map(hospital -> toResponse(hospital, null, null))
                .collect(Collectors.toList());
    }
}
