# Senior Data Engineer — Technical Interview Setup

**Purpose:** Validate your local environment before a live coding interview.  
**Not a take-home puzzle** — this is a quick setup check using a fake Salesforce-style CRM A/B experiment dataset (dbt + DuckDB).

## Time estimate
30–60 minutes for environment setup and verification.

## Success criteria
Before your interview, you must confirm:
- ✅ **DuckDB CLI installed** (`duckdb --version` works — this is the standalone binary, not just the Python adapter)
- ✅ **dbt installed** (`dbt --version` shows `dbt-core` **1.8–1.x** — pin `<2`; we verify on 1.10+/1.12)
- ✅ DuckDB adapter configured (`dbt debug` passes)
- ✅ Seeds, models, tests run successfully
- ✅ You can query `data/interview.duckdb` directly with the DuckDB CLI
- ✅ You can modify a model and redeploy with `dbt run --select ...`

## Quickstart

### macOS / Linux
```bash
# Install DuckDB CLI (the standalone binary)
brew install duckdb  # macOS
# Linux: see SETUP.md for install script

# Clone and configure, then install dbt (Core 1.x pin in requirements.txt; do not use dbt 2.x)
git clone https://github.com/jordan-springer/senior-de-technical-interview-setup.git
cd senior-de-technical-interview-setup
pip install -r requirements.txt
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml

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

# Clone, then install from requirements (Core 1.x pin; do not use dbt 2.x)
git clone https://github.com/jordan-springer/senior-de-technical-interview-setup.git
cd senior-de-technical-interview-setup
pip install -r requirements.txt
mkdir %USERPROFILE%\.dbt
copy profiles.yml.example %USERPROFILE%\.dbt\profiles.yml
```

See **[SETUP.md](SETUP.md)** for detailed Windows instructions (CMD vs PowerShell, profile paths) and troubleshooting.

## What's included
- **Staging models:** Clean Salesforce-style `lead`, `campaign`, `campaign_member` seeds
- **Marts:** Dimensions, fact table, and an A/B experiment performance summary
- **Custom schemas:** Staging models and seeds land in `edw`, marts land in `sfdc`
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

-- Verify models materialized
SELECT COUNT(*) FROM sfdc.dim_leads;
SELECT COUNT(*) FROM edw.stg_sfdc__leads;
```

## Detailed setup guide
See **[SETUP.md](SETUP.md)** for troubleshooting, common errors, and platform-specific notes.

---

**License:** MIT  
**Dataset:** 100% fictional (fake emails, 2099 dates)
