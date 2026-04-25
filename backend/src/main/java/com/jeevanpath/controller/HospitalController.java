package com.jeevanpath.controller;

import com.jeevanpath.dto.HospitalResponse;
import com.jeevanpath.service.HospitalService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/hospitals")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class HospitalController {
    
    private final HospitalService hospitalService;
    
    /**
     * Get hospitals within specified radius (default 5km)
     * GET /api/hospitals/nearby?latitude=19.0760&longitude=72.8777&radius=5
     */
    @GetMapping("/nearby")
    public ResponseEntity<List<HospitalResponse>> getNearbyHospitals(
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam(defaultValue = "5.0") Double radius) {
        
        List<HospitalResponse> hospitals = hospitalService.getHospitalsNearby(latitude, longitude, radius);
        return ResponseEntity.ok(hospitals);
    }
    
    /**
     * Get all hospitals
     * GET /api/hospitals
     */
    @GetMapping
    public ResponseEntity<List<HospitalResponse>> getAllHospitals() {
        List<HospitalResponse> hospitals = hospitalService.getAllHospitals();
        return ResponseEntity.ok(hospitals);
    }
    
    /**
     * Get hospital by ID
     * GET /api/hospitals/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<HospitalResponse> getHospitalById(@PathVariable Long id) {
        HospitalResponse hospital = hospitalService.getHospitalById(id);
        return ResponseEntity.ok(hospital);
    }
    
    /**
     * Get emergency hospitals only
     * GET /api/hospitals/emergency
     */
    @GetMapping("/emergency")
    public ResponseEntity<List<HospitalResponse>> getEmergencyHospitals() {
        List<HospitalResponse> hospitals = hospitalService.getEmergencyHospitals();
        return ResponseEntity.ok(hospitals);
    }
}
