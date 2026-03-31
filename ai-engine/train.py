"""
MamaApp AI Model Training Script

Trains an XGBoost classifier for maternal risk prediction.
Uses Optuna for hyperparameter optimization and PR-AUC for evaluation.
"""

import os
import numpy as np
import pandas as pd
from pathlib import Path

import xgboost as xgb
import shap
import optuna
import mlflow
import joblib
from sklearn.model_selection import StratifiedKFold, train_test_split, cross_val_score
from sklearn.metrics import (
    average_precision_score, 
    precision_recall_curve, 
    classification_report,
    confusion_matrix
)

# Feature definitions (same as main.py)
FEATURES = [
    'age', 'gravida', 'parity', 'gestational_weeks', 'anc_visits',
    'systolic_bp', 'diastolic_bp', 'heart_rate', 'temperature', 'spo2',
    'fundal_height', 'facility_distance_km',
    'prior_stillbirth', 'prior_csection', 'prior_preeclampsia',
    'multiple_pregnancy', 'hiv_positive', 'diabetes', 'anaemia',
    'severe_headache', 'vaginal_bleeding', 'reduced_fetal_movement',
    'oedema_face_hands', 'pallor'
]

TARGET = 'adverse_outcome'  # 1 = complication/death, 0 = safe delivery


def generate_synthetic_data(n_samples: int = 5000) -> pd.DataFrame:
    """
    Generate synthetic training data for initial model.
    
    In production, replace with:
    - WHO Global Health Observatory data
    - DHS (Demographic and Health Surveys) data
    - DHIS2 data from ministries of health
    - Your collected data from the app
    """
    
    np.random.seed(42)
    
    data = {
        # Demographics
        'age': np.random.normal(26, 6, n_samples).clip(14, 45),
        'gravida': np.random.poisson(2, n_samples).clip(1, 10),
        'parity': np.random.poisson(1, n_samples).clip(0, 8),
        'gestational_weeks': np.random.uniform(8, 40, n_samples),
        'anc_visits': np.random.poisson(3, n_samples).clip(0, 10),
        
        # Vitals - most are normal, some elevated
        'systolic_bp': np.where(
            np.random.random(n_samples) > 0.85,
            np.random.normal(150, 15, n_samples),  # Elevated
            np.random.normal(115, 10, n_samples)   # Normal
        ).clip(80, 200),
        
        'diastolic_bp': np.where(
            np.random.random(n_samples) > 0.85,
            np.random.normal(95, 10, n_samples),   # Elevated
            np.random.normal(75, 8, n_samples)     # Normal
        ).clip(50, 130),
        
        'heart_rate': np.random.normal(80, 12, n_samples).clip(50, 120),
        'temperature': np.where(
            np.random.random(n_samples) > 0.95,
            np.random.normal(38.5, 0.5, n_samples),  # Fever
            np.random.normal(36.8, 0.3, n_samples)   # Normal
        ).clip(35, 40),
        
        'spo2': np.where(
            np.random.random(n_samples) > 0.92,
            np.random.normal(92, 3, n_samples),  # Low
            np.random.normal(98, 1, n_samples)   # Normal
        ).clip(80, 100),
        
        'fundal_height': np.random.uniform(10, 40, n_samples),
        'facility_distance_km': np.random.exponential(15, n_samples).clip(0, 100),
        
        # Medical history (binary)
        'prior_stillbirth': np.random.binomial(1, 0.05, n_samples),
        'prior_csection': np.random.binomial(1, 0.15, n_samples),
        'prior_preeclampsia': np.random.binomial(1, 0.08, n_samples),
        'multiple_pregnancy': np.random.binomial(1, 0.03, n_samples),
        'hiv_positive': np.random.binomial(1, 0.04, n_samples),
        'diabetes': np.random.binomial(1, 0.06, n_samples),
        'anaemia': np.random.binomial(1, 0.25, n_samples),
        
        # Current symptoms (binary)
        'severe_headache': np.random.binomial(1, 0.08, n_samples),
        'vaginal_bleeding': np.random.binomial(1, 0.03, n_samples),
        'reduced_fetal_movement': np.random.binomial(1, 0.05, n_samples),
        'oedema_face_hands': np.random.binomial(1, 0.12, n_samples),
        'pallor': np.random.binomial(1, 0.15, n_samples),
    }
    
    df = pd.DataFrame(data)
    
    # Generate outcome based on risk factors (simplified model for synthetic data)
    risk_score = (
        0.3 * (df['systolic_bp'] >= 140).astype(int) +
        0.3 * (df['diastolic_bp'] >= 90).astype(int) +
        0.2 * df['prior_preeclampsia'] +
        0.15 * df['prior_stillbirth'] +
        0.25 * df['vaginal_bleeding'] +
        0.15 * df['severe_headache'] +
        0.1 * df['oedema_face_hands'] +
        0.15 * (df['spo2'] < 95).astype(int) +
        0.1 * df['anaemia'] +
        0.05 * ((df['age'] < 18) | (df['age'] > 35)).astype(int) +
        np.random.normal(0, 0.1, n_samples)  # noise
    )
    
    # Convert to probability and generate outcome
    prob = 1 / (1 + np.exp(-3 * (risk_score - 0.5)))
    df[TARGET] = (np.random.random(n_samples) < prob).astype(int)
    
    # Add some missing values (realistic scenario)
    for col in ['anc_visits', 'fundal_height', 'facility_distance_km']:
        mask = np.random.random(n_samples) < 0.1
        df.loc[mask, col] = np.nan
    
    print(f"Generated {n_samples} samples")
    print(f"Adverse outcomes: {df[TARGET].sum()} ({df[TARGET].mean()*100:.1f}%)")
    
    return df


def objective(trial, X_train, y_train):
    """Optuna objective function for hyperparameter optimization"""
    
    params = {
        'n_estimators': trial.suggest_int('n_estimators', 100, 500),
        'max_depth': trial.suggest_int('max_depth', 3, 8),
        'learning_rate': trial.suggest_float('learning_rate', 0.01, 0.2, log=True),
        'subsample': trial.suggest_float('subsample', 0.6, 1.0),
        'colsample_bytree': trial.suggest_float('colsample_bytree', 0.6, 1.0),
        'min_child_weight': trial.suggest_int('min_child_weight', 1, 10),
        'gamma': trial.suggest_float('gamma', 0, 1),
        'reg_alpha': trial.suggest_float('reg_alpha', 0, 1),
        'reg_lambda': trial.suggest_float('reg_lambda', 0, 2),
        
        # Fixed params
        'scale_pos_weight': (y_train == 0).sum() / (y_train == 1).sum(),
        'eval_metric': 'aucpr',
        'random_state': 42,
        'n_jobs': -1,
    }
    
    model = xgb.XGBClassifier(**params, use_label_encoder=False)
    
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    scores = cross_val_score(
        model, X_train, y_train, 
        cv=cv, 
        scoring='average_precision',
        n_jobs=-1
    )
    
    return scores.mean()


def find_optimal_threshold(y_true, y_proba, target_recall: float = 0.85):
    """
    Find threshold that achieves target recall.
    In clinical settings, we prefer high recall (catching true positives).
    """
    
    precision, recall, thresholds = precision_recall_curve(y_true, y_proba)
    
    # Find threshold closest to target recall
    idx = np.argmin(np.abs(recall[:-1] - target_recall))
    optimal_threshold = thresholds[idx]
    
    print(f"Optimal threshold for {target_recall:.0%} recall: {optimal_threshold:.3f}")
    print(f"Precision at this threshold: {precision[idx]:.3f}")
    
    return optimal_threshold


def train_model(
    df: pd.DataFrame,
    n_trials: int = 50,
    output_dir: str = "./models"
):
    """
    Train XGBoost model with Optuna hyperparameter optimization.
    """
    
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    X = df[FEATURES]
    y = df[TARGET]
    
    print(f"Training data: {X.shape[0]} samples, {X.shape[1]} features")
    print(f"Class distribution: {y.value_counts().to_dict()}")
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, stratify=y, random_state=42
    )
    
    # MLflow tracking
    mlflow.set_experiment("maternal_risk_scoring")
    
    with mlflow.start_run():
        # Hyperparameter optimization
        print("\nOptimizing hyperparameters...")
        study = optuna.create_study(direction='maximize')
        study.optimize(
            lambda t: objective(t, X_train, y_train),
            n_trials=n_trials,
            show_progress_bar=True
        )
        
        print(f"\nBest PR-AUC: {study.best_value:.4f}")
        print(f"Best params: {study.best_params}")
        
        # Train final model with best params
        best_params = {
            **study.best_params,
            'scale_pos_weight': (y_train == 0).sum() / (y_train == 1).sum(),
            'eval_metric': 'aucpr',
            'random_state': 42,
            'n_jobs': -1,
        }
        
        model = xgb.XGBClassifier(**best_params, use_label_encoder=False)
        model.fit(X_train, y_train)
        
        # Evaluate
        y_proba = model.predict_proba(X_test)[:, 1]
        pr_auc = average_precision_score(y_test, y_proba)
        
        print(f"\nTest PR-AUC: {pr_auc:.4f}")
        
        # Find optimal threshold
        threshold = find_optimal_threshold(y_test, y_proba, target_recall=0.85)
        y_pred = (y_proba >= threshold).astype(int)
        
        print("\nClassification Report:")
        print(classification_report(y_test, y_pred))
        
        print("\nConfusion Matrix:")
        print(confusion_matrix(y_test, y_pred))
        
        # Create SHAP explainer
        print("\nCreating SHAP explainer...")
        explainer = shap.TreeExplainer(model)
        
        # Log to MLflow
        mlflow.log_params(best_params)
        mlflow.log_metric("pr_auc", pr_auc)
        mlflow.log_metric("optimal_threshold", threshold)
        
        # Save model and explainer
        model_path = os.path.join(output_dir, "maternal_risk_model.joblib")
        explainer_path = os.path.join(output_dir, "maternal_risk_explainer.joblib")
        
        joblib.dump(model, model_path)
        joblib.dump(explainer, explainer_path)
        
        print(f"\nModel saved to {model_path}")
        print(f"Explainer saved to {explainer_path}")
        
        # Log artifacts to MLflow
        mlflow.log_artifact(model_path)
        mlflow.log_artifact(explainer_path)
        
        # Feature importance plot
        print("\nFeature Importance (Gain):")
        importance = dict(zip(FEATURES, model.feature_importances_))
        for feat, imp in sorted(importance.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {feat}: {imp:.4f}")
        
        return model, explainer


def evaluate_model(
    model: xgb.XGBClassifier,
    X_test: pd.DataFrame,
    y_test: pd.Series
) -> dict:
    """
    Comprehensive model evaluation with clinical metrics.
    """
    
    y_proba = model.predict_proba(X_test)[:, 1]
    
    # PR-AUC (primary metric)
    pr_auc = average_precision_score(y_test, y_proba)
    
    # Find threshold for 85% recall
    precision, recall, thresholds = precision_recall_curve(y_test, y_proba)
    idx_85 = np.argmin(np.abs(recall[:-1] - 0.85))
    
    metrics = {
        'pr_auc': pr_auc,
        'threshold_85_recall': thresholds[idx_85],
        'precision_at_85_recall': precision[idx_85],
    }
    
    # Evaluate at multiple thresholds
    for thresh in [0.25, 0.40, 0.60]:
        y_pred = (y_proba >= thresh).astype(int)
        tp = ((y_pred == 1) & (y_test == 1)).sum()
        fp = ((y_pred == 1) & (y_test == 0)).sum()
        fn = ((y_pred == 0) & (y_test == 1)).sum()
        tn = ((y_pred == 0) & (y_test == 0)).sum()
        
        metrics[f'recall_at_{thresh}'] = tp / (tp + fn) if (tp + fn) > 0 else 0
        metrics[f'precision_at_{thresh}'] = tp / (tp + fp) if (tp + fp) > 0 else 0
    
    return metrics


def promotion_gate(
    new_model: xgb.XGBClassifier,
    old_model: xgb.XGBClassifier,
    X_test: pd.DataFrame,
    y_test: pd.Series,
    min_recall: float = 0.85,
    max_pr_auc_drop: float = 0.01
) -> tuple[bool, str]:
    """
    Gate that must pass before promoting a new model to production.
    
    Returns (should_promote, reason)
    """
    
    new_metrics = evaluate_model(new_model, X_test, y_test)
    old_metrics = evaluate_model(old_model, X_test, y_test)
    
    # Check 1: PR-AUC should not drop significantly
    pr_auc_change = new_metrics['pr_auc'] - old_metrics['pr_auc']
    if pr_auc_change < -max_pr_auc_drop:
        return False, f"PR-AUC dropped by {-pr_auc_change:.4f} (max allowed: {max_pr_auc_drop})"
    
    # Check 2: Recall at 0.40 threshold must meet minimum
    new_recall = new_metrics['recall_at_0.40']
    if new_recall < min_recall:
        return False, f"Recall at 0.40 threshold is {new_recall:.2%} (min required: {min_recall:.0%})"
    
    # Check 3: High-risk recall (danger signs) - simulate with threshold
    # (In production, this would check recall on hard cases specifically)
    
    return True, f"Model approved. PR-AUC: {new_metrics['pr_auc']:.4f}, Recall: {new_recall:.2%}"


if __name__ == "__main__":
    print("=" * 60)
    print("MamaApp AI Model Training")
    print("=" * 60)
    
    # Generate synthetic data (replace with real data in production)
    print("\nGenerating synthetic training data...")
    df = generate_synthetic_data(n_samples=5000)
    
    # Train model
    print("\nTraining model...")
    model, explainer = train_model(df, n_trials=30)
    
    print("\n" + "=" * 60)
    print("Training complete!")
    print("=" * 60)
