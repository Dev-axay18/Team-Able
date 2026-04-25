package com.jeevanpath.repository;

import com.jeevanpath.model.Hospital;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HospitalRepository extends JpaRepository<Hospital, Long> {
    
    /**
     * Find hospitals within a radius using Haversine formula
     * @param latitude User's current latitude
     * @param longitude User's current longitude
     * @param radiusKm Radius in kilometers
     * @return List of hospitals within the radius
     */
    @Query(value = "SELECT * FROM hospitals h WHERE " +
            "(6371 * acos(cos(radians(:latitude)) * cos(radians(h.latitude)) * " +
            "cos(radians(h.longitude) - radians(:longitude)) + " +
            "sin(radians(:latitude)) * sin(radians(h.latitude)))) <= :radiusKm " +
            "ORDER BY (6371 * acos(cos(radians(:latitude)) * cos(radians(h.latitude)) * " +
            "cos(radians(h.longitude) - radians(:longitude)) + " +
            "sin(radians(:latitude)) * sin(radians(h.latitude))))",
            nativeQuery = true)
    List<Hospital> findHospitalsWithinRadius(
            @Param("latitude") Double latitude,
            @Param("longitude") Double longitude,
            @Param("radiusKm") Double radiusKm
    );
    
    List<Hospital> findByHasEmergencyTrue();
    
    List<Hospital> findByType(String type);
}
