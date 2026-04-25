package com.jeevanpath.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "hospitals")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Hospital {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String address;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    private String phone;
    private String emergencyPhone;
    private String email;
    
    @Column(columnDefinition = "TEXT")
    private String facilities;
    
    private Boolean hasEmergency;
    private Boolean hasAmbulance;
    private Boolean hasICU;
    private Integer bedCount;
    private Double rating;
    private String type; // Government, Private, Multi-specialty, etc.
    private String imageUrl;
    
    @Column(name = "available_24x7")
    private Boolean available24x7;
}
