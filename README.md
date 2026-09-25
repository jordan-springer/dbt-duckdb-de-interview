# dbt + DuckDB Pre-Interview Setup Lab

**Purpose:** Validate your local environment before a live dbt coding interview.  
**Not a take-home puzzle** — this is a quick setup check using a fake Salesforce-style CRM A/B experiment dataset.

## Time estimate
30–60 minutes for environment setup and verification.

## Success criteria
Before your interview, you must confirm:
- ✅ dbt installed (`dbt --version` shows `dbt-core>=1.8.0`)
- ✅ DuckDB adapter configured (`dbt debug` passes)
- ✅ Seeds, models, tests run successfully
- ✅ You can query `data/interview.duckdb` with DuckDB CLI
- ✅ You can modify a model and redeploy with `dbt run --select ...`

## Quickstart

### macOS / Linux
```bash
# Install dbt with the DuckDB adapter
pip install "dbt-core>=1.8.0,<2" dbt-duckdb

# Clone and configure
git clone https://github.com/jordan-springer/dbt-duckdb-de-interview.git
cd dbt-duckdb-de-interview
cp profiles.yml.example ~/.dbt/profiles.yml

# Run the pipeline
dbt deps
dbt seed
dbt run
dbt test
```

### Windows
See **[SETUP.md](SETUP.md)** for detailed Windows instructions (CMD vs PowerShell, profile paths).

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

Expected: 50 leads, 2 campaigns, ~40 A/B test members, conversion rate difference between variants A and B.

## What to do during the interview
See **[DURING_INTERVIEW.md](DURING_INTERVIEW.md)** for workflow guidance.

## Detailed setup guide
See **[SETUP.md](SETUP.md)** for troubleshooting, common errors, and platform-specific notes.

---

**License:** MIT  
**Dataset:** 100% fictional (fake emails, 2099 dates)
