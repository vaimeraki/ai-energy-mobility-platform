# Roadmap

Each phase lists the deliverable, the concrete sustainability question it answers, and the data engineering concept it's meant to teach. Phases are built one at a time — nothing here is claimed as done in the README until it actually exists and runs.

## Phase 0 — Foundations (done)
- Repo hygiene: no secrets committed, no binaries committed, `.gitignore` covers state/cache/credentials
- One coherent cloud story (Azure, design-only via Terraform) instead of three competing ones
- Local dev lakehouse runnable via `docker compose up` (MinIO + Postgres/pgvector)
- **Concept:** a portfolio repo is read by humans before any code runs — structure and honesty are part of the deliverable.

## Phase 1 — Batch ingestion
- Deliverable: Python clients for RTE éCO2mix (national + regional generation mix) and ADEME Base Empreinte (emission factors), landing raw JSON/CSV into the `bronze` zone in MinIO, one partition per pull (`source=rte/date=YYYY-MM-DD/...`)
- Sustainability question answered: "what does the French electricity mix actually look like, and what's the official emission factor for each mode?"
- **Concepts:** idempotent ingestion (safe to re-run), partitioning strategy, retry/backoff against a public API, schema-on-read vs. schema-on-write

## Phase 2 — Mobility ingestion (micro-batch "streaming")
- Deliverable: scheduled pulls of SNCF station traffic / punctuality data on a short interval, landing into bronze the same way as batch data
- Sustainability question answered: "how much rail traffic is happening, and how reliable is it as a car alternative?"
- **Concepts:** streaming vs. micro-batch trade-offs, why this project chooses micro-batch over Kafka (documented in `docs/architecture.md`), watermarking/late data

## Phase 3 — Processing & lakehouse (bronze → silver → gold)
- Deliverable: Spark jobs that clean, type, deduplicate, and conform bronze data into silver (Delta Lake tables), then aggregate into gold marts
- Sustainability question answered: none yet directly — this phase makes the data trustworthy enough to answer one
- **Concepts:** medallion architecture, schema evolution, data contracts between layers, Delta Lake ACID guarantees on object storage

## Phase 4 — Analytics (dbt marts + tests)
- Deliverable: three dbt marts — `carbon_intensity` (gCO2/kWh over time, by region), `ev_charging_windows` (ranked low-carbon windows per day), `mobility_emissions_avoided` (CO2e saved by rail vs. estimated car equivalent, using ADEME factors) — each with dbt tests (not-null, accepted ranges, freshness)
- Sustainability question answered: all three from the README, directly, with numbers
- **Concepts:** transformation-as-code, testing data instead of just code, semantic layer / metrics definitions

## Phase 5 — AI layer (optional, after Phase 4 is real)
- Deliverable: embeddings over the gold marts + documentation in Postgres/pgvector, a small RAG layer that can answer natural-language questions like "when should I charge my EV tomorrow?"
- **Concepts:** when an LLM/RAG layer is a genuine value-add vs. resume-padding — this phase is deliberately last, on top of data that's already correct

## Phase 6 — Production readiness
- Deliverable: GitHub Actions CI (lint, type-check, test), Airflow DAGs replacing manual runs, Great Expectations checks, basic observability (pipeline run metrics), and validating (not applying) the Azure Terraform plan against the real schema
- **Concepts:** the gap between "runs on my laptop" and "runs unattended and tells you when it breaks"

## Explicitly out of scope for now
- Kubernetes/AKS — no orchestrator-of-orchestrators needed for a single-developer project; would only be added if this became a multi-service production deployment
- Multi-cloud (GCP, Scaleway) — one cloud target (Azure) is enough to demonstrate IaC competence without spreading effort thin
- A production Kafka cluster — the mobility "streaming" need is met by micro-batch polling; the architecture doc explains how this would swap for Event Hubs/Kafka in a real production deployment
