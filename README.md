# MamaApp - AI-Driven Maternal Health Solution

An integrated digital health platform to combat maternal mortality and teen pregnancy in Africa through tracking young girls along the health continuum, from reproductive health education to safe delivery.

## Project Architecture

```
MamaApp/
├── backend/              # Node.js/Express - SMS/USSD & Referral System
├── ai-engine/            # Python/FastAPI - Risk Scoring Engine (XGBoost + SHAP)
├── mobile/               # Flutter - Maternal Monitoring App (Offline-first + BLE)
├── dashboard/            # React - Ministry Health Dashboard
├── database/             # PostgreSQL schemas & migrations (with TimescaleDB)
└── docker-compose.yml    # Container orchestration
```

## Five Integrated Layers

### 1. Prevention Layer (SMS/USSD)
- Anonymous SRH education via SMS and USSD
- No smartphone required - works on feature phones
- Multi-language support (English, Swahili, Luganda, etc.)
- Weekly educational drip campaigns
- Integration with Africa's Talking API

### 2. Early Detection Layer (AI Scoring)
- XGBoost-based risk scoring engine
- SHAP explanations for clinician trust and transparency
- Handles missing data gracefully (median imputation)
- Hard override rules for critical danger signs
- RESTful API for scoring requests

### 3. Maternal Monitoring Kit
- Offline-first Flutter app with Riverpod state management
- BLE device integration (BP cuff, pulse oximeter, thermometer)
- Drift (SQLite) local storage with outbox sync pattern
- Real-time danger sign detection and alerts
- Auto-syncs when connectivity restored

### 4. Referral & Emergency System
- Automated notification chain (push → SMS → voice call)
- Escalation if no response within configurable timeout
- Full tracking from detection to delivery outcome
- Offline-capable with sync on reconnect
- Red/amber/green urgency levels

### 5. Ministry Dashboard
- Real-time metrics and trends visualization
- Geographic mapping with Leaflet (risk hotspots, facility locations)
- Regional breakdown and comparison analytics
- Role-based access control (National, Regional, Facility)
- Advanced drill-down analytics

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Clone and configure
cp .env.example .env
# Edit .env with your credentials

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f
```

Services will be available at:
- **Backend API**: http://localhost:4000
- **AI Engine**: http://localhost:8000
- **Dashboard**: http://localhost:3000
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

### Option 2: Manual Setup

#### Prerequisites
- Node.js 18+
- Python 3.11+
- Flutter 3.16+
- PostgreSQL 15+ with TimescaleDB extension
- Redis 7+

#### Installation

```bash
# Database setup
psql -U postgres -f database/schema.sql
psql -U postgres -f database/migrations/002_device_registry.sql

# Backend
cd backend
npm install
cp .env.example .env  # Configure database URL, etc.
npm run dev

# AI Engine
cd ai-engine
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn main:app --reload

# Mobile App
cd mobile
flutter pub get
flutter run

# Dashboard
cd dashboard
npm install
npm run dev
```

## API Endpoints

### USSD/SMS (Backend)
- `POST /api/ussd` - USSD gateway callback
- `POST /api/sms/incoming` - Incoming SMS webhook
- `POST /api/sms/campaigns` - Create SMS campaign

### Patients & Monitoring
- `GET /api/patients` - List patients (with filters)
- `POST /api/patients` - Register new patient
- `POST /api/patients/:id/vitals` - Record vital signs

### Referrals
- `GET /api/referrals` - List referrals
- `POST /api/referrals` - Create referral
- `PATCH /api/referrals/:id/status` - Update status

### AI Scoring
- `POST /ai/score` - Get risk score for patient data
- `GET /ai/model-info` - Model metadata

### Dashboard
- `GET /api/dashboard/overview` - KPI summary
- `GET /api/dashboard/analytics` - Detailed analytics
- `GET /api/dashboard/map-data` - Geographic data

## Device Binding

Monitoring devices (BP cuff, pulse oximeter) are bound to patients:

```bash
# Register device
POST /api/devices/register
{ "deviceHardwareId": "BPCUFF-001", "model": "iHealth BP7" }

# Assign to patient
POST /api/devices/:id/assign
{ "patientId": "uuid-here" }

# Auto-lookup patient by device
GET /api/devices/lookup/BPCUFF-001
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string |
| `JWT_SECRET` | JWT signing secret (min 32 chars) |
| `AFRICAS_TALKING_API_KEY` | Africa's Talking API key |
| `AFRICAS_TALKING_USERNAME` | Africa's Talking username |
| `FIREBASE_PROJECT_ID` | Firebase project for push notifications |
| `AI_ENGINE_URL` | URL of AI scoring service |

## Mobile App Features

- **Offline-First**: All data stored locally, syncs when online
- **BLE Support**: Connects to Bluetooth medical devices
- **Danger Detection**: Real-time vital sign analysis
- **Session Tracking**: Complete monitoring sessions with symptoms
- **Referral Creation**: Create and track referrals offline

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `npm test` / `flutter test`
5. Submit a pull request

## License

MIT License - See LICENSE file
