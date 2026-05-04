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
French APIs (RTE, SNCF, ADEME)
        ↓
Batch Ingestion (Cloud Functions)
        ↓
Pub/Sub (Streaming Backbone)
        ↓
Spark Structured Streaming (Dataproc)
        ↓
Lakehouse (GCS + Delta Lake)
        ↓
dbt (Analytics Models)
        ↓
BigQuery (Serving Layer)
        ↓
Vector DB (pgvector)
        ↓
LLM (Gemini / OSS)
        ↓
API / Dashboard
```

## Technology Stack
- **Cloud**: Google Cloud Platform (free tier)
- **Data Processing**: Apache Spark (batch & streaming)
- **Storage**: GCS + Delta Lake + BigQuery
- **Orchestration**: Airflow
- **Analytics**: dbt
- **AI**: Open‑source LLM + Retrieval‑Augmented Generation
- **DevOps**: Terraform, CI/CD, Kubernetes