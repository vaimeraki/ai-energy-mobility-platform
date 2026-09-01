# Data sources

## RTE éCO2mix (via Open Data Réseaux Énergies)
- Portal: https://odre.opendatasoft.com/explore/dataset/eco2mix-national-tr/ (national, real-time) and https://odre.opendatasoft.com/explore/dataset/eco2mix-regional-cons-def/ (regional, consolidated/historical)
- What it gives us: electricity generation by source (nuclear, hydro, wind, solar, gas, coal, bioenergy) and cross-border exchanges, at national and regional granularity
- Access: OpenDataSoft Explore API v2.1, public read, no key required for reasonable volumes; an RTE-issued OAuth2 client (free registration) raises rate limits for the newer eco2mix v5 API — see https://www.rte-france.com/en/data-publications/eco2mix/download-indicators
- License: Etalab Licence Ouverte / Open Licence (free reuse with attribution)
- Update cadence: national real-time feed refreshes every few minutes; regional consolidated data is published with a lag (definitive figures follow weeks/months later)
- Why it matters here: this is the primary input for the `carbon_intensity` mart — no carbon-intensity number exists without a generation-mix breakdown

## ADEME Base Empreinte® (formerly Base Carbone®)
- Portal: https://data.ademe.fr/datasets/base-carboner and https://api.gouv.fr/les-api/api_base_carbone
- What it gives us: official French emission factors (gCO2e per km by transport mode, per kWh by energy source, per unit for many other categories)
- Access: public dataset + API (see api.gouv.fr listing for current auth requirements)
- License: Etalab Licence Ouverte
- Update cadence: periodic revisions (methodology updates are versioned)
- Why it matters here: this is the reference table that turns "X km by train instead of car" into an actual CO2e number — it's the ground truth for `mobility_emissions_avoided`

## SNCF Open Data
- Portal: https://ressources.data.sncf.com/ (see the "API théorique et temps réel" and station-traffic/punctuality datasets)
- What it gives us: train schedules, station traffic, and punctuality indicators
- Access: OpenDataSoft Explore API v2.1 (https://ressources.data.sncf.com/api-console/explore/v2.1/), public read
- License: check per-dataset (SNCF publishes most under Etalab Licence Ouverte / ODbL — confirm on the specific dataset page before redistribution)
- Update cadence: varies by dataset; punctuality/traffic data is typically periodic (not real-time)
- Why it matters here: rail traffic volume is the "how much of this is actually happening" side of the modal-shift emissions story

## A note on accuracy
API consoles, exact endpoint paths, and auth requirements on these portals change over time. Before writing an ingestion client against any of these, re-check the live API console/documentation rather than trusting this file or any code comments blindly — treat this doc as a starting map, not a frozen contract.
