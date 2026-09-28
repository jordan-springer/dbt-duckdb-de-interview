# During the Interview: Workflow Guide

This document outlines what to expect and how to work efficiently during the live dbt coding session.

## What "build and deploy" means here
In this lab, **deploy** = running dbt commands that materialize models into the local DuckDB file (`data/interview.duckdb`).  
The DuckDB file *is* your warehouse. When you run `dbt run`, you're deploying to "production."

## Typical workflow
1. **Edit SQL or YAML** in `models/` directory
2. **Run dbt** to materialize changes:
   ```bash
   dbt run --select model_name      # Single model
   dbt run --select model_name+     # Model + downstream dependencies
   dbt run --select +model_name     # Model + upstream dependencies
   dbt run --select tag:demo        # All models with 'demo' tag
   ```
3. **Verify in DuckDB:**
   ```bash
   duckdb data/interview.duckdb
   ```
   ```sql
   SELECT * FROM sfdc.your_model_name LIMIT 10;
   ```
4. **Run tests** (if modifying constraints):
   ```bash
   dbt test --select model_name
   ```

## Suggested commands (no spoilers)
These are standard dbt operations you may need:

```bash
# Run all models
dbt run

# Run staging only
dbt run --select staging.*

# Run marts only
dbt run --select marts.*

# Run a specific model and its downstream dependents
dbt run --select mart_ab_lead_performance+

# Rebuild everything from scratch
dbt clean
dbt deps
dbt seed
dbt run
dbt test

# Generate documentation (optional)
dbt docs generate
dbt docs serve
```

## How to show your work
During the interview, you may be asked to:
1. **Show terminal output** — `dbt run` logs with green checkmarks
2. **Run queries in DuckDB** — demonstrate that your model produces expected results
3. **Explain your SQL** — walk through joins, aggregations, or business logic
4. **Interpret test failures** — debug why a constraint fails and propose fixes

**Tip:** Keep two terminal tabs open:
- **Tab 1:** For dbt commands (`dbt run`, `dbt test`)
- **Tab 2:** For DuckDB CLI (`duckdb data/interview.duckdb`)

## Querying results in DuckDB
After running models, verify outputs:

```bash
duckdb data/interview.duckdb
```

### Useful queries
```sql
-- List all schemas and tables
SHOW SCHEMAS;
SHOW ALL TABLES;

-- Inspect a model's output
SELECT * FROM sfdc.dim_leads LIMIT 10;

-- Check row counts
SELECT COUNT(*) FROM sfdc.fct_campaign_members;

-- Sample mart data
SELECT * FROM sfdc.mart_ab_lead_performance LIMIT 5;

-- Exit DuckDB
.quit
```

### Schema note
With the custom `generate_schema_name` macro, DuckDB uses clean schema names: `edw` for staging models and seeds, `sfdc` for marts.  
No `main_*` prefixes — tables appear as `edw.stg_sfdc__leads` and `sfdc.dim_leads`.

## Etiquette & best practices
- **Ask clarifying questions** — If a requirement is ambiguous, ask before coding.
- **Think aloud** — Explain your approach as you work ("I'm joining leads to campaign members on lead_id...").
- **Test incrementally** — Don't write 100 lines of SQL then run it. Build queries piece by piece.
- **Use dbt ref() correctly** — Always reference upstream models with `{{ ref('model_name') }}`, not raw table names.
- **Don't worry about perfection** — Interviewers care more about your thought process than syntactically perfect SQL on the first try.

## Git commits (optional)
You may be asked to commit your changes during or after the interview.  
Basic workflow:
```bash
git add models/marts/sfdc/my_new_model.sql
git commit -m "Add my_new_model for X analysis"
```

If you're unfamiliar with git, mention that upfront — it's not a dealbreaker.

## Common pitfalls to avoid
- **Forgetting to run `dbt run` after editing SQL** — Changes don't take effect until you materialize them.
- **Querying the wrong schema** — Check `SHOW ALL TABLES;` to confirm schema names (`edw.*` for staging, `sfdc.*` for marts).
- **Hardcoding table names** — Use `{{ ref('stg_sfdc__leads') }}` instead of `FROM edw.seed_sfdc_lead`.
- **Not checking dbt logs** — If a model fails, read the error message in the terminal output.
- **Overthinking** — Start simple, validate, then iterate.

## Sample interview task (illustrative, not actual)
You might be asked something like:
> "Add a new model `mart_campaign_summary` that shows total leads, responses, and conversions per campaign."

**Suggested approach:**
1. Create `models/marts/sfdc/mart_campaign_summary.sql`
2. Write SQL using `{{ ref('fct_campaign_members') }}`
3. Run: `dbt run --select mart_campaign_summary`
4. Verify: `SELECT * FROM sfdc.mart_campaign_summary;` in DuckDB
5. Add tests in `models/marts/sfdc/marts_sfdc.yml` (if requested)
6. Run: `dbt test --select mart_campaign_summary`

## What success looks like
- You can navigate the dbt project structure confidently
- You write idiomatic dbt SQL (using `ref()`, CTEs, clear aliases)
- You can run selective rebuilds (`--select`)
- You verify outputs in DuckDB
- You explain your reasoning clearly

**Good luck!** The setup work you've done ensures the interview focuses on your data modeling skills, not environment issues.
