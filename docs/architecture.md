# Architecture

## Layers

**Bronze (raw landing zone, MinIO bucket `aem-raw`)**
Data lands exactly as received from the source API — same field names, same types, no cleaning. One partition per pull. This is the "what did the source actually say" audit trail; never mutated after write.

**Silver (cleaned/conformed, Delta Lake on `aem-processed`)**
Typed, deduplicated, and conformed to a shared schema per domain (energy, mobility, emissions-factors). This is where Spark jobs handle malformed rows, timezone normalization (French sources mix local time and UTC across datasets), and schema drift from the upstream APIs.

**Gold (curated marts, dbt on `aem-analytics` / Postgres)**
Three marts, each answering one sustainability question directly:
- `carbon_intensity` — gCO2/kWh by region and time, derived from the RTE generation mix and ADEME emission factors per source
- `ev_charging_windows` — ranked low-carbon time windows per day, derived from `carbon_intensity` forecasts
- `mobility_emissions_avoided` — estimated CO2e saved per rail trip vs. an equivalent car trip, derived from SNCF traffic and ADEME transport emission factors

## Why micro-batch instead of Kafka

The original design considered Kafka / Azure Event Hubs for "streaming" mobility ingestion. For a single-developer portfolio project, running and operating a Kafka cluster adds real operational overhead (brokers, topics, consumer groups, partitioning strategy) without a corresponding sustainability insight that actually needs sub-second latency — station traffic and punctuality data don't change fast enough to justify it.

Instead, mobility ingestion runs as a short-interval scheduled micro-batch (e.g. every 5-15 minutes), landing into bronze the same way as the batch sources. This still exercises real streaming concepts — idempotent incremental pulls, watermarking on late-arriving records, exactly-once landing — without the operational cost. The production path (swapping the scheduler for Event Hubs + Spark Structured Streaming) is a documented extension, not a redesign, if this ever needed genuine low-latency ingestion.

## Why Azure, design-only

Terraform under `infra/terraform/` defines an Azure Storage Account (mirroring the bronze/silver/gold buckets) and an Event Hubs namespace, targeting France Central. It is deliberately never applied — `terraform validate` and `terraform plan` are run in CI/locally to prove the IaC is correct, without incurring cloud spend. MinIO stands in for Azure Blob Storage locally via the same S3-compatible API surface, so the pipeline code doesn't need to change when/if it moves to Azure.

## Implemented vs. planned

| Component | Status |
|---|---|
| Local lakehouse (Docker Compose: MinIO, Postgres+pgvector, pgAdmin) | Implemented |
| Postgres schema (staging tables + embeddings table) | Implemented |
| Azure Terraform (Storage Account, Event Hubs) | Implemented, design-only |
| RTE / ADEME batch ingestion | Planned — Phase 1 |
| SNCF micro-batch ingestion | Planned — Phase 2 |
| Spark bronze→silver→gold jobs | Planned — Phase 3 |
| dbt marts + tests | Planned — Phase 4 |
| AI/RAG insight layer | Planned — Phase 5 |
| Airflow, CI, Great Expectations, observability | Planned — Phase 6 |
