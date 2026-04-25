package com.jeevanpath.controller;

import com.jeevanpath.model.Doctor;
import com.jeevanpath.service.DoctorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/doctors")
@RequiredArgsConstructor
public class DoctorController {

    private final DoctorService doctorService;

    @GetMapping
    public ResponseEntity<List<Doctor>> getAllDoctors(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String specialization) {
        if (query != null || specialization != null) {
            return ResponseEntity.ok(doctorService.searchDoctors(query, specialization));
        }
        return ResponseEntity.ok(doctorService.getAllDoctors());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Doctor> getDoctorById(@PathVariable String id) {
        return ResponseEntity.ok(doctorService.getDoctorById(id));
    }

    @GetMapping("/top")
    public ResponseEntity<List<Doctor>> getTopDoctors() {
        return ResponseEntity.ok(doctorService.getTopDoctors());
    }

    @GetMapping("/available")
    public ResponseEntity<List<Doctor>> getAvailableDoctors() {
        return ResponseEntity.ok(doctorService.getAvailableDoctors());
    }
}
