"""
MamaApp AI Scoring Engine

XGBoost-based maternal risk scoring with SHAP explanations.
Handles missing data gracefully and provides interpretable results.
"""

import os
import numpy as np
from typing import Optional
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import xgboost as xgb
import shap

# Settings - simplified to avoid pydantic_settings dependency
class Settings:
    host: str = os.getenv("HOST", "0.0.0.0")
    port: int = int(os.getenv("PORT", "8000"))
    debug: bool = os.getenv("DEBUG", "false").lower() == "true"
    model_path: str = os.getenv("MODEL_PATH", "./models/maternal_risk_model.joblib")
    explainer_path: str = os.getenv("EXPLAINER_PATH", "./models/maternal_risk_explainer.joblib")
    model_version: str = os.getenv("MODEL_VERSION", "v1.0.0")

settings = Settings()

# Feature definitions
FEATURES = [
    'age', 'gravida', 'parity', 'gestational_weeks', 'anc_visits',
    'systolic_bp', 'diastolic_bp', 'heart_rate', 'temperature', 'spo2',
    'fundal_height', 'facility_distance_km',
    'prior_stillbirth', 'prior_csection', 'prior_preeclampsia',
    'multiple_pregnancy', 'hiv_positive', 'diabetes', 'anaemia',
    'severe_headache', 'vaginal_bleeding', 'reduced_fetal_movement',
    'oedema_face_hands', 'pallor'
]

# Human-readable feature names for explanations
FEATURE_NAMES = {
    'age': 'Patient age',
    'gravida': 'Number of pregnancies',
    'parity': 'Previous births',
    'gestational_weeks': 'Gestational weeks',
    'anc_visits': 'Antenatal care visits',
    'systolic_bp': 'Systolic blood pressure',
    'diastolic_bp': 'Diastolic blood pressure',
    'heart_rate': 'Heart rate',
    'temperature': 'Body temperature',
    'spo2': 'Oxygen saturation (SpO2)',
    'fundal_height': 'Fundal height',
    'facility_distance_km': 'Distance to facility',
    'prior_stillbirth': 'History of stillbirth',
    'prior_csection': 'Previous C-section',
    'prior_preeclampsia': 'History of pre-eclampsia',
    'multiple_pregnancy': 'Multiple pregnancy (twins+)',
    'hiv_positive': 'HIV positive',
    'diabetes': 'Diabetes',
    'anaemia': 'Anaemia',
    'severe_headache': 'Severe headache',
    'vaginal_bleeding': 'Vaginal bleeding',
    'reduced_fetal_movement': 'Reduced fetal movement',
    'oedema_face_hands': 'Swelling (face/hands)',
    'pallor': 'Pallor (pale appearance)',
}

# Global model instances
model: Optional[xgb.XGBClassifier] = None
explainer: Optional[shap.TreeExplainer] = None


# Request/Response models
class PatientRecord(BaseModel):
    """Input features for risk scoring"""
    # Demographics
    age: Optional[float] = Field(None, ge=10, le=60)
    gravida: Optional[int] = Field(None, ge=0)
    parity: Optional[int] = Field(None, ge=0)
    gestational_weeks: Optional[float] = Field(None, ge=1, le=45)
    anc_visits: Optional[int] = Field(None, ge=0)
    
    # Vitals
    systolic_bp: Optional[float] = Field(None, ge=60, le=250)
    diastolic_bp: Optional[float] = Field(None, ge=30, le=180)
    heart_rate: Optional[float] = Field(None, ge=30, le=200)
    temperature: Optional[float] = Field(None, ge=34, le=42)
    spo2: Optional[float] = Field(None, ge=50, le=100)
    fetal_hr: Optional[float] = Field(None, ge=50, le=220)
    fundal_height: Optional[float] = Field(None, ge=5, le=50)
    
    # Context
    facility_distance_km: Optional[float] = Field(None, ge=0)
    
    # Medical history (booleans)
    prior_stillbirth: bool = False
    prior_csection: bool = False
    prior_preeclampsia: bool = False
    multiple_pregnancy: bool = False
    hiv_positive: bool = False
    diabetes: bool = False
    anaemia: bool = False
    
    # Current symptoms (booleans)
    severe_headache: bool = False
    vaginal_bleeding: bool = False
    reduced_fetal_movement: bool = False
    oedema_face_hands: bool = False
    pallor: bool = False


class RiskFactor(BaseModel):
    """Individual factor contributing to risk score"""
    factor: str
    direction: str  # 'increases risk' or 'reduces risk'
    impact: float


class RiskScoreResponse(BaseModel):
    """Risk scoring result with explanations"""
    risk_score: float = Field(..., ge=0, le=1)
    risk_tier: str  # 'low', 'medium', 'high'
    reasons: list[RiskFactor]
    missing_features: list[str]
    model_version: str
    hard_override: bool = False
    override_reason: Optional[str] = None


class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    model_loaded: bool
    model_version: str


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown logic"""
    global model, explainer
    
    # Try to load existing model
    if os.path.exists(settings.model_path):
        print(f"Loading model from {settings.model_path}")
        model = joblib.load(settings.model_path)
        
        if os.path.exists(settings.explainer_path):
            explainer = joblib.load(settings.explainer_path)
        else:
            explainer = shap.TreeExplainer(model)
            
        print(f"Model loaded: {settings.model_version}")
    else:
        print("No model found, using rule-based scoring only")
        model = None
        explainer = None
    
    yield
    
    # Cleanup
    print("AI Engine shutting down")


app = FastAPI(
    title="MamaApp AI Scoring Engine",
    description="Maternal risk scoring with explainable AI",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Check if the service is healthy and model is loaded"""
    return HealthResponse(
        status="healthy",
        model_loaded=model is not None,
        model_version=settings.model_version
    )


@app.post("/score", response_model=RiskScoreResponse)
async def score_patient(record: PatientRecord):
    """
    Calculate maternal risk score with SHAP explanations.
    
    Hard override rules trigger HIGH risk regardless of model score:
    - Systolic BP >= 160 or Diastolic BP >= 110
    - Active vaginal bleeding
    - SpO2 < 90%
    - Temperature >= 38.5°C with headache
    """
    
    # Check hard override rules first
    override, override_reason = check_hard_overrides(record)
    
    if override:
        return RiskScoreResponse(
            risk_score=0.95,
            risk_tier="high",
            reasons=[RiskFactor(
                factor=override_reason,
                direction="increases risk",
                impact=0.95
            )],
            missing_features=[],
            model_version=settings.model_version,
            hard_override=True,
            override_reason=override_reason
        )
    
    # Build feature vector
    feature_values, missing = build_feature_vector(record)
    
    # If model is not loaded, use rule-based scoring
    if model is None:
        return rule_based_scoring(record, missing)
    
    # Model prediction
    try:
        row = np.array([feature_values])
        prob = float(model.predict_proba(row)[0][1])
        
        # Get SHAP explanations
        shap_values = explainer.shap_values(row)[0]
        
        # Get top factors
        factors = []
        for feature, shap_val in sorted(
            zip(FEATURES, shap_values),
            key=lambda x: abs(x[1]),
            reverse=True
        )[:5]:
            if abs(shap_val) > 0.01:
                factors.append(RiskFactor(
                    factor=FEATURE_NAMES.get(feature, feature),
                    direction="increases risk" if shap_val > 0 else "reduces risk",
                    impact=round(abs(shap_val), 3)
                ))
        
        # Determine tier
        if prob >= 0.60:
            tier = "high"
        elif prob >= 0.25:
            tier = "medium"
        else:
            tier = "low"
        
        return RiskScoreResponse(
            risk_score=round(prob, 4),
            risk_tier=tier,
            reasons=factors,
            missing_features=missing,
            model_version=settings.model_version
        )
        
    except Exception as e:
        print(f"Model prediction error: {e}")
        return rule_based_scoring(record, missing)


def check_hard_overrides(record: PatientRecord) -> tuple[bool, str]:
    """
    Check for conditions that require immediate HIGH risk classification.
    These override any model predictions.
    """
    
    if record.vaginal_bleeding:
        return True, "Active vaginal bleeding"
    
    if record.systolic_bp is not None and record.systolic_bp >= 160:
        return True, f"Critically high systolic BP ({record.systolic_bp} mmHg)"
    
    if record.diastolic_bp is not None and record.diastolic_bp >= 110:
        return True, f"Critically high diastolic BP ({record.diastolic_bp} mmHg)"
    
    if record.spo2 is not None and record.spo2 < 90:
        return True, f"Dangerously low oxygen saturation ({record.spo2}%)"
    
    if record.temperature is not None and record.temperature >= 38.5 and record.severe_headache:
        return True, f"High fever ({record.temperature}°C) with severe headache"
    
    if record.reduced_fetal_movement and record.gestational_weeks and record.gestational_weeks >= 28:
        return True, "Reduced fetal movement in third trimester"
    
    return False, ""


def build_feature_vector(record: PatientRecord) -> tuple[list, list[str]]:
    """Build feature array for model input, tracking missing values"""
    
    values = []
    missing = []
    
    feature_map = {
        'age': record.age,
        'gravida': record.gravida,
        'parity': record.parity,
        'gestational_weeks': record.gestational_weeks,
        'anc_visits': record.anc_visits,
        'systolic_bp': record.systolic_bp,
        'diastolic_bp': record.diastolic_bp,
        'heart_rate': record.heart_rate,
        'temperature': record.temperature,
        'spo2': record.spo2,
        'fundal_height': record.fundal_height,
        'facility_distance_km': record.facility_distance_km,
        'prior_stillbirth': int(record.prior_stillbirth),
        'prior_csection': int(record.prior_csection),
        'prior_preeclampsia': int(record.prior_preeclampsia),
        'multiple_pregnancy': int(record.multiple_pregnancy),
        'hiv_positive': int(record.hiv_positive),
        'diabetes': int(record.diabetes),
        'anaemia': int(record.anaemia),
        'severe_headache': int(record.severe_headache),
        'vaginal_bleeding': int(record.vaginal_bleeding),
        'reduced_fetal_movement': int(record.reduced_fetal_movement),
        'oedema_face_hands': int(record.oedema_face_hands),
        'pallor': int(record.pallor),
    }
    
    for feature in FEATURES:
        val = feature_map.get(feature)
        if val is None:
            values.append(np.nan)
            missing.append(feature)
        else:
            values.append(float(val))
    
    return values, missing


def rule_based_scoring(record: PatientRecord, missing: list[str]) -> RiskScoreResponse:
    """
    Fallback rule-based scoring when ML model is unavailable.
    Based on WHO maternal risk guidelines.
    """
    
    score = 0.0
    factors = []
    
    # Blood pressure
    if record.systolic_bp is not None:
        if record.systolic_bp >= 140:
            score += 0.2
            factors.append(RiskFactor(
                factor="Elevated systolic BP",
                direction="increases risk",
                impact=0.2
            ))
    
    if record.diastolic_bp is not None:
        if record.diastolic_bp >= 90:
            score += 0.2
            factors.append(RiskFactor(
                factor="Elevated diastolic BP",
                direction="increases risk",
                impact=0.2
            ))
    
    # SpO2
    if record.spo2 is not None and record.spo2 < 95:
        score += 0.15
        factors.append(RiskFactor(
            factor="Low oxygen saturation",
            direction="increases risk",
            impact=0.15
        ))
    
    # Medical history
    if record.prior_preeclampsia:
        score += 0.25
        factors.append(RiskFactor(
            factor="History of pre-eclampsia",
            direction="increases risk",
            impact=0.25
        ))
    
    if record.prior_stillbirth:
        score += 0.15
        factors.append(RiskFactor(
            factor="History of stillbirth",
            direction="increases risk",
            impact=0.15
        ))
    
    # Current symptoms
    if record.severe_headache:
        score += 0.15
        factors.append(RiskFactor(
            factor="Severe headache",
            direction="increases risk",
            impact=0.15
        ))
    
    if record.oedema_face_hands:
        score += 0.15
        factors.append(RiskFactor(
            factor="Facial/hand swelling",
            direction="increases risk",
            impact=0.15
        ))
    
    if record.pallor:
        score += 0.1
        factors.append(RiskFactor(
            factor="Pallor (possible anaemia)",
            direction="increases risk",
            impact=0.1
        ))
    
    # Multiple pregnancy
    if record.multiple_pregnancy:
        score += 0.1
        factors.append(RiskFactor(
            factor="Multiple pregnancy",
            direction="increases risk",
            impact=0.1
        ))
    
    # Age factors
    if record.age is not None:
        if record.age < 18 or record.age > 35:
            score += 0.1
            factors.append(RiskFactor(
                factor="Age risk factor",
                direction="increases risk",
                impact=0.1
            ))
    
    # Cap score at 1.0
    score = min(score, 1.0)
    
    # Determine tier
    if score >= 0.6:
        tier = "high"
    elif score >= 0.25:
        tier = "medium"
    else:
        tier = "low"
    
    return RiskScoreResponse(
        risk_score=round(score, 4),
        risk_tier=tier,
        reasons=factors[:5],  # Top 5 factors
        missing_features=missing,
        model_version="rule-based-v1"
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug
    )
