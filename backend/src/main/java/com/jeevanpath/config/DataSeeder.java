package com.jeevanpath.config;

import com.jeevanpath.model.Doctor;
import com.jeevanpath.model.Hospital;
import com.jeevanpath.model.User;
import com.jeevanpath.repository.DoctorRepository;
import com.jeevanpath.repository.HospitalRepository;
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
    private final HospitalRepository hospitalRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        seedUsers();
        seedDoctors();
        seedHospitals();
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

    private void seedHospitals() {
        if (hospitalRepository.count() > 0) return;

        // Mumbai hospitals (around 19.0760, 72.8777)
        hospitalRepository.saveAll(List.of(
            Hospital.builder()
                .name("Apollo Hospital")
                .address("Plot No. 13, Parsik Hill Road, Sector 23, CBD Belapur, Navi Mumbai")
                .latitude(19.0176)
                .longitude(73.0322)
                .phone("+91 22 3989 8900")
                .emergencyPhone("+91 22 3989 8901")
                .email("info@apollohospitals.com")
                .facilities("Emergency, ICU, Cardiology, Neurology, Orthopedics, Pediatrics")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(500)
                .rating(4.5)
                .type("Multi-specialty")
                .available24x7(true)
                .build(),

            Hospital.builder()
                .name("Kokilaben Dhirubhai Ambani Hospital")
                .address("Rao Saheb Achutrao Patwardhan Marg, Four Bungalows, Andheri West, Mumbai")
                .latitude(19.1258)
                .longitude(72.8347)
                .phone("+91 22 4269 6969")
                .emergencyPhone("+91 22 4269 6900")
                .email("info@kokilabenhospital.com")
                .facilities("Emergency, ICU, Trauma Center, Cardiology, Neurology, Oncology")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(750)
                .rating(4.7)
                .type("Multi-specialty")
                .available24x7(true)
                .build(),

            Hospital.builder()
                .name("Lilavati Hospital")
                .address("A-791, Bandra Reclamation, Bandra West, Mumbai")
                .latitude(19.0544)
                .longitude(72.8194)
                .phone("+91 22 2640 0000")
                .emergencyPhone("+91 22 2640 0111")
                .email("info@lilavatihospital.com")
                .facilities("Emergency, ICU, Cardiology, Neurosurgery, Orthopedics, Gastroenterology")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(323)
                .rating(4.6)
                .type("Multi-specialty")
                .available24x7(true)
                .build(),

            Hospital.builder()
                .name("Hinduja Hospital")
                .address("Veer Savarkar Marg, Mahim, Mumbai")
                .latitude(19.0433)
                .longitude(72.8397)
                .phone("+91 22 2444 9199")
                .emergencyPhone("+91 22 2444 9222")
                .email("info@hindujahospital.com")
                .facilities("Emergency, ICU, Cardiology, Nephrology, Oncology, Orthopedics")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(450)
                .rating(4.5)
                .type("Multi-specialty")
                .available24x7(true)
                .build(),

            Hospital.builder()
                .name("Breach Candy Hospital")
                .address("60-A, Bhulabhai Desai Road, Mumbai")
                .latitude(18.9697)
                .longitude(72.8058)
                .phone("+91 22 2367 1888")
                .emergencyPhone("+91 22 2367 1999")
                .email("info@breachcandyhospital.org")
                .facilities("Emergency, ICU, Cardiology, Neurology, Orthopedics, Maternity")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(200)
                .rating(4.4)
                .type("Multi-specialty")
                .available24x7(true)
                .build(),

            Hospital.builder()
                .name("Jaslok Hospital")
                .address("15, Dr. G. Deshmukh Marg, Pedder Road, Mumbai")
                .latitude(18.9697)
                .longitude(72.8058)
                .phone("+91 22 6657 3333")
                .emergencyPhone("+91 22 6657 3434")
                .email("info@jaslokhospital.net")
                .facilities("Emergency, ICU, Cardiology, Neurology, Oncology, Transplant")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(350)
                .rating(4.6)
                .type("Multi-specialty")
                .available24x7(true)
                .build(),

            Hospital.builder()
                .name("Fortis Hospital")
                .address("Mulund Goregaon Link Road, Mulund West, Mumbai")
                .latitude(19.1722)
                .longitude(72.9561)
                .phone("+91 22 6754 7000")
                .emergencyPhone("+91 22 6754 7111")
                .email("info@fortishealthcare.com")
                .facilities("Emergency, ICU, Cardiology, Neurology, Orthopedics, Oncology")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(315)
                .rating(4.3)
                .type("Multi-specialty")
                .available24x7(true)
                .build(),

            Hospital.builder()
                .name("Nanavati Super Speciality Hospital")
                .address("S.V. Road, Vile Parle West, Mumbai")
                .latitude(19.1076)
                .longitude(72.8263)
                .phone("+91 22 2626 7500")
                .emergencyPhone("+91 22 2626 7600")
                .email("info@nanavatihospital.org")
                .facilities("Emergency, ICU, Cardiology, Neurology, Oncology, Transplant")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(350)
                .rating(4.5)
                .type("Multi-specialty")
                .available24x7(true)
                .build(),

            Hospital.builder()
                .name("Wockhardt Hospital")
                .address("1877, Dr. Anandrao Nair Marg, Mumbai Central, Mumbai")
                .latitude(18.9750)
                .longitude(72.8258)
                .phone("+91 22 2498 3636")
                .emergencyPhone("+91 22 2498 3737")
                .email("info@wockhardthospitals.com")
                .facilities("Emergency, ICU, Cardiology, Neurology, Orthopedics, Nephrology")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(350)
                .rating(4.2)
                .type("Multi-specialty")
                .available24x7(true)
                .build(),

            Hospital.builder()
                .name("Holy Family Hospital")
                .address("St. Andrew's Road, Bandra West, Mumbai")
                .latitude(19.0596)
                .longitude(72.8295)
                .phone("+91 22 2640 5151")
                .emergencyPhone("+91 22 2640 5252")
                .email("info@holyfamilyhospital.org")
                .facilities("Emergency, ICU, Maternity, Pediatrics, General Medicine")
                .hasEmergency(true)
                .hasAmbulance(true)
                .hasICU(true)
                .bedCount(180)
                .rating(4.3)
                .type("General")
                .available24x7(true)
                .build()
        ));

        log.info("✅ Seeded {} hospitals", hospitalRepository.count());
    }
}
