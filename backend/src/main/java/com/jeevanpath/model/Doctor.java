package com.jeevanpath.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "doctors")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Doctor {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @NotBlank
    private String name;

    @NotBlank
    private String specialization;

    @NotBlank
    private String qualification;

    @NotBlank
    private String hospital;

    private String profileImage;

    @Builder.Default
    private Double rating = 0.0;

    @Builder.Default
    private Integer reviewCount = 0;

    @Builder.Default
    private Integer experienceYears = 0;

    @Builder.Default
    private Double consultationFee = 0.0;

    @Builder.Default
    private boolean available = true;

    @Builder.Default
    private boolean online = false;

    @ElementCollection
    @CollectionTable(name = "doctor_available_days", joinColumns = @JoinColumn(name = "doctor_id"))
    @Column(name = "day")
    private List<String> availableDays;

    @ElementCollection
    @CollectionTable(name = "doctor_slots", joinColumns = @JoinColumn(name = "doctor_id"))
    @Column(name = "slot")
    private List<String> availableSlots;

    @Column(length = 2000)
    private String about;

    private String address;
    private Double latitude;
    private Double longitude;
    private String phone;

    @Column(updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
