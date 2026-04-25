package com.jeevanpath.config;

import com.jeevanpath.model.Doctor;
import com.jeevanpath.model.User;
import com.jeevanpath.repository.DoctorRepository;
import com.jeevanpath.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final DoctorRepository doctorRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        seedUsers();
        seedDoctors();
        log.info("✅ JeevanPath data seeding complete");
    }

    private void seedUsers() {
        if (userRepository.count() > 0) return;

        userRepository.save(User.builder()
                .name("Arjun Sharma")
                .email("arjun@example.com")
                .phone("+91 98765 43210")
                .password(passwordEncoder.encode("password123"))
                .bloodGroup("O+")
                .age(32)
                .gender("Male")
                .allergies(List.of("Penicillin"))
                .conditions(List.of("Hypertension"))
                .emergencyContact("Priya Sharma")
                .emergencyPhone("+91 98765 43211")
                .role(User.Role.PATIENT)
                .build());

        log.info("✅ Seeded demo user: arjun@example.com / password123");
    }

    private void seedDoctors() {
        if (doctorRepository.count() > 0) return;

        doctorRepository.saveAll(List.of(
            Doctor.builder()
                .name("Dr. Priya Mehta")
                .specialization("Cardiologist")
                .qualification("MBBS, MD (Cardiology)")
                .hospital("Apollo Hospital, Mumbai")
                .rating(4.9)
                .reviewCount(312)
                .experienceYears(15)
                .consultationFee(800.0)
                .available(true)
                .online(true)
                .availableDays(List.of("Mon", "Wed", "Fri"))
                .availableSlots(List.of("09:00 AM", "10:00 AM", "11:00 AM", "02:00 PM", "03:00 PM"))
                .about("Dr. Priya Mehta is a renowned cardiologist with 15 years of experience.")
                .address("Apollo Hospital, Juhu, Mumbai - 400049")
                .phone("+91 98765 11111")
                .build(),

            Doctor.builder()
                .name("Dr. Rajesh Kumar")
                .specialization("Neurologist")
                .qualification("MBBS, DM (Neurology)")
                .hospital("AIIMS, New Delhi")
                .rating(4.8)
                .reviewCount(245)
                .experienceYears(12)
                .consultationFee(1000.0)
                .available(true)
                .online(false)
                .availableDays(List.of("Tue", "Thu", "Sat"))
                .availableSlots(List.of("10:00 AM", "11:00 AM", "12:00 PM", "04:00 PM"))
                .about("Dr. Rajesh Kumar is a leading neurologist specializing in stroke management.")
                .address("AIIMS, Ansari Nagar, New Delhi - 110029")
                .phone("+91 98765 22222")
                .build(),

            Doctor.builder()
                .name("Dr. Ananya Singh")
                .specialization("Pediatrician")
                .qualification("MBBS, MD (Pediatrics)")
                .hospital("Fortis Hospital, Bangalore")
                .rating(4.9)
                .reviewCount(428)
                .experienceYears(10)
                .consultationFee(600.0)
                .available(true)
                .online(true)
                .availableDays(List.of("Mon", "Tue", "Wed", "Thu", "Fri"))
                .availableSlots(List.of("09:00 AM", "10:00 AM", "11:00 AM", "02:00 PM", "03:00 PM"))
                .about("Dr. Ananya Singh is a compassionate pediatrician dedicated to child health.")
                .address("Fortis Hospital, Bannerghatta Road, Bangalore - 560076")
                .phone("+91 98765 33333")
                .build(),

            Doctor.builder()
                .name("Dr. Sunita Rao")
                .specialization("Dermatologist")
                .qualification("MBBS, MD (Dermatology)")
                .hospital("Manipal Hospital, Chennai")
                .rating(4.6)
                .reviewCount(156)
                .experienceYears(8)
                .consultationFee(700.0)
                .available(true)
                .online(true)
                .availableDays(List.of("Tue", "Thu", "Fri", "Sat"))
                .availableSlots(List.of("10:00 AM", "11:00 AM", "02:00 PM", "03:00 PM"))
                .about("Dr. Sunita Rao is a skilled dermatologist with expertise in cosmetic dermatology.")
                .address("Manipal Hospital, Anna Nagar, Chennai - 600040")
                .phone("+91 98765 55555")
                .build()
        ));

        log.info("✅ Seeded {} doctors", doctorRepository.count());
    }
}
