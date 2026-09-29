# Senior Data Engineer — Technical Interview Setup

**Purpose:** Validate your local environment before a live coding interview.  
**Not a take-home puzzle** — this is a quick setup check using a fake Salesforce-style CRM / mortgage-lead dataset (dbt + DuckDB) aligned to the Architecture Interview warehouse models.

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

# Install dbt Core 1.x + DuckDB adapter (do not use dbt 2.x for this lab)
pip install "dbt-core>=1.8.0,<2" dbt-duckdb

# Clone and configure
git clone https://github.com/jordan-springer/senior-de-technical-interview-setup.git
cd senior-de-technical-interview-setup
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

# Install dbt (then see SETUP.md for detailed profile configuration)
pip install "dbt-core>=1.8.0,<2" dbt-duckdb

# Clone, then create ~/.dbt before copying the profile
git clone https://github.com/jordan-springer/senior-de-technical-interview-setup.git
cd senior-de-technical-interview-setup
mkdir %USERPROFILE%\.dbt
copy profiles.yml.example %USERPROFILE%\.dbt\profiles.yml
```

See **[SETUP.md](SETUP.md)** for detailed Windows instructions (CMD vs PowerShell, profile paths) and troubleshooting.

## What's included
- **Seeds / staging:** a-lead (`LEAD`), b-lead (`BLEAD__C`), loan milestones, marketing spend
- **Marts (Architecture Interview):** `dim_lead`, `fact_conversion_transaction`, `fact_marketing_spend`
- **Schema:** All seeds and models land in DuckDB default schema `main` (no custom `edw` / `sfdc`)
- **Tests:** Unique/not_null, accepted values on status / milestone / channel

## Verification queries
After `dbt run`, confirm in DuckDB CLI:

```bash
duckdb data/interview.duckdb
```

```sql
-- Check schemas and tables
SHOW SCHEMAS;
SHOW ALL TABLES;

-- Verify Architecture Interview marts (all in main)
SELECT COUNT(*) FROM dim_lead;
SELECT COUNT(*) FROM fact_conversion_transaction;
SELECT COUNT(*) FROM fact_marketing_spend;
SELECT COUNT(*) FROM stg_sfdc__a_leads;
SELECT COUNT(*) FROM stg_sfdc__b_leads;
-- or: SELECT COUNT(*) FROM main.dim_lead;
```

## Detailed setup guide
See **[SETUP.md](SETUP.md)** for troubleshooting, common errors, and platform-specific notes.

---

**License:** MIT  
**Dataset:** 100% fictional (fake emails, 2099 dates)
