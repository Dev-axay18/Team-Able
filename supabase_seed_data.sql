-- ============================================================
-- JEEVANPATH - SEED DATA FOR SUPABASE
-- Sample data for testing and development
-- ============================================================

-- ============================================================
-- HOSPITALS SEED DATA (Mumbai Area)
-- ============================================================

INSERT INTO public.hospitals (
    name, address, latitude, longitude, phone, emergency_phone, email,
    facilities, has_emergency, has_ambulance, has_icu, bed_count,
    general_ward_beds, private_room_beds, icu_beds, pediatric_beds,
    maternity_beds, isolation_beds, burn_unit_beds,
    rating, review_count, type, available_24x7, is_active
) VALUES
(
    'Apollo Hospital Navi Mumbai',
    'Plot No. 13, Parsik Hill Road, Sector 23, CBD Belapur, Navi Mumbai, Maharashtra 400614',
    19.0176, 73.0322,
    '+91 22 3989 8900', '+91 22 3989 8901',
    'info@apollohospitals.com',
    'Emergency, ICU, Cardiology, Neurology, Orthopedics, Pediatrics, Maternity, Radiology, Laboratory, Pharmacy, Blood Bank',
    true, true, true, 500,
    200, 150, 50, 40, 30, 20, 10,
    4.5, 1250, 'Multi-specialty', true, true
),
(
    'Kokilaben Dhirubhai Ambani Hospital',
    'Rao Saheb Achutrao Patwardhan Marg, Four Bungalows, Andheri West, Mumbai, Maharashtra 400053',
    19.1197, 72.8346,
    '+91 22 4269 6969', '+91 22 4269 6900',
    'info@kokilabenhospital.com',
    'Emergency, ICU, Cardiology, Neurology, Oncology, Orthopedics, Pediatrics, Maternity, Transplant, Radiology, Laboratory',
    true, true, true, 750,
    300, 250, 80, 50, 40, 20, 10,
    4.7, 2100, 'Multi-specialty', true, true
),
(
    'Lilavati Hospital and Research Centre',
    'A-791, Bandra Reclamation, Bandra West, Mumbai, Maharashtra 400050',
    19.0521, 72.8224,
    '+91 22 2640 0000', '+91 22 2640 0111',
    'info@lilavatihospital.com',
    'Emergency, ICU, Cardiology, Neurology, Orthopedics, Gastroenterology, Nephrology, Urology, Pediatrics, Maternity',
    true, true, true, 323,
    150, 100, 40, 20, 10, 3, 0,
    4.6, 1800, 'Multi-specialty', true, true
),
(
    'Hinduja Hospital',
    'Veer Savarkar Marg, Mahim, Mumbai, Maharashtra 400016',
    19.0387, 72.8408,
    '+91 22 2444 9199', '+91 22 2444 9222',
    'info@hindujahospital.com',
    'Emergency, ICU, Cardiology, Neurology, Orthopedics, Oncology, Nephrology, Gastroenterology, Pediatrics',
    true, true, true, 350,
    180, 100, 40, 20, 10, 0, 0,
    4.5, 1600, 'Multi-specialty', true, true
),
(
    'Breach Candy Hospital',
    '60-A, Bhulabhai Desai Road, Breach Candy, Mumbai, Maharashtra 400026',
    18.9697, 72.8053,
    '+91 22 2367 1888', '+91 22 2367 1999',
    'info@breachcandyhospital.org',
    'Emergency, ICU, Cardiology, Orthopedics, Neurology, General Surgery, Pediatrics, Maternity, Radiology',
    true, true, true, 200,
    80, 80, 25, 10, 5, 0, 0,
    4.4, 950, 'Multi-specialty', true, true
),
(
    'Jaslok Hospital and Research Centre',
    '15, Dr. Gopalrao Deshmukh Marg, Pedder Road, Mumbai, Maharashtra 400026',
    18.9697, 72.8053,
    '+91 22 6657 3333', '+91 22 6657 3434',
    'info@jaslokhospital.net',
    'Emergency, ICU, Cardiology, Neurology, Orthopedics, Oncology, Nephrology, Gastroenterology, Pediatrics, Maternity',
    true, true, true, 350,
    150, 120, 45, 20, 10, 5, 0,
    4.6, 1400, 'Multi-specialty', true, true
),
(
    'Fortis Hospital Mulund',
    'Mulund Goregaon Link Road, Nahur West, Mumbai, Maharashtra 400078',
    19.1722, 72.9561,
    '+91 22 6754 7000', '+91 22 6754 7100',
    'info@fortishealthcare.com',
    'Emergency, ICU, Cardiology, Neurology, Orthopedics, Oncology, Nephrology, Urology, Pediatrics, Maternity',
    true, true, true, 315,
    140, 100, 40, 20, 10, 5, 0,
    4.5, 1100, 'Multi-specialty', true, true
),
(
    'Nanavati Super Speciality Hospital',
    'S.V. Road, Vile Parle West, Mumbai, Maharashtra 400056',
    19.1076, 72.8339,
    '+91 22 2626 7500', '+91 22 2626 7600',
    'info@nanavati.com',
    'Emergency, ICU, Cardiology, Neurology, Orthopedics, Oncology, Nephrology, Gastroenterology, Pediatrics, Maternity, Transplant',
    true, true, true, 350,
    160, 120, 40, 20, 10, 0, 0,
    4.6, 1700, 'Multi-specialty', true, true
),
(
    'Wockhardt Hospital Mumbai Central',
    '1877, Dr. Anandrao Nair Marg, Near Agripada Police Station, Mumbai Central, Mumbai, Maharashtra 400011',
    18.9750, 72.8258,
    '+91 22 2498 3636', '+91 22 2498 3737',
    'info@wockhardthospitals.com',
    'Emergency, ICU, Cardiology, Neurology, Orthopedics, Oncology, Nephrology, Urology, Pediatrics, Maternity',
    true, true, true, 350,
    150, 120, 45, 20, 10, 5, 0,
    4.5, 1300, 'Multi-specialty', true, true
),
(
    'Holy Family Hospital',
    'St. Andrew Road, Bandra West, Mumbai, Maharashtra 400050',
    19.0596, 72.8295,
    '+91 22 2640 5151', '+91 22 2640 5252',
    'info@holyfamilyhospital.org',
    'Emergency, ICU, General Medicine, Surgery, Orthopedics, Pediatrics, Maternity, Radiology, Laboratory',
    true, true, true, 180,
    90, 50, 20, 10, 10, 0, 0,
    4.3, 800, 'General', true, true
);

-- ============================================================
-- DOCTORS SEED DATA
-- ============================================================

INSERT INTO public.doctors (
    name, specialization, qualification, hospital_name, profile_image,
    rating, review_count, experience_years, consultation_fee,
    is_available, is_online, available_days, available_slots,
    about, phone, email, is_verified
) VALUES
(
    'Dr. Rajesh Kumar',
    'Cardiologist',
    'MBBS, MD (Cardiology), DM (Cardiology)',
    'Apollo Hospital Navi Mumbai',
    'https://randomuser.me/api/portraits/men/1.jpg',
    4.8, 320, 15, 1500.00,
    true, true,
    ARRAY['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    ARRAY['09:00-10:00', '10:00-11:00', '11:00-12:00', '14:00-15:00', '15:00-16:00'],
    'Experienced cardiologist specializing in interventional cardiology and heart failure management.',
    '+91 98765 43210', 'dr.rajesh@apollo.com', true
),
(
    'Dr. Priya Sharma',
    'Pediatrician',
    'MBBS, MD (Pediatrics)',
    'Kokilaben Dhirubhai Ambani Hospital',
    'https://randomuser.me/api/portraits/women/2.jpg',
    4.9, 450, 12, 1200.00,
    true, true,
    ARRAY['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    ARRAY['10:00-11:00', '11:00-12:00', '12:00-13:00', '16:00-17:00', '17:00-18:00'],
    'Specialist in child healthcare, vaccinations, and developmental pediatrics.',
    '+91 98765 43211', 'dr.priya@kokilaben.com', true
),
(
    'Dr. Amit Patel',
    'Orthopedic Surgeon',
    'MBBS, MS (Orthopedics)',
    'Lilavati Hospital and Research Centre',
    'https://randomuser.me/api/portraits/men/3.jpg',
    4.7, 280, 18, 1800.00,
    true, false,
    ARRAY['Monday', 'Wednesday', 'Friday'],
    ARRAY['09:00-10:00', '10:00-11:00', '11:00-12:00'],
    'Expert in joint replacement surgery and sports medicine.',
    '+91 98765 43212', 'dr.amit@lilavati.com', true
),
(
    'Dr. Sneha Desai',
    'Gynecologist',
    'MBBS, MD (Obstetrics & Gynecology)',
    'Hinduja Hospital',
    'https://randomuser.me/api/portraits/women/4.jpg',
    4.8, 390, 14, 1400.00,
    true, true,
    ARRAY['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    ARRAY['10:00-11:00', '11:00-12:00', '14:00-15:00', '15:00-16:00'],
    'Specializing in high-risk pregnancies and minimally invasive gynecological surgery.',
    '+91 98765 43213', 'dr.sneha@hinduja.com', true
),
(
    'Dr. Vikram Singh',
    'Neurologist',
    'MBBS, MD (Medicine), DM (Neurology)',
    'Breach Candy Hospital',
    'https://randomuser.me/api/portraits/men/5.jpg',
    4.9, 410, 20, 2000.00,
    true, true,
    ARRAY['Tuesday', 'Thursday', 'Saturday'],
    ARRAY['09:00-10:00', '10:00-11:00', '11:00-12:00', '14:00-15:00'],
    'Expert in stroke management, epilepsy, and movement disorders.',
    '+91 98765 43214', 'dr.vikram@breachcandy.com', true
),
(
    'Dr. Anjali Mehta',
    'Dermatologist',
    'MBBS, MD (Dermatology)',
    'Jaslok Hospital and Research Centre',
    'https://randomuser.me/api/portraits/women/6.jpg',
    4.6, 310, 10, 1000.00,
    true, true,
    ARRAY['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    ARRAY['10:00-11:00', '11:00-12:00', '12:00-13:00', '16:00-17:00'],
    'Specialist in cosmetic dermatology, acne treatment, and skin allergies.',
    '+91 98765 43215', 'dr.anjali@jaslok.com', true
),
(
    'Dr. Rahul Joshi',
    'General Physician',
    'MBBS, MD (Internal Medicine)',
    'Fortis Hospital Mulund',
    'https://randomuser.me/api/portraits/men/7.jpg',
    4.5, 520, 8, 800.00,
    true, true,
    ARRAY['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    ARRAY['09:00-10:00', '10:00-11:00', '11:00-12:00', '14:00-15:00', '15:00-16:00', '16:00-17:00'],
    'General physician with expertise in diabetes, hypertension, and preventive healthcare.',
    '+91 98765 43216', 'dr.rahul@fortis.com', true
),
(
    'Dr. Kavita Reddy',
    'Oncologist',
    'MBBS, MD (Medicine), DM (Medical Oncology)',
    'Nanavati Super Speciality Hospital',
    'https://randomuser.me/api/portraits/women/8.jpg',
    4.9, 270, 16, 2500.00,
    true, false,
    ARRAY['Monday', 'Wednesday', 'Friday'],
    ARRAY['10:00-11:00', '11:00-12:00', '14:00-15:00'],
    'Medical oncologist specializing in breast cancer and targeted therapy.',
    '+91 98765 43217', 'dr.kavita@nanavati.com', true
),
(
    'Dr. Suresh Nair',
    'Gastroenterologist',
    'MBBS, MD (Medicine), DM (Gastroenterology)',
    'Wockhardt Hospital Mumbai Central',
    'https://randomuser.me/api/portraits/men/9.jpg',
    4.7, 340, 13, 1600.00,
    true, true,
    ARRAY['Tuesday', 'Thursday', 'Saturday'],
    ARRAY['09:00-10:00', '10:00-11:00', '11:00-12:00', '15:00-16:00'],
    'Expert in endoscopy, liver diseases, and inflammatory bowel disease.',
    '+91 98765 43218', 'dr.suresh@wockhardt.com', true
),
(
    'Dr. Meera Iyer',
    'Psychiatrist',
    'MBBS, MD (Psychiatry)',
    'Holy Family Hospital',
    'https://randomuser.me/api/portraits/women/10.jpg',
    4.8, 290, 11, 1300.00,
    true, true,
    ARRAY['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    ARRAY['10:00-11:00', '11:00-12:00', '14:00-15:00', '15:00-16:00', '16:00-17:00'],
    'Specialist in anxiety disorders, depression, and cognitive behavioral therapy.',
    '+91 98765 43219', 'dr.meera@holyfamily.com', true
);

-- ============================================================
-- AMBULANCE DRIVERS SEED DATA
-- ============================================================

INSERT INTO public.ambulance_drivers (
    name, phone, vehicle_number, vehicle_type,
    latitude, longitude, is_available, is_active, rating, total_trips
) VALUES
('Ramesh Patil', '+91 98765 11111', 'MH-01-AB-1234', 'Advanced', 19.0760, 72.8777, true, true, 4.7, 450),
('Sunil Kumar', '+91 98765 22222', 'MH-02-CD-5678', 'ICU', 19.1197, 72.8346, true, true, 4.9, 380),
('Prakash Sharma', '+91 98765 33333', 'MH-03-EF-9012', 'Basic', 19.0521, 72.8224, true, true, 4.5, 520),
('Vijay Singh', '+91 98765 44444', 'MH-04-GH-3456', 'Advanced', 19.0387, 72.8408, true, true, 4.8, 410),
('Mahesh Yadav', '+91 98765 55555', 'MH-05-IJ-7890', 'ICU', 18.9697, 72.8053, true, true, 4.9, 360),
('Rajesh Gupta', '+91 98765 66666', 'MH-06-KL-2345', 'Basic', 19.1722, 72.9561, true, true, 4.6, 490),
('Anil Verma', '+91 98765 77777', 'MH-07-MN-6789', 'Advanced', 19.1076, 72.8339, true, true, 4.7, 430),
('Deepak Joshi', '+91 98765 88888', 'MH-08-OP-0123', 'ICU', 18.9750, 72.8258, true, true, 4.8, 390),
('Santosh More', '+91 98765 99999', 'MH-09-QR-4567', 'Basic', 19.0596, 72.8295, true, true, 4.5, 510),
('Ganesh Pawar', '+91 98765 00000', 'MH-10-ST-8901', 'Advanced', 19.0176, 73.0322, true, true, 4.7, 440);

-- ============================================================
-- EMERGENCY CONTACTS SEED DATA
-- ============================================================

INSERT INTO public.emergency_contacts (
    name, category, phone, alternate_phone, description, is_active, display_order
) VALUES
('National Emergency Number', 'emergency', '112', NULL, 'Single emergency number for all services', true, 1),
('Ambulance Service', 'ambulance', '102', '108', 'Emergency ambulance service', true, 2),
('Police Emergency', 'police', '100', NULL, 'Police emergency helpline', true, 3),
('Fire Brigade', 'fire', '101', NULL, 'Fire emergency service', true, 4),
('Women Helpline', 'helpline', '1091', NULL, '24x7 women in distress helpline', true, 5),
('Child Helpline', 'helpline', '1098', NULL, 'Child protection helpline', true, 6),
('Disaster Management', 'emergency', '108', NULL, 'National disaster management helpline', true, 7),
('Blood Bank', 'hospital', '104', NULL, 'Blood bank helpline', true, 8),
('Mental Health Helpline', 'helpline', '9152987821', NULL, 'Mental health support', true, 9),
('Senior Citizen Helpline', 'helpline', '14567', NULL, 'Helpline for senior citizens', true, 10);

-- ============================================================
-- FIRST AID GUIDES SEED DATA
-- ============================================================

INSERT INTO public.first_aid_guides (
    title, category, description, steps, warnings, is_active, display_order
) VALUES
(
    'Heart Attack',
    'Cardiac Emergency',
    'Immediate steps to take when someone is having a heart attack',
    '[
        {"step": 1, "title": "Call Emergency", "description": "Call 102 or 112 immediately"},
        {"step": 2, "title": "Keep Person Calm", "description": "Help them sit down and stay calm"},
        {"step": 3, "title": "Give Aspirin", "description": "If available and not allergic, give 300mg aspirin to chew"},
        {"step": 4, "title": "Loosen Clothing", "description": "Loosen any tight clothing around neck and chest"},
        {"step": 5, "title": "Monitor", "description": "Monitor breathing and pulse until help arrives"}
    ]'::jsonb,
    ARRAY['Do not leave the person alone', 'Do not give food or water', 'Be prepared to perform CPR if needed'],
    true, 1
),
(
    'Choking',
    'Breathing Emergency',
    'How to help someone who is choking',
    '[
        {"step": 1, "title": "Assess Situation", "description": "Check if person can cough or speak"},
        {"step": 2, "title": "Encourage Coughing", "description": "If they can cough, encourage them to continue"},
        {"step": 3, "title": "Back Blows", "description": "Give 5 sharp back blows between shoulder blades"},
        {"step": 4, "title": "Abdominal Thrusts", "description": "Perform 5 abdominal thrusts (Heimlich maneuver)"},
        {"step": 5, "title": "Repeat", "description": "Alternate between back blows and abdominal thrusts"},
        {"step": 6, "title": "Call Emergency", "description": "If obstruction does not clear, call 102"}
    ]'::jsonb,
    ARRAY['Do not perform abdominal thrusts on infants', 'Do not give water while choking'],
    true, 2
),
(
    'Severe Bleeding',
    'Injury',
    'How to control severe bleeding',
    '[
        {"step": 1, "title": "Apply Pressure", "description": "Apply direct pressure to wound with clean cloth"},
        {"step": 2, "title": "Elevate", "description": "Raise injured area above heart level if possible"},
        {"step": 3, "title": "Maintain Pressure", "description": "Keep pressure for at least 10 minutes"},
        {"step": 4, "title": "Bandage", "description": "Apply bandage firmly but not too tight"},
        {"step": 5, "title": "Call Emergency", "description": "Call 102 if bleeding does not stop"}
    ]'::jsonb,
    ARRAY['Do not remove embedded objects', 'Do not apply tourniquet unless absolutely necessary'],
    true, 3
),
(
    'Burns',
    'Injury',
    'First aid for burns',
    '[
        {"step": 1, "title": "Cool the Burn", "description": "Run cool (not cold) water over burn for 10-20 minutes"},
        {"step": 2, "title": "Remove Items", "description": "Remove jewelry and tight clothing before swelling"},
        {"step": 3, "title": "Cover", "description": "Cover with sterile, non-stick bandage"},
        {"step": 4, "title": "Pain Relief", "description": "Give over-the-counter pain reliever if needed"},
        {"step": 5, "title": "Seek Help", "description": "Seek medical help for severe burns"}
    ]'::jsonb,
    ARRAY['Do not apply ice directly', 'Do not break blisters', 'Do not apply butter or oil'],
    true, 4
),
(
    'Fracture',
    'Injury',
    'How to handle suspected fractures',
    '[
        {"step": 1, "title": "Do Not Move", "description": "Keep the injured area still"},
        {"step": 2, "title": "Immobilize", "description": "Splint the area using rigid material"},
        {"step": 3, "title": "Ice Pack", "description": "Apply ice pack to reduce swelling"},
        {"step": 4, "title": "Elevate", "description": "Elevate injured area if possible"},
        {"step": 5, "title": "Call Emergency", "description": "Call 102 for serious fractures"}
    ]'::jsonb,
    ARRAY['Do not try to realign the bone', 'Do not move the person if spine injury is suspected'],
    true, 5
);

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Check hospitals count
SELECT COUNT(*) as hospital_count FROM public.hospitals;

-- Check doctors count
SELECT COUNT(*) as doctor_count FROM public.doctors;

-- Check ambulance drivers count
SELECT COUNT(*) as ambulance_count FROM public.ambulance_drivers;

-- Check emergency contacts count
SELECT COUNT(*) as emergency_contacts_count FROM public.emergency_contacts;

-- Check first aid guides count
SELECT COUNT(*) as first_aid_count FROM public.first_aid_guides;

-- Test nearby hospitals function (Mumbai coordinates)
SELECT * FROM get_nearby_hospitals(19.0760, 72.8777, 5.0);

-- Test nearby ambulances function
SELECT * FROM get_nearby_ambulances(19.0760, 72.8777, 10.0);
