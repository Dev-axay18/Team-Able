package com.jeevanpath.service;

import com.jeevanpath.dto.AppointmentRequest;
import com.jeevanpath.model.Appointment;
import com.jeevanpath.model.Doctor;
import com.jeevanpath.model.User;
import com.jeevanpath.repository.AppointmentRepository;
import com.jeevanpath.repository.DoctorRepository;
import com.jeevanpath.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AppointmentService {

    private final AppointmentRepository appointmentRepository;
    private final DoctorRepository doctorRepository;
    private final UserRepository userRepository;

    public List<Appointment> getUserAppointments(String userId) {
        return appointmentRepository.findByUserIdOrderByAppointmentDateTimeDesc(userId);
    }

    public List<Appointment> getUpcomingAppointments(String userId) {
        return appointmentRepository.findUpcomingByUserId(userId, LocalDateTime.now());
    }

    @Transactional
    public Appointment bookAppointment(String userId, AppointmentRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Doctor doctor = doctorRepository.findById(request.getDoctorId())
                .orElseThrow(() -> new IllegalArgumentException("Doctor not found"));

        // Check if slot is already booked
        boolean slotTaken = appointmentRepository.existsByDoctorIdAndAppointmentDateTime(
                doctor.getId(), request.getAppointmentDateTime());

        if (slotTaken) {
            throw new IllegalStateException("This time slot is already booked");
        }

        Appointment.AppointmentType type = request.getType() != null
                ? Appointment.AppointmentType.valueOf(request.getType())
                : Appointment.AppointmentType.IN_PERSON;

        double fee = type == Appointment.AppointmentType.ONLINE
                ? doctor.getConsultationFee() * 0.8
                : doctor.getConsultationFee();

        Appointment appointment = Appointment.builder()
                .user(user)
                .doctor(doctor)
                .appointmentDateTime(request.getAppointmentDateTime())
                .status(Appointment.AppointmentStatus.PENDING)
                .type(type)
                .notes(request.getNotes())
                .fee(fee)
                .build();

        return appointmentRepository.save(appointment);
    }

    @Transactional
    public Appointment cancelAppointment(String appointmentId, String userId) {
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new IllegalArgumentException("Appointment not found"));

        if (!appointment.getUser().getId().equals(userId)) {
            throw new SecurityException("Not authorized to cancel this appointment");
        }

        if (appointment.getStatus() == Appointment.AppointmentStatus.COMPLETED) {
            throw new IllegalStateException("Cannot cancel a completed appointment");
        }

        appointment.setStatus(Appointment.AppointmentStatus.CANCELLED);
        return appointmentRepository.save(appointment);
    }

    @Transactional
    public Appointment updateStatus(String appointmentId, String status) {
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new IllegalArgumentException("Appointment not found"));

        appointment.setStatus(Appointment.AppointmentStatus.valueOf(status));
        return appointmentRepository.save(appointment);
    }
}
