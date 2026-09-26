# dbt + DuckDB Pre-Interview Setup Lab

**Purpose:** Validate your local environment before a live dbt coding interview.  
**Not a take-home puzzle** — this is a quick setup check using a fake Salesforce-style CRM A/B experiment dataset.

## Time estimate
30–60 minutes for environment setup and verification.

## Success criteria
Before your interview, you must confirm:
- ✅ **DuckDB CLI installed** (`duckdb --version` works — this is the standalone binary, not just the Python adapter)
- ✅ **dbt installed** (`dbt --version` shows `dbt-core>=1.8.0` — both dbt 1.8-1.9.x and 2.x work)
- ✅ DuckDB adapter configured (`dbt debug` passes)
- ✅ `data/` directory exists (prevents "No such file or directory" error)
- ✅ Seeds, models, tests run successfully
- ✅ You can query `data/interview.duckdb` directly with the DuckDB CLI
- ✅ You can modify a model and redeploy with `dbt run --select ...`

## Quickstart

### macOS / Linux
```bash
# Install DuckDB CLI (the standalone binary)
brew install duckdb  # macOS
# Linux: see SETUP.md for install script

# Install dbt (2.x has built-in DuckDB; 1.8-1.9.x needs dbt-duckdb)
pip install "dbt-core>=1.8.0" dbt-duckdb  # Works for both versions

# Clone and configure
git clone https://github.com/jordan-springer/dbt-duckdb-de-interview.git
cd dbt-duckdb-de-interview
cp profiles.yml.example ~/.dbt/profiles.yml

# Create data directory (required before first connection)
mkdir -p data

# Run the pipeline
dbt deps
dbt seed
dbt run
dbt test

# Verify with DuckDB CLI
duckdb data/interview.duckdb
```

### Windows
```cmd
# Install DuckDB CLI
winget install DuckDB.cli

# Install dbt (then see SETUP.md for detailed profile configuration)
pip install "dbt-core>=1.8.0" dbt-duckdb

# Create data directory before running dbt
mkdir data
```

See **[SETUP.md](SETUP.md)** for detailed Windows instructions (CMD vs PowerShell, profile paths) and troubleshooting.

## What's included
- **Staging models:** Clean Salesforce-style `lead`, `campaign`, `campaign_member` seeds
- **Marts:** Dimensions, fact table, and an A/B experiment performance summary
- **Custom schema:** Marts land in `main_sfdc` (DuckDB) or `sfdc` (depending on config)
- **Tests:** Schema constraints, accepted values, foreign keys

## Verification queries
After `dbt run`, confirm in DuckDB CLI:

```bash
duckdb data/interview.duckdb
```

```sql
-- Check schemas and tables
SHOW SCHEMAS;
SHOW ALL TABLES;

-- Sample A/B performance (Variant A vs B conversion rates)
SELECT * FROM main_sfdc.mart_ab_lead_performance;

-- Lead conversion metrics
SELECT status, COUNT(*) as ct, SUM(is_converted::int) as converted
FROM main_sfdc.dim_leads
GROUP BY status
ORDER BY converted DESC;
```

## What to do during the interview
See **[DURING_INTERVIEW.md](DURING_INTERVIEW.md)** for workflow guidance.

## Detailed setup guide
See **[SETUP.md](SETUP.md)** for troubleshooting, common errors, and platform-specific notes.

---

**License:** MIT  
**Dataset:** 100% fictional (fake emails, 2099 dates)
