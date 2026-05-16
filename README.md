# AI‑Driven Energy & Mobility Intelligence Platform 🇫🇷

This project implements a production‑grade data platform that ingests, processes, and analyzes French public energy, mobility, and smart‑city datasets in real time and batch modes.

The platform combines:
- Scalable data engineering (Spark, BigQuery, Pub/Sub)
- Modern DevOps practices (CI/CD, IaC, Kubernetes)
- AI‑powered analytics (LLM + RAG)
- Observability and data quality by design

## Key Use Cases
- Electricity demand monitoring and forecasting
- Mobility & transport delay analysis
- Environmental signal correlation (air quality, weather)
- AI‑assisted insight generation for operators and analysts

## Architecture

```
┌──────────────────────── Azure (Design & Governance) ───────────────────────┐
│ Resource Group | IAM | Terraform (Blob Storage defined, not applied)        │
└────────────────────────────────────────────────────────────────────────────┘
                                │
                                │ (portable boundary)
                                ▼
French APIs (RTE, SNCF, ADEME)
        ↓
Batch Ingestion (Local Functions)
        ↓
MinIO (S3-compatible Streaming)
        ↓
Spark Structured Streaming (Docker)
        ↓
Lakehouse (MinIO + Delta Lake)
        ↓
dbt (Analytics Models)
        ↓
PostgreSQL + pgvector (Local)
        ↓
LLM (Local/Cloud)
        ↓
API / Dashboard
```

## Technology Stack
- **Cloud**: Azure (primary) + MinIO (local S3-compatible) - Hybrid Architecture
- **Data Engineering (Hybrid Cloud)**
- **Python 3.11** - Core language
- **Apache Spark 3.5** - Batch & streaming processing
- **MinIO** - Local S3-compatible data lake (development)
- **Azure Blob Storage** - Cloud data lake (production design)
- **PostgreSQL + pgvector** - Vector database (local)
- **Azure Event Hubs** - Streaming backbone (cloud design)
- **Azure Synapse/Databricks** - Data warehouse & serving layer (cloud design)
- **dbt 1.6** - Analytics transformation
- **Delta Lake** - Lakehouse architecture
- **Airflow 2.7** - Orchestration
- **DevOps / Platform (Hybrid)**
- **Docker** - Containerization
- **Azure Kubernetes Service (AKS)** - Orchestration (cloud design)
- **Terraform** - Infrastructure as Code (Azure)
- **GitHub Actions** - CI/CD
- **Azure Container Registry** - Private registry