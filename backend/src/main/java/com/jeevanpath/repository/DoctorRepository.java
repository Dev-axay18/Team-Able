package com.jeevanpath.repository;

import com.jeevanpath.model.Doctor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DoctorRepository extends JpaRepository<Doctor, String> {

    List<Doctor> findBySpecialization(String specialization);

    List<Doctor> findByAvailableTrue();

    @Query("SELECT d FROM Doctor d WHERE " +
           "LOWER(d.name) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(d.specialization) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(d.hospital) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Doctor> searchDoctors(@Param("query") String query);

    @Query("SELECT d FROM Doctor d WHERE " +
           "(:specialization IS NULL OR d.specialization = :specialization) AND " +
           "(:query IS NULL OR LOWER(d.name) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(d.hospital) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<Doctor> findByFilters(
            @Param("specialization") String specialization,
            @Param("query") String query);

    List<Doctor> findTop10ByOrderByRatingDesc();
}
