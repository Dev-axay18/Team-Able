-- ============================================================
-- JEEVANPATH - COMPLETE SUPABASE DATABASE SCHEMA
-- Medical Services Platform
-- Version: 1.0
-- Compatible with Flutter App Models
-- ============================================================

-- ============================================================
-- SECTION 1: ENABLE EXTENSIONS
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable PostGIS for location-based queries (optional but recommended)
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================
-- SECTION 2: CREATE TABLES
-- ============================================================

-- ------------------------------------------------------------
-- USERS TABLE
-- Stores user profile and medical information
-- Linked to Supabase Auth
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    profile_image TEXT,
    blood_group VARCHAR(10),
    age INTEGER,
    gender VARCHAR(20),
    allergies TEXT[], -- Array of allergies
    conditions TEXT[], -- Array of medical conditions
    emergency_contact VARCHAR(255),
    emergency_phone VARCHAR(20),
    address TEXT,
    c_pin VARCHAR(4), -- 4-digit emergency PIN
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- HOSPITALS TABLE
-- Stores hospital information with location data
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.hospitals (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    location GEOGRAPHY(POINT, 4326), -- PostGIS point for efficient spatial queries
    phone VARCHAR(20),
    emergency_phone VARCHAR(20),
    email VARCHAR(100),
    facilities TEXT,
    has_emergency BOOLEAN DEFAULT false,
    has_ambulance BOOLEAN DEFAULT false,
    has_icu BOOLEAN DEFAULT false,
    bed_count INTEGER DEFAULT 0,
    
    -- Bed categories for detailed tracking
    general_ward_beds INTEGER DEFAULT 0,
    private_room_beds INTEGER DEFAULT 0,
    icu_beds INTEGER DEFAULT 0,
    pediatric_beds INTEGER DEFAULT 0,
    maternity_beds INTEGER DEFAULT 0,
    isolation_beds INTEGER DEFAULT 0,
    burn_unit_beds INTEGER DEFAULT 0,
    
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    type VARCHAR(50), -- Multi-specialty, General, Specialty, etc.
    image_url TEXT,
    available_24x7 BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- DOCTORS TABLE
-- Stores doctor profiles and availability
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    qualification VARCHAR(255) NOT NULL,
    hospital_id BIGINT REFERENCES public.hospitals(id) ON DELETE SET NULL,
    hospital_name VARCHAR(255),
    profile_image TEXT,
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    experience_years INTEGER DEFAULT 0,
    consultation_fee DECIMAL(10,2) DEFAULT 0.0,
    is_available BOOLEAN DEFAULT true,
    is_online BOOLEAN DEFAULT false,
    available_days TEXT[], -- Array of days: ['Monday', 'Tuesday', ...]
    available_slots TEXT[], -- Array of time slots: ['09:00-10:00', '10:00-11:00', ...]
    about TEXT,
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    phone VARCHAR(20),
    email VARCHAR(100),
    license_number VARCHAR(50),
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- APPOINTMENTS TABLE
-- Stores appointment bookings
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.doctors(id) ON DELETE CASCADE,
    doctor_name VARCHAR(255) NOT NULL,
    doctor_specialization VARCHAR(100) NOT NULL,
    doctor_image TEXT,
    appointment_date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- pending, confirmed, completed, cancelled
    type VARCHAR(20) DEFAULT 'inPerson', -- inPerson, online
    notes TEXT,
    fee DECIMAL(10,2) NOT NULL,
    meeting_link TEXT,
    prescription TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- AMBULANCE_DRIVERS TABLE
-- Stores ambulance driver information and real-time location
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ambulance_drivers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    vehicle_number VARCHAR(50) NOT NULL UNIQUE,
    vehicle_type VARCHAR(50), -- Basic, Advanced, ICU
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    location GEOGRAPHY(POINT, 4326),
    is_available BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    rating DECIMAL(3,2) DEFAULT 0.0,
    total_trips INTEGER DEFAULT 0,
    hospital_id BIGINT REFERENCES public.hospitals(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- AMBULANCE_REQUESTS TABLE
-- Stores ambulance booking requests with severity levels
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ambulance_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES public.ambulance_drivers(id) ON DELETE SET NULL,
    pickup_latitude DOUBLE PRECISION NOT NULL,
    pickup_longitude DOUBLE PRECISION NOT NULL,
    pickup_address TEXT,
    destination_latitude DOUBLE PRECISION,
    destination_longitude DOUBLE PRECISION,
    destination_address TEXT,
    severity_level VARCHAR(20) NOT NULL, -- critical, severe, moderate, minor
    priority INTEGER NOT NULL, -- 1 (highest) to 4 (lowest)
    status VARCHAR(20) DEFAULT 'pending', -- pending, assigned, enroute, arrived, completed, cancelled
    notes TEXT,
    estimated_arrival_time TIMESTAMP WITH TIME ZONE,
    actual_arrival_time TIMESTAMP WITH TIME ZONE,
    completion_time TIMESTAMP WITH TIME ZONE,
    fare DECIMAL(10,2),
    rating DECIMAL(3,2),
    feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- SOS_SESSIONS TABLE
-- Stores emergency SOS session data with C-PIN verification
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sos_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT,
    is_active BOOLEAN DEFAULT true,
    severity_level VARCHAR(20), -- critical, severe, moderate, minor
    emergency_type VARCHAR(50), -- ambulance, police, fire, medical
    notes TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- EMERGENCY_CONTACTS TABLE
-- Stores emergency contact numbers (hospitals, police, etc.)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.emergency_contacts (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL, -- hospital, police, fire, ambulance, helpline
    phone VARCHAR(20) NOT NULL,
    alternate_phone VARCHAR(20),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- MEDICAL_RECORDS TABLE
-- Stores user medical records and documents
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.medical_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    record_type VARCHAR(50) NOT NULL, -- prescription, lab_report, scan, vaccination, etc.
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_url TEXT,
    file_type VARCHAR(50), -- pdf, image, etc.
    doctor_id UUID REFERENCES public.doctors(id) ON DELETE SET NULL,
    doctor_name VARCHAR(255),
    hospital_name VARCHAR(255),
    record_date DATE,
    tags TEXT[],
    is_shared BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- PRESCRIPTIONS TABLE
-- Stores prescription details
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.prescriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID REFERENCES public.appointments(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.doctors(id) ON DELETE CASCADE,
    diagnosis TEXT,
    medications JSONB, -- Array of medication objects
    instructions TEXT,
    follow_up_date DATE,
    file_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- REVIEWS TABLE
-- Stores reviews for doctors and hospitals
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.doctors(id) ON DELETE CASCADE,
    hospital_id BIGINT REFERENCES public.hospitals(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_review_target CHECK (
        (doctor_id IS NOT NULL AND hospital_id IS NULL) OR
        (doctor_id IS NULL AND hospital_id IS NOT NULL)
    )
);

-- ------------------------------------------------------------
-- NOTIFICATIONS TABLE
-- Stores user notifications
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- appointment, ambulance, emergency, general
    reference_id UUID, -- ID of related entity (appointment, ambulance request, etc.)
    is_read BOOLEAN DEFAULT false,
    action_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- FIRST_AID_GUIDES TABLE
-- Stores first aid instructions
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.first_aid_guides (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    steps JSONB NOT NULL, -- Array of step objects
    warnings TEXT[],
    image_url TEXT,
    video_url TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- SECTION 3: CREATE INDEXES FOR PERFORMANCE
-- ============================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_auth_id ON public.users(auth_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);

-- Hospitals indexes
CREATE INDEX IF NOT EXISTS idx_hospitals_location ON public.hospitals USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_hospitals_lat_lon ON public.hospitals(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_hospitals_type ON public.hospitals(type);
CREATE INDEX IF NOT EXISTS idx_hospitals_active ON public.hospitals(is_active);

-- Doctors indexes
CREATE INDEX IF NOT EXISTS idx_doctors_hospital_id ON public.doctors(hospital_id);
CREATE INDEX IF NOT EXISTS idx_doctors_specialization ON public.doctors(specialization);
CREATE INDEX IF NOT EXISTS idx_doctors_available ON public.doctors(is_available);
CREATE INDEX IF NOT EXISTS idx_doctors_rating ON public.doctors(rating DESC);

-- Appointments indexes
CREATE INDEX IF NOT EXISTS idx_appointments_user_id ON public.appointments(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor_id ON public.appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date_time ON public.appointments(appointment_date_time);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON public.appointments(status);

-- Ambulance drivers indexes
CREATE INDEX IF NOT EXISTS idx_ambulance_drivers_location ON public.ambulance_drivers USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_ambulance_drivers_available ON public.ambulance_drivers(is_available);

-- Ambulance requests indexes
CREATE INDEX IF NOT EXISTS idx_ambulance_requests_user_id ON public.ambulance_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_ambulance_requests_driver_id ON public.ambulance_requests(driver_id);
CREATE INDEX IF NOT EXISTS idx_ambulance_requests_status ON public.ambulance_requests(status);
CREATE INDEX IF NOT EXISTS idx_ambulance_requests_severity ON public.ambulance_requests(severity_level, priority);

-- SOS sessions indexes
CREATE INDEX IF NOT EXISTS idx_sos_sessions_user_id ON public.sos_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sos_sessions_active ON public.sos_sessions(is_active);
CREATE INDEX IF NOT EXISTS idx_sos_sessions_token ON public.sos_sessions(session_token);

-- Medical records indexes
CREATE INDEX IF NOT EXISTS idx_medical_records_user_id ON public.medical_records(user_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_type ON public.medical_records(record_type);
CREATE INDEX IF NOT EXISTS idx_medical_records_date ON public.medical_records(record_date DESC);

-- Prescriptions indexes
CREATE INDEX IF NOT EXISTS idx_prescriptions_user_id ON public.prescriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_appointment_id ON public.prescriptions(appointment_id);

-- Reviews indexes
CREATE INDEX IF NOT EXISTS idx_reviews_doctor_id ON public.reviews(doctor_id);
CREATE INDEX IF NOT EXISTS idx_reviews_hospital_id ON public.reviews(hospital_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON public.reviews(user_id);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON public.notifications(created_at DESC);

-- ============================================================
-- SECTION 4: CREATE FUNCTIONS
-- ============================================================

-- ------------------------------------------------------------
-- Function to update updated_at timestamp
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ------------------------------------------------------------
-- Function to sync location geography from lat/lon
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION sync_location_geography()
RETURNS TRIGGER AS $$
BEGIN
    NEW.location = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ------------------------------------------------------------
-- Function to find nearby hospitals (Haversine formula)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_nearby_hospitals(
    user_lat DOUBLE PRECISION,
    user_lon DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 5.0
)
RETURNS TABLE (
    id BIGINT,
    name VARCHAR,
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    phone VARCHAR,
    emergency_phone VARCHAR,
    email VARCHAR,
    facilities TEXT,
    has_emergency BOOLEAN,
    has_ambulance BOOLEAN,
    has_icu BOOLEAN,
    bed_count INTEGER,
    rating DECIMAL,
    type VARCHAR,
    image_url TEXT,
    available_24x7 BOOLEAN,
    distance_km DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.id,
        h.name,
        h.address,
        h.latitude,
        h.longitude,
        h.phone,
        h.emergency_phone,
        h.email,
        h.facilities,
        h.has_emergency,
        h.has_ambulance,
        h.has_icu,
        h.bed_count,
        h.rating,
        h.type,
        h.image_url,
        h.available_24x7,
        (
            6371 * acos(
                cos(radians(user_lat)) * 
                cos(radians(h.latitude)) * 
                cos(radians(h.longitude) - radians(user_lon)) + 
                sin(radians(user_lat)) * 
                sin(radians(h.latitude))
            )
        ) AS distance_km
    FROM public.hospitals h
    WHERE h.is_active = true
    AND (
        6371 * acos(
            cos(radians(user_lat)) * 
            cos(radians(h.latitude)) * 
            cos(radians(h.longitude) - radians(user_lon)) + 
            sin(radians(user_lat)) * 
            sin(radians(h.latitude))
        )
    ) <= radius_km
    ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql;

-- ------------------------------------------------------------
-- Function to find nearby available ambulances
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_nearby_ambulances(
    user_lat DOUBLE PRECISION,
    user_lon DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 10.0
)
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    phone VARCHAR,
    vehicle_number VARCHAR,
    vehicle_type VARCHAR,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    rating DECIMAL,
    distance_km DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.phone,
        a.vehicle_number,
        a.vehicle_type,
        a.latitude,
        a.longitude,
        a.rating,
        (
            6371 * acos(
                cos(radians(user_lat)) * 
                cos(radians(a.latitude)) * 
                cos(radians(a.longitude) - radians(user_lon)) + 
                sin(radians(user_lat)) * 
                sin(radians(a.latitude))
            )
        ) AS distance_km
    FROM public.ambulance_drivers a
    WHERE a.is_available = true
    AND a.is_active = true
    AND (
        6371 * acos(
            cos(radians(user_lat)) * 
            cos(radians(a.latitude)) * 
            cos(radians(a.longitude) - radians(user_lon)) + 
            sin(radians(user_lat)) * 
            sin(radians(a.latitude))
        )
    ) <= radius_km
    ORDER BY distance_km ASC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SECTION 5: CREATE TRIGGERS
-- ============================================================

-- Updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_hospitals_updated_at BEFORE UPDATE ON public.hospitals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_doctors_updated_at BEFORE UPDATE ON public.doctors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON public.appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ambulance_drivers_updated_at BEFORE UPDATE ON public.ambulance_drivers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ambulance_requests_updated_at BEFORE UPDATE ON public.ambulance_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sos_sessions_updated_at BEFORE UPDATE ON public.sos_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medical_records_updated_at BEFORE UPDATE ON public.medical_records
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prescriptions_updated_at BEFORE UPDATE ON public.prescriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_first_aid_guides_updated_at BEFORE UPDATE ON public.first_aid_guides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Location sync triggers
CREATE TRIGGER sync_hospital_location BEFORE INSERT OR UPDATE ON public.hospitals
    FOR EACH ROW EXECUTE FUNCTION sync_location_geography();

CREATE TRIGGER sync_ambulance_location BEFORE INSERT OR UPDATE ON public.ambulance_drivers
    FOR EACH ROW EXECUTE FUNCTION sync_location_geography();

-- ============================================================
-- SECTION 6: ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ambulance_drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ambulance_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sos_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.first_aid_guides ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = auth_id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = auth_id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = auth_id);

-- Hospitals policies (public read)
CREATE POLICY "Anyone can view active hospitals" ON public.hospitals
    FOR SELECT USING (is_active = true);

CREATE POLICY "Authenticated users can update hospitals" ON public.hospitals
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Doctors policies (public read)
CREATE POLICY "Anyone can view available doctors" ON public.doctors
    FOR SELECT USING (is_available = true);

CREATE POLICY "Authenticated users can update doctors" ON public.doctors
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Appointments policies
CREATE POLICY "Users can view own appointments" ON public.appointments
    FOR SELECT USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

CREATE POLICY "Users can create own appointments" ON public.appointments
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

CREATE POLICY "Users can update own appointments" ON public.appointments
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

-- Ambulance drivers policies (public read for available)
CREATE POLICY "Anyone can view available ambulances" ON public.ambulance_drivers
    FOR SELECT USING (is_available = true AND is_active = true);

CREATE POLICY "Authenticated users can update ambulances" ON public.ambulance_drivers
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Ambulance requests policies
CREATE POLICY "Users can view own ambulance requests" ON public.ambulance_requests
    FOR SELECT USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

CREATE POLICY "Users can create ambulance requests" ON public.ambulance_requests
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

CREATE POLICY "Users can update own ambulance requests" ON public.ambulance_requests
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

-- SOS sessions policies
CREATE POLICY "Users can view own SOS sessions" ON public.sos_sessions
    FOR SELECT USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

CREATE POLICY "Users can create SOS sessions" ON public.sos_sessions
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

-- Emergency contacts policies (public read)
CREATE POLICY "Anyone can view active emergency contacts" ON public.emergency_contacts
    FOR SELECT USING (is_active = true);

-- Medical records policies
CREATE POLICY "Users can view own medical records" ON public.medical_records
    FOR SELECT USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

CREATE POLICY "Users can create own medical records" ON public.medical_records
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

CREATE POLICY "Users can update own medical records" ON public.medical_records
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

-- Prescriptions policies
CREATE POLICY "Users can view own prescriptions" ON public.prescriptions
    FOR SELECT USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

-- Reviews policies
CREATE POLICY "Anyone can view verified reviews" ON public.reviews
    FOR SELECT USING (is_verified = true);

CREATE POLICY "Users can create reviews" ON public.reviews
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT auth_id FROM public.users WHERE id = user_id
        )
    );

-- First aid guides policies (public read)
CREATE POLICY "Anyone can view active first aid guides" ON public.first_aid_guides
    FOR SELECT USING (is_active = true);

-- ============================================================
-- SECTION 7: SEED DATA
-- ============================================================
