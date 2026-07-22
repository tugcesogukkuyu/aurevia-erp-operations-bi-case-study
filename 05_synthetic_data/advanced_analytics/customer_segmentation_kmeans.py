"""
===============================================================================
Aurevia ERP Operations & BI Dashboard
Customer Segmentation K-Means Model

Purpose
-------
This script creates a Python-based K-Means customer segmentation output for the
Aurevia ERP Operations & BI Dashboard.

It supports the Power BI page:
08 - Customer Portfolio Action Model

Business Problem
----------------
Identify which customer groups in the Aurevia portfolio can support revenue
growth without increasing collection risk and profitability risk.

Technology Stack
----------------
- pandas: data preparation
- numpy: numeric calculations
- scikit-learn: K-Means clustering
- StandardScaler: feature scaling before clustering
- joblib: model/scaler persistence
- SQLAlchemy / pyodbc: optional SQL Server integration

Input
-----
Preferred SQL input view:
    vw_Page08_CustomerSegmentationInput

Expected input columns:
    CustomerID
    CustomerName
    CustomerSegment
    Region
    SalesChannel
    TotalRevenue
    GrossProfit
    GrossMarginPercent
    SalesOrderCount
    AvgMonthlyOrderFrequency
    CollectionRate
    OpenBalance
    OpenBalanceRatio
    ProductCategoryDiversity

Outputs
-------
CSV outputs:
    outputs/customer_segments.csv
    outputs/customer_cluster_profile.csv
    outputs/sales_priority_actions.csv
    outputs/model_run_log.csv

Optional SQL target:
    dbo.CustomerSegmentationOutput

Cluster Labels
--------------
The model creates 4 business-readable customer groups:

1. Strategic Value Customers
2. Growth Potential Customers
3. Collection Risk Customers
4. Low Contribution Customers

===============================================================================
"""

from __future__ import annotations

import logging
import os
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List

import joblib
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler
from sqlalchemy import create_engine, text


# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = BASE_DIR / "outputs"
MODEL_DIR = BASE_DIR / "model_artifacts"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
MODEL_DIR.mkdir(parents=True, exist_ok=True)


# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)

logger = logging.getLogger("aurevia_customer_segmentation")


# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

@dataclass
class ModelConfig:
    model_run_id: str
    k_value: int = 4
    random_state: int = 42
    n_init: int = 20
    reporting_start_date: str = "2025-01-01"
    reporting_end_date: str = "2026-06-30"


CONFIG = ModelConfig(
    model_run_id=f"RUN-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
)


FEATURE_COLUMNS: List[str] = [
    "TotalRevenue",
    "GrossMarginPercent",
    "AvgMonthlyOrderFrequency",
    "CollectionRate",
    "OpenBalanceRatio",
    "ProductCategoryDiversity",
]


REQUIRED_COLUMNS: List[str] = [
    "CustomerID",
    "CustomerName",
    "CustomerSegment",
    "Region",
    "SalesChannel",
    "TotalRevenue",
    "GrossProfit",
    "GrossMarginPercent",
    "SalesOrderCount",
    "AvgMonthlyOrderFrequency",
    "CollectionRate",
    "OpenBalance",
    "OpenBalanceRatio",
    "ProductCategoryDiversity",
]


# -----------------------------------------------------------------------------
# SQL Connection
# -----------------------------------------------------------------------------

def get_sql_engine():
    """
    Creates a SQL Server connection engine.

    Environment variables:
        AUREVIA_SQL_SERVER
        AUREVIA_SQL_DATABASE
        AUREVIA_SQL_USERNAME
        AUREVIA_SQL_PASSWORD

    Example:
        AUREVIA_SQL_SERVER=localhost,1434
        AUREVIA_SQL_DATABASE=AureviaERPBI
        AUREVIA_SQL_USERNAME=sa
        AUREVIA_SQL_PASSWORD=AureviaERP2026!
    """

    server = os.getenv("AUREVIA_SQL_SERVER")
    database = os.getenv("AUREVIA_SQL_DATABASE")
    username = os.getenv("AUREVIA_SQL_USERNAME")
    password = os.getenv("AUREVIA_SQL_PASSWORD")

    if not all([server, database, username, password]):
        raise RuntimeError(
            "SQL connection variables are missing. "
            "Set AUREVIA_SQL_SERVER, AUREVIA_SQL_DATABASE, "
            "AUREVIA_SQL_USERNAME, and AUREVIA_SQL_PASSWORD."
        )

    connection_string = (
        "mssql+pyodbc://"
        f"{username}:{password}@{server}/{database}"
        "?driver=ODBC+Driver+18+for+SQL+Server"
        "&TrustServerCertificate=yes"
    )

    return create_engine(connection_string, fast_executemany=True)


# -----------------------------------------------------------------------------
# Data Loading
# -----------------------------------------------------------------------------

def load_customer_features_from_sql() -> pd.DataFrame:
    """
    Loads customer segmentation features from SQL Server.

    Source view:
        vw_Page08_CustomerSegmentationInput
    """

    logger.info("Loading customer segmentation input from SQL Server.")

    engine = get_sql_engine()

    query = """
        SELECT
            CustomerID,
            CustomerName,
            CustomerSegment,
            Region,
            SalesChannel,
            TotalRevenue,
            GrossProfit,
            GrossMarginPercent,
            SalesOrderCount,
            AvgMonthlyOrderFrequency,
            CollectionRate,
            OpenBalance,
            OpenBalanceRatio,
            ProductCategoryDiversity
        FROM vw_Page08_CustomerSegmentationInput;
    """

    df = pd.read_sql(query, engine)

    logger.info("Loaded %s customer records from SQL.", len(df))

    return df


def load_customer_features_from_csv(input_file: str | Path) -> pd.DataFrame:
    """
    Loads customer segmentation features from a CSV file.

    This option is useful for portfolio review, local testing, or when SQL Server
    is not available.
    """

    input_path = Path(input_file)

    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    logger.info("Loading customer segmentation input from CSV: %s", input_path)

    df = pd.read_csv(input_path)

    logger.info("Loaded %s customer records from CSV.", len(df))

    return df


# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------

def validate_input_schema(df: pd.DataFrame) -> None:
    """
    Validates required input columns and basic data completeness.
    """

    missing_columns = [col for col in REQUIRED_COLUMNS if col not in df.columns]

    if missing_columns:
        raise ValueError(f"Missing required columns: {missing_columns}")

    if df.empty:
        raise ValueError("Input dataset is empty.")

    duplicate_customers = df["CustomerID"].duplicated().sum()

    if duplicate_customers > 0:
        logger.warning(
            "Input contains %s duplicate CustomerID records. "
            "The model expects one row per customer.",
            duplicate_customers,
        )

    logger.info("Input schema validation completed.")


def prepare_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Cleans numeric model features before scaling and clustering.
    """

    model_df = df.copy()

    for col in FEATURE_COLUMNS:
        model_df[col] = pd.to_numeric(model_df[col], errors="coerce")

    model_df[FEATURE_COLUMNS] = model_df[FEATURE_COLUMNS].replace(
        [np.inf, -np.inf],
        np.nan,
    )

    model_df[FEATURE_COLUMNS] = model_df[FEATURE_COLUMNS].fillna(
        model_df[FEATURE_COLUMNS].median(numeric_only=True)
    )

    return model_df


# -----------------------------------------------------------------------------
# Cluster Labeling
# -----------------------------------------------------------------------------

def build_cluster_profile(df: pd.DataFrame) -> pd.DataFrame:
    """
    Creates a numeric cluster profile to support business-readable labels.
    """

    profile = (
        df.groupby("ClusterID")
        .agg(
            CustomerCount=("CustomerID", "nunique"),
            TotalRevenue=("TotalRevenue", "sum"),
            GrossProfit=("GrossProfit", "sum"),
            GrossMarginPercent=("GrossMarginPercent", "mean"),
            CollectionRate=("CollectionRate", "mean"),
            OpenBalance=("OpenBalance", "sum"),
            OpenBalanceRatio=("OpenBalanceRatio", "mean"),
            AvgMonthlyOrderFrequency=("AvgMonthlyOrderFrequency", "mean"),
            ProductCategoryDiversity=("ProductCategoryDiversity", "mean"),
        )
        .reset_index()
    )

    profile["RevenueRank"] = profile["TotalRevenue"].rank(
        ascending=False,
        method="first",
    )

    profile["MarginRank"] = profile["GrossMarginPercent"].rank(
        ascending=False,
        method="first",
    )

    profile["CollectionRank"] = profile["CollectionRate"].rank(
        ascending=False,
        method="first",
    )

    profile["OpenBalanceRiskRank"] = profile["OpenBalance"].rank(
        ascending=False,
        method="first",
    )

    profile["ValueScore"] = (
        profile["TotalRevenue"].rank(pct=True)
        + profile["GrossMarginPercent"].rank(pct=True)
        + profile["CollectionRate"].rank(pct=True)
        + profile["AvgMonthlyOrderFrequency"].rank(pct=True)
        - profile["OpenBalanceRatio"].rank(pct=True)
    )

    profile["RiskScore"] = (
        profile["OpenBalance"].rank(pct=True)
        + (1 - profile["CollectionRate"].rank(pct=True))
        + (1 - profile["GrossMarginPercent"].rank(pct=True))
    )

    return profile


def assign_business_cluster_labels(df: pd.DataFrame) -> pd.DataFrame:
    """
    Converts K-Means numeric cluster IDs into business-readable labels.

    Labeling logic:
    - Highest business value cluster:
        Strategic Value Customers
    - Highest collection/open balance risk cluster:
        Collection Risk Customers
    - Remaining cluster with higher revenue / healthier margin:
        Growth Potential Customers
    - Remaining cluster:
        Low Contribution Customers
    """

    model_df = df.copy()

    profile = build_cluster_profile(model_df)

    strategic_cluster = (
        profile.sort_values("ValueScore", ascending=False)
        .iloc[0]["ClusterID"]
    )

    risk_cluster = (
        profile.sort_values("RiskScore", ascending=False)
        .iloc[0]["ClusterID"]
    )

    remaining = profile[
        ~profile["ClusterID"].isin([strategic_cluster, risk_cluster])
    ].copy()

    if len(remaining) >= 2:
        growth_cluster = (
            remaining.sort_values(
                ["TotalRevenue", "GrossMarginPercent"],
                ascending=False,
            )
            .iloc[0]["ClusterID"]
        )

        low_contribution_cluster = remaining[
            remaining["ClusterID"] != growth_cluster
        ].iloc[0]["ClusterID"]
    else:
        growth_cluster = remaining.iloc[0]["ClusterID"]
        low_contribution_cluster = risk_cluster

    label_map: Dict[int, str] = {
        int(strategic_cluster): "Strategic Value Customers",
        int(growth_cluster): "Growth Potential Customers",
        int(risk_cluster): "Collection Risk Customers",
        int(low_contribution_cluster): "Low Contribution Customers",
    }

    model_df["ClusterLabel"] = model_df["ClusterID"].map(label_map)

    action_map: Dict[str, str] = {
        "Strategic Value Customers": "Protect / Retain / Upsell",
        "Growth Potential Customers": "Grow / Cross-sell",
        "Collection Risk Customers": "Collect First / Monitor Credit",
        "Low Contribution Customers": "Low-Touch Service",
    }

    model_df["RecommendedAction"] = model_df["ClusterLabel"].map(action_map)

    return model_df


# -----------------------------------------------------------------------------
# Priority Scoring
# -----------------------------------------------------------------------------

def add_customer_priority_score(df: pd.DataFrame) -> pd.DataFrame:
    """
    Creates an action-oriented customer priority score.

    Business logic:
    - High revenue increases priority.
    - High open balance increases finance follow-up priority.
    - Low collection rate increases risk priority.
    - Cluster label adjusts action priority.
    """

    model_df = df.copy()

    revenue_scaled = model_df["TotalRevenue"] / model_df["TotalRevenue"].max()
    open_balance_scaled = model_df["OpenBalance"] / model_df["OpenBalance"].max()
    collection_risk = 1 - model_df["CollectionRate"].fillna(0)

    cluster_weight_map = {
        "Strategic Value Customers": 0.20,
        "Growth Potential Customers": 0.15,
        "Collection Risk Customers": 0.30,
        "Low Contribution Customers": 0.05,
    }

    cluster_weight = model_df["ClusterLabel"].map(cluster_weight_map).fillna(0)

    model_df["CustomerPriorityScore"] = (
        revenue_scaled * 0.35
        + open_balance_scaled * 0.25
        + collection_risk * 0.25
        + cluster_weight
    )

    model_df["CustomerPriorityScore"] = model_df["CustomerPriorityScore"].round(4)

    return model_df


# -----------------------------------------------------------------------------
# Model Training
# -----------------------------------------------------------------------------

def run_kmeans_segmentation(df: pd.DataFrame) -> tuple[pd.DataFrame, dict]:
    """
    Runs K-Means segmentation and returns customer-level outputs plus metadata.
    """

    validate_input_schema(df)

    model_df = prepare_features(df)

    scaler = StandardScaler()
    scaled_features = scaler.fit_transform(model_df[FEATURE_COLUMNS])

    kmeans = KMeans(
        n_clusters=CONFIG.k_value,
        random_state=CONFIG.random_state,
        n_init=CONFIG.n_init,
    )

    model_df["ClusterID"] = kmeans.fit_predict(scaled_features)

    silhouette = silhouette_score(scaled_features, model_df["ClusterID"])

    model_df = assign_business_cluster_labels(model_df)
    model_df = add_customer_priority_score(model_df)

    model_df["ModelRunID"] = CONFIG.model_run_id
    model_df["ModelRunDate"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    joblib.dump(kmeans, MODEL_DIR / "customer_kmeans_model.joblib")
    joblib.dump(scaler, MODEL_DIR / "customer_feature_scaler.joblib")

    metadata = {
        "ModelRunID": CONFIG.model_run_id,
        "ModelRunDate": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "ModelType": "Python K-Means",
        "KValue": CONFIG.k_value,
        "FeatureCount": len(FEATURE_COLUMNS),
        "FeatureColumns": ", ".join(FEATURE_COLUMNS),
        "SilhouetteScore": round(float(silhouette), 4),
        "CustomerCount": int(model_df["CustomerID"].nunique()),
        "TotalRevenue": round(float(model_df["TotalRevenue"].sum()), 2),
        "OpenBalance": round(float(model_df["OpenBalance"].sum()), 2),
    }

    logger.info("K-Means segmentation completed.")
    logger.info("Silhouette Score: %.4f", silhouette)

    return model_df, metadata


# -----------------------------------------------------------------------------
# Output Builders
# -----------------------------------------------------------------------------

def build_cluster_profile_output(model_df: pd.DataFrame) -> pd.DataFrame:
    """
    Creates the cluster-level output used in the Power BI heatmap and summary cards.
    """

    total_revenue = model_df["TotalRevenue"].sum()
    total_open_balance = model_df["OpenBalance"].sum()

    output = (
        model_df.groupby("ClusterLabel")
        .agg(
            CustomerCount=("CustomerID", "nunique"),
            Revenue=("TotalRevenue", "sum"),
            GrossProfit=("GrossProfit", "sum"),
            GrossMarginPercent=("GrossMarginPercent", "mean"),
            OpenBalance=("OpenBalance", "sum"),
            CollectionRate=("CollectionRate", "mean"),
            AvgMonthlyOrderFrequency=("AvgMonthlyOrderFrequency", "mean"),
            ProductCategoryDiversity=("ProductCategoryDiversity", "mean"),
        )
        .reset_index()
    )

    output["RevenueSharePercent"] = output["Revenue"] / total_revenue
    output["OpenBalanceSharePercent"] = output["OpenBalance"] / total_open_balance

    cluster_order = {
        "Strategic Value Customers": 1,
        "Growth Potential Customers": 2,
        "Collection Risk Customers": 3,
        "Low Contribution Customers": 4,
    }

    output["ClusterSortOrder"] = output["ClusterLabel"].map(cluster_order)

    output = output.sort_values("ClusterSortOrder")

    return output


def build_sales_priority_actions(model_df: pd.DataFrame) -> pd.DataFrame:
    """
    Creates a compact action queue used by Power BI.
    """

    actions = []

    strategic = model_df[
        model_df["ClusterLabel"] == "Strategic Value Customers"
    ]

    growth = model_df[
        model_df["ClusterLabel"] == "Growth Potential Customers"
    ]

    risk = model_df[
        model_df["ClusterLabel"] == "Collection Risk Customers"
    ]

    low_contribution = model_df[
        model_df["ClusterLabel"] == "Low Contribution Customers"
    ]

    actions.append(
        {
            "ActionType": "Protect",
            "TargetGroup": "Strategic Value Customers",
            "FinancialValue": strategic["TotalRevenue"].sum(),
            "ValueType": "Revenue",
            "RecommendedAction": "Protect / Retain / Upsell",
        }
    )

    actions.append(
        {
            "ActionType": "Grow",
            "TargetGroup": "Growth Potential Customers",
            "FinancialValue": growth["TotalRevenue"].sum(),
            "ValueType": "Revenue",
            "RecommendedAction": "Grow / Cross-sell",
        }
    )

    actions.append(
        {
            "ActionType": "Collect First",
            "TargetGroup": "Collection Risk Customers",
            "FinancialValue": risk["OpenBalance"].sum(),
            "ValueType": "Open Balance",
            "RecommendedAction": "Collect First / Monitor Credit",
        }
    )

    actions.append(
        {
            "ActionType": "Low-Touch Service",
            "TargetGroup": "Low Contribution Customers",
            "FinancialValue": low_contribution["CustomerID"].nunique(),
            "ValueType": "Customer Count",
            "RecommendedAction": "Low-Touch Service",
        }
    )

    return pd.DataFrame(actions)


def write_outputs(model_df: pd.DataFrame, metadata: dict) -> None:
    """
    Writes CSV outputs for Power BI and technical review.
    """

    cluster_profile = build_cluster_profile_output(model_df)
    priority_actions = build_sales_priority_actions(model_df)

    customer_output_file = OUTPUT_DIR / "customer_segments.csv"
    cluster_profile_file = OUTPUT_DIR / "customer_cluster_profile.csv"
    priority_actions_file = OUTPUT_DIR / "sales_priority_actions.csv"
    model_run_log_file = OUTPUT_DIR / "model_run_log.csv"

    model_df.to_csv(customer_output_file, index=False)
    cluster_profile.to_csv(cluster_profile_file, index=False)
    priority_actions.to_csv(priority_actions_file, index=False)
    pd.DataFrame([metadata]).to_csv(model_run_log_file, index=False)

    logger.info("Customer-level output written to: %s", customer_output_file)
    logger.info("Cluster profile output written to: %s", cluster_profile_file)
    logger.info("Priority actions output written to: %s", priority_actions_file)
    logger.info("Model run log written to: %s", model_run_log_file)


# -----------------------------------------------------------------------------
# Optional SQL Writeback
# -----------------------------------------------------------------------------

def write_customer_segments_to_sql(model_df: pd.DataFrame) -> None:
    """
    Writes customer segmentation outputs back to SQL Server.

    Target table:
        dbo.CustomerSegmentationOutput

    The table contract is defined in:
        04_sql_database/advanced_analytics_reporting_queries.sql
    """

    logger.info("Writing customer segmentation output to SQL Server.")

    engine = get_sql_engine()

    output_columns = [
        "CustomerID",
        "CustomerName",
        "CustomerSegment",
        "Region",
        "SalesChannel",
        "TotalRevenue",
        "GrossProfit",
        "GrossMarginPercent",
        "SalesOrderCount",
        "AvgMonthlyOrderFrequency",
        "CollectionRate",
        "OpenBalance",
        "OpenBalanceRatio",
        "ProductCategoryDiversity",
        "ClusterID",
        "ClusterLabel",
        "RecommendedAction",
        "CustomerPriorityScore",
        "ModelRunID",
        "ModelRunDate",
    ]

    write_df = model_df[output_columns].copy()

    with engine.begin() as connection:
        connection.execute(text("TRUNCATE TABLE dbo.CustomerSegmentationOutput;"))

    write_df.to_sql(
        "CustomerSegmentationOutput",
        con=engine,
        schema="dbo",
        if_exists="append",
        index=False,
        chunksize=500,
    )

    logger.info("SQL writeback completed. Rows written: %s", len(write_df))


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

def main() -> None:
    """
    Execution modes:

    1. SQL mode:
        Reads from vw_Page08_CustomerSegmentationInput and optionally writes back
        to dbo.CustomerSegmentationOutput.

    2. CSV mode:
        Reads from a local CSV file. Useful for local testing.

    Environment variables:
        AUREVIA_INPUT_MODE = sql or csv
        AUREVIA_INPUT_CSV = path to input CSV
        AUREVIA_WRITE_TO_SQL = true or false
    """

    input_mode = os.getenv("AUREVIA_INPUT_MODE", "csv").lower()
    write_to_sql = os.getenv("AUREVIA_WRITE_TO_SQL", "false").lower() == "true"

    if input_mode == "sql":
        df = load_customer_features_from_sql()
    else:
        input_csv = os.getenv(
            "AUREVIA_INPUT_CSV",
            str(BASE_DIR / "customer_segmentation_input.csv"),
        )
        df = load_customer_features_from_csv(input_csv)

    model_df, metadata = run_kmeans_segmentation(df)

    write_outputs(model_df, metadata)

    if write_to_sql:
        write_customer_segments_to_sql(model_df)

    logger.info("Customer segmentation pipeline completed successfully.")


if __name__ == "__main__":
    main()