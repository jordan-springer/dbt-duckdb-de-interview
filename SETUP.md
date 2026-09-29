# Pre-Interview Setup Guide

Detailed instructions to get the dbt + DuckDB lab running on your machine.

## Prerequisites
- **Python 3.10+** (check with `python --version` or `python3 --version`)
- **git** (to clone this repo)
- **pip** or alternative package manager
- **DuckDB CLI** (the `duckdb` binary for ad-hoc queries — see installation below)

## 1. Install DuckDB CLI

**Important:** The DuckDB CLI is a standalone binary used to run ad-hoc SQL queries against `data/interview.duckdb`. Installing the Python adapter (`dbt-duckdb`) does **not** install the CLI.

### macOS
```bash
brew install duckdb
```

### Linux
**Official install script (recommended):**
```bash
curl -L https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip -o duckdb_cli.zip
unzip duckdb_cli.zip
sudo mv duckdb /usr/local/bin/
chmod +x /usr/local/bin/duckdb
```

**Or via package manager (if available):**
```bash
# Ubuntu/Debian (if packaged)
sudo apt install duckdb

# Or download binary from https://duckdb.org/docs/installation/
```

### Windows
**Option A: winget (recommended)**
```cmd
winget install DuckDB.cli
```

**Option B: Official installer**
1. Download the Windows CLI binary from [duckdb.org/docs/installation/](https://duckdb.org/docs/installation/)
2. Extract `duckdb.exe`
3. Add to PATH or place in your project directory

### Verify installation
```bash
duckdb --version
```
Expected output: `v1.x.x` or similar.

## 2. Install dbt with the DuckDB adapter

**Important distinction:**
- This lab requires **dbt Core 1.8–1.x** (`<2`) plus the **`dbt-duckdb`** adapter
- Do **not** install dbt 2.x for this interview setup
- The DuckDB CLI binary (step 1) is still required separately from the Python adapter

### Option A: pip (recommended)
From the repo root (after clone):
```bash
pip install -r requirements.txt
```
Equivalent pin: `pip install "dbt-core>=1.8.0,<2" dbt-duckdb`

### Option B: Virtual environment (cleaner isolation)
```bash
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate   # Windows CMD
# venv\Scripts\Activate.ps1  # Windows PowerShell

# Then install from repo root (after clone)
pip install -r requirements.txt
```

### Option C: Alternative package managers
- **macOS Homebrew:** `brew install dbt` — confirm `dbt --version` is **1.x** (`<2`); if brew gives 2.x, use the pip pin above in a venv instead
- **Windows winget:** `winget install dbt-labs.dbt-core` — confirm `dbt --version` is **1.x**, then `pip install "dbt-core>=1.8.0,<2" dbt-duckdb` if needed

### Verify installation
```bash
dbt --version
```
**Expected:** `dbt-core: 1.x.x` (must be `<2`) and `dbt-duckdb: 1.x.x`

## 3. Clone this repository
```bash
git clone https://github.com/jordan-springer/senior-de-technical-interview-setup.git
cd senior-de-technical-interview-setup
```

## 4. Configure profiles.yml

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

## 5. Data directory (recovery only)

A normal clone already includes `data/` (tracked via `data/.gitkeep`). You do **not** need to create it for a fresh setup.

Only recreate it if you deleted `data/` and see `Cannot open file "...data/interview.duckdb": No such file or directory`:

**macOS / Linux:**
```bash
mkdir -p data
```

**Windows CMD:**
```cmd
mkdir data
```

**Windows PowerShell:**
```powershell
New-Item -ItemType Directory -Force -Path data
```

## 6. Verify dbt connection
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
| `IO Error: Cannot open file "...data/interview.duckdb": No such file or directory` | `data/` directory doesn't exist | Run `mkdir -p data` (or `mkdir data` on Windows), or pull latest with `data/.gitkeep` |
| `Profile interview_lab does not exist` | `profiles.yml` not in `~/.dbt/` or `DBT_PROFILES_DIR` | Copy `profiles.yml.example` to the correct location |
| `Could not find profile named 'interview_lab'` | Wrong working directory or profile name mismatch | Run `dbt debug` from repo root; verify `profile:` in `dbt_project.yml` matches `profiles.yml` |
| `No module named 'dbt.adapters.duckdb'` | `dbt-duckdb` not installed | `pip install dbt-duckdb` |
| `Runtime Error: Unrecognized adapter type 'duckdb'` | `dbt-duckdb` not installed alongside `dbt-core` | `pip install --upgrade "dbt-core>=1.8.0,<2" dbt-duckdb` |
| `dbt-core` shows 2.x | Accidental dbt 2 install | `pip install "dbt-core>=1.8.0,<2" dbt-duckdb` (recreate the venv if needed) |

## 7. Install dbt packages
```bash
dbt deps
```
This installs `dbt_utils` from `packages.yml`.

## 8. Load seed data
```bash
dbt seed
```
Loads 3 CSV files into `data/interview.duckdb`:
- `seed_sfdc_lead` (50 fake leads)
- `seed_sfdc_campaign` (2 campaigns)
- `seed_sfdc_campaign_member` (50 campaign members with A/B variants)

## 9. Run models
```bash
dbt run
```
Builds:
- **Staging views:** `stg_sfdc__leads`, `stg_sfdc__campaigns`, `stg_sfdc__campaign_members` (in `edw` schema)
- **Mart tables** (in `sfdc` schema): `dim_leads`, `dim_campaigns`, `fct_campaign_members`, `mart_ab_lead_performance`

### Expected output
```
Completed successfully
Done. PASS=7 WARN=0 ERROR=0 SKIP=0 TOTAL=7
```

## 10. Run tests
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

## 11. Verify with DuckDB CLI

Now use the DuckDB CLI (installed in step 1) to query the warehouse directly.

### Query the warehouse
```bash
duckdb data/interview.duckdb
```

**Inside DuckDB REPL:**
```sql
-- List schemas
SHOW SCHEMAS;

-- List all tables
SHOW ALL TABLES;

-- Sample data
SELECT * FROM sfdc.dim_leads LIMIT 5;

-- Verify mart tables exist
SELECT * FROM sfdc.mart_ab_lead_performance LIMIT 5;
```

### Schema naming note
With the custom `generate_schema_name` macro, DuckDB uses clean schema names: `edw` for staging models and seeds, `sfdc` for marts.  
No `main_*` prefixes — tables appear as `edw.stg_sfdc__leads` and `sfdc.dim_leads`.

### Common query failures

| Issue | Fix |
|-------|-----|
| `SHOW ALL TABLES;` returns empty or only staging tables | Run `dbt run` again; check for errors in model builds |
| `Table 'sfdc.dim_leads' not found` | Verify schemas with `SHOW SCHEMAS;` and use the actual schema prefix |
| DuckDB CLI not found | Install from [duckdb.org](https://duckdb.org/docs/installation/) or use Python: `python -c "import duckdb; duckdb.connect('data/interview.duckdb')"` |

## 12. Test incremental workflow
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
- ✅ Installed DuckDB CLI (the `duckdb` binary)
- ✅ Installed dbt-core + dbt-duckdb adapter
- ✅ Configured profiles
- ✅ Run deps, seed, run, test
- ✅ Queried results with the DuckDB CLI
- ✅ Executed a selective model rebuild

**Ready:** If everything above passes, bring that working environment to the live session.

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
- **Check working directory:** Run `pwd` (macOS/Linux) or `cd` (Windows). You must be in the repo root (`senior-de-technical-interview-setup/`).
- **Clear cache:** If models aren't rebuilding, run `dbt clean` then `dbt run` again.
- **Fresh start:** Delete `data/interview.duckdb*`, `target/`, `dbt_packages/`, then re-run `dbt deps && dbt seed && dbt run && dbt test`.
- **Python environment conflicts:** Create a fresh virtual environment and reinstall dbt.

### Still stuck?
- Check dbt logs in `logs/dbt.log`
- Verify `dbt --version` shows Core **1.8–1.x** (`<2`; we verify on 1.10+/1.12)
- Confirm `profiles.yml` path with `dbt debug --config-dir`
