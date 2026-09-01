# France Energy Transition & Sustainable Mobility Platform

A data engineering platform that ingests French public open data on electricity generation, transport, and emissions factors, and turns it into concrete decarbonization signals:

- **Grid carbon intensity** — how clean is the French electricity mix right now, and when will it be cleanest in the next few hours?
- **Cleanest-time-to-charge** — align EV charging (or any flexible electricity use) with low-carbon, high-renewable windows on the grid.
- **Rail vs. road emissions avoided** — quantify the CO2e saved when a trip happens by train (SNCF) instead of by car, using ADEME's official emission factors.

This is a personal research + portfolio project built to demonstrate production-grade data engineering practice (ingestion, lakehouse storage, transformation, testing, orchestration, IaC) applied to a real sustainability problem, not a synthetic dataset.

> **Status: active build, documented honestly.** The sections below are split into **Implemented** and **Planned** so this README never claims more than the repo actually contains. See [`PROJECT_PLAN.md`](PROJECT_PLAN.md) for the phase-by-phase roadmap.

## Why this project

Most "energy dashboard" portfolio projects stop at a chart. This one is built as an argument: it takes raw, messy, real government open data and turns it into a specific, defensible sustainability claim (grams of CO2 per kWh, tonnes of CO2e avoided), with the full engineering chain — ingestion, data quality, lineage, tests — visible and reproducible.

## Data sources

| Source | What it provides | Portal |
|---|---|---|
| RTE éCO2mix (via Open Data Réseaux Énergies) | Real-time and historical French electricity generation by source (nuclear, hydro, wind, solar, gas, coal, bioenergy) and cross-border exchanges | [odre.opendatasoft.com](https://odre.opendatasoft.com/explore/dataset/eco2mix-national-tr/) |
| ADEME Base Empreinte® (formerly Base Carbone) | Official French emission factors (gCO2e per km, per kWh, per mode of transport, etc.) | [data.ademe.fr](https://data.ademe.fr/datasets/base-carboner) |
| SNCF Open Data | Train schedules, station traffic, and punctuality data | [ressources.data.sncf.com](https://ressources.data.sncf.com/) |

Full access details, update cadence, and licensing notes are in [`docs/DATA_SOURCES.md`](docs/DATA_SOURCES.md).

## Architecture

```
French open data (RTE éCO2mix · ADEME · SNCF)
        │
        ▼
  Batch ingestion  ──────────────►  Bronze  (raw, as-received, append-only)
        │                              │
        ▼                              ▼
  Micro-batch "streaming"        Silver (cleaned, typed, deduplicated,
  simulation (mobility events)          conformed to a shared schema)
                                        │
                                        ▼
                                  Gold (curated marts via dbt:
                                  carbon_intensity, ev_charging_windows,
                                  mobility_emissions_avoided)
                                        │
                                        ▼
                          PostgreSQL + pgvector (serving + optional
                          embeddings for a later RAG/insight layer)
                                        │
                                        ▼
                              Dashboard / API / LLM insight layer
```

Storage follows a bronze/silver/gold lakehouse pattern on MinIO (S3-compatible) locally, with a matching Azure Blob Storage design in Terraform for a production target. See [`docs/architecture.md`](docs/architecture.md) for the full breakdown, including the deliberate engineering trade-offs (e.g. why this project uses a micro-batch streaming simulation instead of a full Kafka cluster for a single-developer portfolio project, and how it would change in production).

## Implemented today

- Local dev lakehouse via Docker Compose: MinIO (S3-compatible object storage), PostgreSQL + pgvector, pgAdmin
- PostgreSQL schema for energy/mobility staging tables and a vector-embeddings table for the future insight layer (`scripts/init-postgres.sql`)
- Azure infrastructure defined as code in Terraform (Storage Account + containers, Event Hubs namespace) — **design-only, not applied**, to avoid any cloud spend while still demonstrating IaC
- Project structure, roadmap, and data-source research (this repo)

## Planned (see PROJECT_PLAN.md for phases)

- Batch ingestion clients for RTE éCO2mix and ADEME
- Micro-batch mobility ingestion simulating streaming (SNCF)
- Spark jobs for bronze → silver → gold transformation
- dbt models and tests for the three sustainability marts above
- Airflow orchestration
- Data quality checks (Great Expectations or dbt tests)
- CI (lint + test) via GitHub Actions
- Optional: embeddings + RAG layer for natural-language questions over the marts

## Getting started (local dev environment)

```bash
# 1. Copy env template and adjust if needed (defaults work for local dev)
cp .env.example .env

# 2. Start MinIO + PostgreSQL + pgAdmin
make docker-up

# 3. Create the lakehouse buckets
make minio-setup

# 4. Check everything is healthy
make minio-status
```

Services once running:

- MinIO console: http://localhost:9001 (`minioadmin` / see `.env`)
- PostgreSQL: `localhost:5433` from your host machine (containers on the docker network still use 5432 internally), database `aem_platform`
- pgAdmin: http://localhost:8080

To see (but not apply) the Azure infrastructure design:

```bash
make infra-plan       # terraform plan only
make infra-validate   # terraform validate only
```

## Technology stack

**Implemented / used locally:** Docker Compose, MinIO, PostgreSQL + pgvector, Terraform (Azure provider, design-only).

**Planned, phase by phase:** Apache Spark (batch + micro-batch processing), Delta Lake, dbt, Apache Airflow, Great Expectations, GitHub Actions, Azure Blob Storage / Event Hubs (production target).

## License

MIT — see [`LICENSE`](LICENSE).
