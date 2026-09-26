# DE Interview Lab Verification Report

**Date**: September 26, 2026  
**Repo**: jordan-springer/dbt-duckdb-de-interview @ main  
**Verified By**: Cloud Agent  
**PR Created**: [#3](https://github.com/jordan-springer/dbt-duckdb-de-interview/pull/3)

---

## Executive Summary

✅ **Pipeline runs successfully** with all seeds, models, and tests passing  
❌ **Documentation bug found**: INTERVIEWER.md contained incorrect A/B test conversion rate expectations  
✅ **All DURING_INTERVIEW.md commands verified** and work as documented  
🔧 **Fix provided**: PR #3 corrects the A/B test documentation to match actual data

---

## (a) Environment & dbt Version

**dbt Version:**
```
Core: 1.12.5
Plugins: duckdb 1.11.0
```

**DuckDB CLI:**
```
v1.5.5 (Variegata)
```

**Python:**
```
3.12.3
```

---

## (b) Pipeline Execution Results

### ✅ dbt seed
**Status**: PASS  
**Output**: `Done. PASS=7 WARN=0 ERROR=0 SKIP=0 TOTAL=7`

Seeds loaded:
- seed_sfdc_lead (50 rows)
- seed_sfdc_campaign (2 rows)
- seed_sfdc_campaign_member (50 rows)
- seed_sfdc_a_lead (41 rows)
- seed_sfdc_b_lead (68 rows)
- seed_loan_milestones (117 rows)
- seed_marketing_spend (174 rows)

### ✅ dbt run
**Status**: PASS  
**Output**: `Done. PASS=7 WARN=0 ERROR=0 SKIP=0 TOTAL=7`

Models built:
- 3 staging views (stg_sfdc__leads, stg_sfdc__campaigns, stg_sfdc__campaign_members)
- 4 mart tables (dim_leads, dim_campaigns, fct_campaign_members, mart_ab_lead_performance)

### ✅ dbt test
**Status**: PASS  
**Output**: `Done. PASS=24 WARN=0 ERROR=0 SKIP=0 TOTAL=24`

All 24 data tests passed:
- Unique constraints
- Not null constraints
- Accepted values
- Referential integrity

---

## (c) INTERVIEWER.md Checklist Verification

### ✅ Row Counts Check

**Query executed:**
```sql
SELECT 'dim_leads' as tbl, COUNT(*) as ct FROM main_sfdc.dim_leads 
UNION ALL SELECT 'fct_campaign_members', COUNT(*) FROM main_sfdc.fct_campaign_members 
UNION ALL SELECT 'mart_ab_lead_performance', COUNT(*) FROM main_sfdc.mart_ab_lead_performance;
```

**Actual vs Expected:**

| Table | Expected | Actual | Status |
|-------|----------|--------|--------|
| dim_leads | 50 | 50 | ✅ Match |
| fct_campaign_members | 50 | 50 | ✅ Match |
| mart_ab_lead_performance | 2 | 2 | ✅ Match |

### ❌ A/B Test Results Check (BUG FOUND)

**Query executed:**
```sql
SELECT * FROM main_sfdc.mart_ab_lead_performance;
```

**Actual results:**
```
experiment_key            | variant | total_leads | responded_leads | converted_leads | response_rate_pct | conversion_rate_pct
spring_email_subject_2099 | A       | 20          | 10              | 8               | 50.0              | 40.0
spring_email_subject_2099 | B       | 20          | 11              | 7               | 55.0              | 35.0
```

**Documentation stated (INCORRECT):**
> "Conversion rates: Variant B should outperform Variant A (~50% vs ~40%)"

**Reality:**
- **Variant A**: 40% conversion rate (8/20) ✅
- **Variant B**: 35% conversion rate (7/20) ❌ (underperforms A, not outperforms)

**Bug impact**: Interviewers would expect B to show ~50% conversion but actual data shows 35%. This would cause confusion during candidate verification.

**Fix**: PR #3 corrects the documentation to accurately reflect:
- A: 40% conversion (8/20)
- B: 35% conversion (7/20)
- Added note that A outperforms B in this dataset
- Added response rates for context (A: 50%, B: 55%)

---

## (d) DURING_INTERVIEW.md Commands Verification

All spot-checked commands work correctly:

### ✅ Schema inspection commands
```sql
SHOW SCHEMAS;  -- Works
SHOW ALL TABLES;  -- Works, shows 14 tables across main, main_sfdc, main_staging schemas
```

### ✅ Sample queries
```sql
SELECT * FROM main_sfdc.dim_leads LIMIT 10;  -- Works
SELECT COUNT(*) FROM main_sfdc.fct_campaign_members;  -- Works (returns 50)
SELECT * FROM main_sfdc.mart_ab_lead_performance;  -- Works (returns 2 rows)
```

### ✅ Ad-hoc analysis query (line 90-98)
```sql
SELECT lead_source, COUNT(*) as total_leads, SUM(is_converted::int) as converted,
       ROUND(100.0 * SUM(is_converted::int) / COUNT(*), 2) as conversion_rate_pct
FROM main_sfdc.dim_leads
GROUP BY lead_source;
```
**Result**: Works correctly, returns conversion metrics by lead source

### ✅ Schema naming note (line 104-107)
> "DuckDB materializes custom schemas as `main_<schema_name>`"

**Verified**: Correct. Marts configured with `+schema: sfdc` appear as `main_sfdc.*` in DuckDB.

### ✅ dbt selective run commands
```bash
dbt run --select model_name  # Command format is correct
```

---

## (e) Documentation Review

### INTERVIEWER.md
- ❌ **Lines 66-67**: A/B conversion rate expectations were incorrect (fixed in PR #3)
- ✅ All other checklist items are accurate
- ✅ Row count expectations match actual data
- ✅ Command examples are correct

### DURING_INTERVIEW.md
- ✅ All workflow commands are accurate
- ✅ Sample queries work as documented
- ✅ Schema naming explanation is correct
- ✅ File paths and dbt command examples are valid

### SETUP.md
- ✅ Installation instructions are comprehensive and accurate
- ✅ Troubleshooting section covers common issues
- ✅ Platform-specific instructions are detailed

### README.md
- ✅ Quickstart commands are correct
- ✅ Verification queries work as shown
- ✅ Success criteria accurately reflect what passes
- ✅ "~40 A/B test members" is accurate (40 total: 20 A + 20 B)

---

## (f) Risks for Live Interview Use

### 🟢 Low Risk (Environment-Related)
1. **DuckDB file locking**: Multiple concurrent DuckDB CLI sessions can cause lock errors. 
   - **Mitigation**: Documented behavior; interviewers should close CLI between queries or use read-only connections
   - **No fix needed**: This is expected DuckDB concurrency behavior

### 🟢 Low Risk (Documentation)
2. **A/B test interpretation** (FIXED in PR #3)
   - Previous docs would have confused interviewers
   - PR #3 resolves this issue

### 🟢 No Risk (Pipeline)
3. **All pipeline commands work correctly**
   - Seeds, run, test all pass consistently
   - Models materialize to correct schemas
   - Tests validate data quality

### 🟢 No Risk (Candidate Experience)
4. **Candidate-facing docs are accurate**
   - SETUP.md provides clear installation steps
   - DURING_INTERVIEW.md workflow is accurate
   - README.md verification queries work

---

## Summary & Recommendation

### ✅ What Works
- Full dbt pipeline (deps, seed, run, test) executes successfully
- All 24 tests pass
- Row counts match expectations (50, 50, 2)
- DuckDB CLI queries work as documented
- Schema naming is correct (main_sfdc)
- All sample queries in DURING_INTERVIEW.md are accurate

### ❌ What Was Wrong (Now Fixed)
- INTERVIEWER.md A/B test conversion rate documentation was incorrect
- Fix provided in PR #3

### 🎯 Recommendation
**The lab is SAFE for live interview use after PR #3 is merged.**

The single documentation bug has been identified and corrected. All pipeline functionality works correctly, and candidate-facing documentation is accurate. Interviewers will now have correct expectations for A/B test verification.

---

## Pull Request

**PR URL**: https://github.com/jordan-springer/dbt-duckdb-de-interview/pull/3  
**Status**: Draft (ready for review)  
**Changes**: Corrected INTERVIEWER.md A/B test conversion rate documentation to match actual seed data  
**Files Changed**: 1 (INTERVIEWER.md)  
**Lines Changed**: +3 -2
