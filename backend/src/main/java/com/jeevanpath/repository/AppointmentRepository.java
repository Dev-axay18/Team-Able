package com.jeevanpath.repository;

import com.jeevanpath.model.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, String> {

    List<Appointment> findByUserIdOrderByAppointmentDateTimeDesc(String userId);

    List<Appointment> findByDoctorIdOrderByAppointmentDateTimeDesc(String doctorId);

    @Query("SELECT a FROM Appointment a WHERE a.user.id = :userId " +
           "AND a.appointmentDateTime > :now " +
           "AND a.status != 'CANCELLED' " +
           "ORDER BY a.appointmentDateTime ASC")
    List<Appointment> findUpcomingByUserId(
            @Param("userId") String userId,
            @Param("now") LocalDateTime now);

    @Query("SELECT a FROM Appointment a WHERE a.doctor.id = :doctorId " +
           "AND a.appointmentDateTime BETWEEN :start AND :end")
    List<Appointment> findByDoctorAndDateRange(
            @Param("doctorId") String doctorId,
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);

    boolean existsByDoctorIdAndAppointmentDateTime(String doctorId, LocalDateTime dateTime);
}
