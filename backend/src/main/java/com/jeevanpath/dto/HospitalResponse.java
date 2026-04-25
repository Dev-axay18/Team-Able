package com.jeevanpath.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class HospitalResponse {
    private Long id;
    private String name;
    private String address;
    private Double latitude;
    private Double longitude;
    private String phone;
    private String emergencyPhone;
    private String email;
    private String facilities;
    private Boolean hasEmergency;
    private Boolean hasAmbulance;
    private Boolean hasICU;
    private Integer bedCount;
    private Double rating;
    private String type;
    private String imageUrl;
    private Boolean available24x7;
    private Double distance; // Distance in kilometers from user's location
}
