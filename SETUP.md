# Pre-Interview Setup Guide

Detailed instructions to get the dbt + DuckDB lab running on your machine.

## Prerequisites
- **Python 3.10+** (check with `python --version` or `python3 --version`)
- **git** (to clone this repo)
- **pip** or alternative package manager
- **Optional:** DuckDB CLI for ad-hoc queries (install from [duckdb.org](https://duckdb.org/docs/installation/))

## 1. Install dbt with the DuckDB adapter

### Option A: pip (recommended)
```bash
pip install "dbt-core>=1.8.0,<2" dbt-duckdb
```

### Option B: Virtual environment (cleaner isolation)
```bash
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate   # Windows CMD
# venv\Scripts\Activate.ps1  # Windows PowerShell

pip install "dbt-core>=1.8.0,<2" dbt-duckdb
```

### Option C: Alternative package managers
- **macOS Homebrew:** `brew install dbt duckdb` (verify version with `dbt --version`)
- **Windows winget:** `winget install dbt-labs.dbt-core` (then `pip install dbt-duckdb`)

### Verify installation
```bash
dbt --version
```
Expected output includes `dbt-core: 1.x.x` (1.8 or later) and `dbt-duckdb: 1.x.x`.

## 2. Clone this repository
```bash
git clone https://github.com/jordan-springer/dbt-duckdb-de-interview.git
cd dbt-duckdb-de-interview
```

## 3. Configure profiles.yml

dbt requires a `profiles.yml` file to connect to your warehouse (here: a local DuckDB file).

### Option A: Copy to `~/.dbt/profiles.yml` (standard)
**macOS / Linux:**
```bash
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
```

**Windows CMD:**
```cmd
mkdir %USERPROFILE%\.dbt
copy profiles.yml.example %USERPROFILE%\.dbt\profiles.yml
```

**Windows PowerShell:**
```powershell
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.dbt
Copy-Item profiles.yml.example $env:USERPROFILE\.dbt\profiles.yml
```

### Option B: Use `DBT_PROFILES_DIR` environment variable
If you prefer to keep profiles in the project directory:

**macOS / Linux / Windows PowerShell:**
```bash
export DBT_PROFILES_DIR=$(pwd)  # macOS/Linux
$env:DBT_PROFILES_DIR = Get-Location  # PowerShell
```

**Windows CMD:**
```cmd
set DBT_PROFILES_DIR=%cd%
```

Then rename the example file:
```bash
cp profiles.yml.example profiles.yml  # or rename on Windows
```

## 4. Verify dbt connection
```bash
dbt debug
```

### Expected output (green checkmarks)
```
Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]

Required dependencies:
 - git [OK found]

Connection:
  profile: interview_lab
  target: dev
  ...
  Connection test: [OK connection ok]
```

### Common failures

| Error | Cause | Fix |
|-------|-------|-----|
| `Profile interview_lab does not exist` | `profiles.yml` not in `~/.dbt/` or `DBT_PROFILES_DIR` | Copy `profiles.yml.example` to the correct location |
| `Could not find profile named 'interview_lab'` | Wrong working directory or profile name mismatch | Run `dbt debug` from repo root; verify `profile:` in `dbt_project.yml` matches `profiles.yml` |
| `No module named 'dbt.adapters.duckdb'` | `dbt-duckdb` not installed | `pip install dbt-duckdb` |
| `Runtime Error: Unrecognized adapter type 'duckdb'` | `dbt-duckdb` not installed alongside `dbt-core` | `pip install --upgrade dbt-core dbt-duckdb` |

## 5. Install dbt packages
```bash
dbt deps
```
This installs `dbt_utils` from `packages.yml`.

## 6. Load seed data
```bash
dbt seed
```
Loads 3 CSV files into `data/interview.duckdb`:
- `seed_sfdc_lead` (50 fake leads)
- `seed_sfdc_campaign` (2 campaigns)
- `seed_sfdc_campaign_member` (50 campaign members with A/B variants)

## 7. Run models
```bash
dbt run
```
Builds:
- **Staging views:** `stg_sfdc__leads`, `stg_sfdc__campaigns`, `stg_sfdc__campaign_members`
- **Mart tables** (schema `sfdc`): `dim_leads`, `dim_campaigns`, `fct_campaign_members`, `mart_ab_lead_performance`

### Expected output
```
Completed successfully
Done. PASS=7 WARN=0 ERROR=0 SKIP=0 TOTAL=7
```

## 8. Run tests
```bash
dbt test
```
Validates:
- Unique/not_null constraints
- Accepted values for `status`, `variant`
- Referential integrity

### Expected output
```
Completed successfully
Done. PASS=15 WARN=0 ERROR=0 SKIP=0 TOTAL=15
```
(Exact count may vary depending on test definitions.)

## 9. Verify with DuckDB CLI

### Install DuckDB CLI (if not already installed)
- **macOS:** `brew install duckdb`
- **Linux:** Download from [duckdb.org](https://duckdb.org/docs/installation/)
- **Windows:** `winget install DuckDB.cli` or download binary

### Query the warehouse
```bash
duckdb data/interview.duckdb
```

**Inside DuckDB REPL:**
```sql
-- List schemas
SHOW SCHEMAS;

-- List all tables (note custom schema names)
SHOW ALL TABLES;

-- Sample data
SELECT * FROM main_sfdc.dim_leads LIMIT 5;

-- A/B performance (key output)
SELECT * FROM main_sfdc.mart_ab_lead_performance;
```

### Expected A/B results
You should see 2 rows (variants A and B) with different conversion rates:
- **Variant A:** ~40% conversion rate
- **Variant B:** ~50% conversion rate

(Exact numbers depend on seed logic, but B should outperform A.)

### Schema naming note
DuckDB uses `main_<schema>` prefixes by default. If you see `main_sfdc.*` tables, that's correct.  
If tables are in a different schema, check `dbt_project.yml` `+schema:` config.

### Common query failures

| Issue | Fix |
|-------|-----|
| `SHOW ALL TABLES;` returns empty or only `staging.*` tables | Run `dbt run` again; check for errors in model builds |
| `Table 'main_sfdc.dim_leads' not found` | Schema config issue; try `SHOW ALL TABLES;` and use the actual schema prefix |
| DuckDB CLI not found | Install from [duckdb.org](https://duckdb.org/docs/installation/) or use Python: `python -c "import duckdb; duckdb.connect('data/interview.duckdb')"` |

## 10. Test incremental workflow
Modify a model and redeploy:

1. Edit `models/marts/sfdc/mart_ab_lead_performance.sql` (e.g., change column alias)
2. Run only that model:
   ```bash
   dbt run --select mart_ab_lead_performance
   ```
3. Query in DuckDB to confirm changes

**Success:** You can iterate on models without re-running the entire pipeline.

## You're ready!
If all of the above passes, you've successfully:
- ✅ Installed dbt + DuckDB
- ✅ Configured profiles
- ✅ Run deps, seed, run, test
- ✅ Queried results in DuckDB
- ✅ Executed a selective model rebuild

**Next:** Review [DURING_INTERVIEW.md](DURING_INTERVIEW.md) for what to expect in the live coding session.

---

## Troubleshooting tips

### Windows-specific issues
- **PATH not updated:** After installing dbt/Python, restart your terminal or run `refreshenv` (if using Chocolatey).
- **Permissions error:** Run terminal as Administrator if you get access-denied errors during `pip install`.
- **Long path names:** If you see "path too long" errors, enable long paths: `Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1` (requires admin PowerShell).

### macOS-specific issues
- **Multiple Python versions:** Use `python3` and `pip3` explicitly if `python` points to Python 2.7.
- **Permission denied:** Don't use `sudo pip`. Use a virtual environment or `pip install --user`.

### General debugging
- **Check working directory:** Run `pwd` (macOS/Linux) or `cd` (Windows). You must be in the repo root (`dbt-duckdb-de-interview/`).
- **Clear cache:** If models aren't rebuilding, run `dbt clean` then `dbt run` again.
- **Fresh start:** Delete `data/interview.duckdb*`, `target/`, `dbt_packages/`, then re-run `dbt deps && dbt seed && dbt run && dbt test`.
- **Python environment conflicts:** Create a fresh virtual environment and reinstall dbt.

### Still stuck?
- Check dbt logs in `logs/dbt.log`
- Verify `dbt --version` matches requirements (`>=1.8.0,<2`)
- Confirm `profiles.yml` path with `dbt debug --config-dir`
