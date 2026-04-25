# JeevanPath 🏥
### Fast. Reliable. Life-saving.

A full-fledged medical services app built with **Flutter** (frontend) and **Java Spring Boot** (backend).

---

## Features

### Flutter App
- **Splash Screen** — Animated brand intro
- **Onboarding** — 4-page feature walkthrough
- **Authentication** — Login & Register with form validation
- **Home Screen** — Greeting, services grid, upcoming appointment, top doctors
- **Doctor Search** — Filter by specialization, search by name/hospital
- **Doctor Detail** — Full profile, availability, consultation types
- **Book Appointment** — Date picker, time slots, in-person/video toggle
- **Appointments** — Upcoming & past tabs, cancel, join video call
- **Emergency** — SOS button, emergency numbers, nearby hospitals, first aid
- **Profile** — Health stats, medical info, emergency contact, settings

### Java Spring Boot Backend
- **JWT Authentication** — Secure token-based auth
- **Doctor API** — Search, filter, get by ID
- **Appointment API** — Book, cancel, list
- **User API** — Profile management
- **H2 in-memory DB** (dev) / MySQL (prod)
- **Data Seeder** — Pre-loaded demo data

---

## Getting Started

### Flutter App

```bash
cd jeevanpath
flutter pub get
flutter run
```

**Demo login:** any email + password (6+ chars)

### Java Backend

```bash
cd jeevanpath/backend
./mvnw spring-boot:run
```

API runs at: `http://localhost:8080`  
H2 Console: `http://localhost:8080/h2-console`

**Demo user:** `arjun@example.com` / `password123`

---

## API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/register` | ❌ | Register new user |
| POST | `/api/auth/login` | ❌ | Login |
| GET | `/api/doctors` | ❌ | List all doctors |
| GET | `/api/doctors?query=&specialization=` | ❌ | Search doctors |
| GET | `/api/doctors/{id}` | ❌ | Get doctor by ID |
| GET | `/api/doctors/top` | ❌ | Top rated doctors |
| GET | `/api/appointments` | ✅ | My appointments |
| POST | `/api/appointments` | ✅ | Book appointment |
| PATCH | `/api/appointments/{id}/cancel` | ✅ | Cancel appointment |

---

## Project Structure

```
jeevanpath/
├── lib/
│   ├── core/
│   │   ├── models/          # Data models
│   │   ├── providers/       # State management
│   │   └── theme/           # App theme & colors
│   └── features/
│       ├── splash/          # Splash screen
│       ├── onboarding/      # Onboarding flow
│       ├── auth/            # Login & Register
│       ├── home/            # Home + Navigation
│       ├── doctors/         # Doctor list & detail
│       ├── appointments/    # Booking & management
│       ├── emergency/       # Emergency services
│       └── profile/         # User profile
├── backend/
│   └── src/main/java/com/jeevanpath/
│       ├── model/           # JPA entities
│       ├── repository/      # Spring Data repos
│       ├── service/         # Business logic
│       ├── controller/      # REST controllers
│       ├── security/        # JWT auth
│       ├── dto/             # Request/Response DTOs
│       └── config/          # Security, seeder, exception handler
└── android/
    └── app/src/main/AndroidManifest.xml
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.x, Dart |
| State | Provider |
| UI | Material 3, Google Fonts |
| Backend | Java 17, Spring Boot 3.2 |
| Security | Spring Security + JWT |
| Database | H2 (dev), MySQL (prod) |
| ORM | Spring Data JPA / Hibernate |

---

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#1A6B4A` | Main brand green |
| Accent | `#FF6B35` | Emergency orange |
| Secondary | `#4ECDC4` | Teal highlights |
| Success | `#43A047` | Confirmed status |
| Error | `#E53935` | Alerts & cancel |
