package com.jeevanpath.service;

import com.jeevanpath.model.Doctor;
import com.jeevanpath.repository.DoctorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DoctorService {

    private final DoctorRepository doctorRepository;

    public List<Doctor> getAllDoctors() {
        return doctorRepository.findAll();
    }

    public Doctor getDoctorById(String id) {
        return doctorRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Doctor not found: " + id));
    }

    public List<Doctor> searchDoctors(String query, String specialization) {
        if (query == null && specialization == null) {
            return doctorRepository.findAll();
        }
        return doctorRepository.findByFilters(specialization, query);
    }

    public List<Doctor> getTopDoctors() {
        return doctorRepository.findTop10ByOrderByRatingDesc();
    }

    public List<Doctor> getAvailableDoctors() {
        return doctorRepository.findByAvailableTrue();
    }

    public Doctor saveDoctor(Doctor doctor) {
        return doctorRepository.save(doctor);
    }
}
