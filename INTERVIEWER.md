# Interviewer Notes

Internal guidance for verifying candidate setup completion.

## Pre-interview verification checklist
Ask candidates to provide the following outputs before the interview:

### 1. dbt version check
```bash
dbt --version
```
**Required:** `dbt-core: 2.x.x` or later, plus `dbt-duckdb` adapter listed.

### 2. Connection test
```bash
dbt debug
```
**Required:** All checks pass (green), including "Connection test: [OK connection ok]".

### 3. Row counts verification
Ask candidate to run:
```bash
duckdb data/interview.duckdb -c "SELECT 'dim_leads' as tbl, COUNT(*) as ct FROM main_sfdc.dim_leads UNION ALL SELECT 'fct_campaign_members', COUNT(*) FROM main_sfdc.fct_campaign_members UNION ALL SELECT 'mart_ab_lead_performance', COUNT(*) FROM main_sfdc.mart_ab_lead_performance;"
```

**Expected output:**
```
tbl                          ct
dim_leads                    50
fct_campaign_members         50
mart_ab_lead_performance      2
```

(Exact row counts may vary if dataset changes, but order of magnitude should match.)

### 4. Test results
```bash
dbt test
```
**Required:** Zero errors. Warnings are acceptable if documented.

## What to look for in live session
- **Comfort with dbt commands:** `dbt run --select`, `dbt test`, `dbt clean`
- **SQL quality:** Proper CTEs, clear aliases, efficient joins
- **Debugging approach:** Reads error messages, checks logs, doesn't panic
- **Communication:** Explains reasoning before/during coding
- **DuckDB fluency:** Can write ad-hoc queries to validate output
- **Incremental thinking:** Builds models step-by-step, tests along the way

## Sample tasks (adjust difficulty for IC level 2-3)
1. **Easy:** Add a column to an existing mart (e.g., `is_high_value_lead` flag based on title keywords)
2. **Medium:** Build a new mart aggregating campaign performance by `campaign_type`
3. **Hard:** Debug a failing test, trace it back to seed data issues, propose a fix
4. **Advanced:** Refactor a model to use a dbt macro (e.g., `dbt_utils.star()`) or implement incremental logic

## Common candidate mistakes
- Forgetting `{{ ref() }}` and using raw table names
- Running `dbt run` without `--select` and waiting for full rebuild
- Not checking `SHOW ALL TABLES;` before querying (schema confusion)
- Writing procedural SQL instead of declarative (e.g., nested subqueries instead of CTEs)
- Not reading error messages fully

## Dataset details (for reference)
- **50 leads** across various companies (fake emails `lead001@example.test`, etc.)
- **2 campaigns:** Spring Email Subject Test (A/B) and Q1 Webinar Series (no A/B)
- **A/B test:** `spring_email_subject_2099` with variants A and B (40 total members: 20 per variant)
- **Conversion rates:** Variant A: 40% (8/20), Variant B: 35% (7/20) — note that A outperforms B in this dataset
- **Response rates:** Variant A: 50% (10/20), Variant B: 55% (11/20) — B has slightly higher response but lower conversion
- **Dates:** All in 2099 (obviously fake)

## No solution key
This repo intentionally does not include answer keys for live coding tasks.  
Interviewers should design tasks based on the existing schema and candidate's IC level.

## Post-interview
- If the candidate struggled with environment setup, note that in feedback (not their fault if clear gaps in the setup guide)
- If they excelled, consider adding a stretch task (e.g., "How would you handle SCD Type 2 for leads?")

---

**Note:** This file is public but contains no proprietary information or actual interview questions.
