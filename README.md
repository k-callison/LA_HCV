# Spending to Save: The Subscription Model for Eradicating Hepatitis C in Louisiana

---

## Overview

This repository contains the replication code for:

> Callison, K., Conti, R.M., Gruber, J., and Wallace, J. (2026). "Spending to Save: The Subscription Model for Eradicating Hepatitis C in Louisiana."

The paper provides the first empirical estimates of the impact of Louisiana's Hepatitis C (HCV) subscription model on Medicaid spending. In July 2019, Louisiana launched a pilot program designating one direct-acting antiviral (DAA) manufacturer as the default supplier for the state Medicaid and incarcerated populations with HCV at a fixed total cost of approximately $225 million over five years. In exchange, the manufacturer agreed to supply DAA therapies to all eligible patients, covering any utilization above an annual spending cap at no additional cost to the state.

Using Louisiana Medicaid claims and enrollment data from 2017–2023, we model changes in spending for those diagnosed with HCV before and after the subscription model's introduction. We conduct parallel analyses for diabetes and HIV to control for broader time trends in chronic illness spending. We supplement these data with national DAA spending data from IQVIA to assess the marginal value of the subscription model against a counterfactual in which the state relied solely on falling DAA prices through manufacturer competition.

We conclude that the program was money-saving over its five-year term. Estimates suggest savings of approximately $5,300 per treated patient per year, or about one-third of baseline Medicaid spending. Gross savings over five years total $230–250 million, with roughly one quarter attributable to reduced HCV transmission.

---

## Data

This project uses two primary data sources:

### 1. Louisiana Medicaid Administrative Data
Claims and enrollment records provided by the Louisiana Department of Health. The analysis covers July 2017 through July 2023. These data are not publicly available. Researchers seeking access should contact the Louisiana Department of Health.

The data include:
- Claim diagnosis detail: ICD-9 and ICD-10 diagnosis and procedure codes linked to individual claims along with allowed amounts for services provided
- Eligibility/enrollment records: monthly enrollment periods and member demographics (e.g., birth date, sex, race, ethnicity, zip code)

### 2. IQVIA National DAA Spending Data
- **IQVIA National Sales Perspective**: quarterly dollar and unit sales for DAA prescriptions by national and state market, 2017–2023
- **IQVIA LRx**: prescriptions dispensed by retail and mail pharmacies, with state and payor identifiers, 2017–2023

These data are licensed and must be obtained directly from IQVIA. They are used to construct the counterfactual spending path under competition-driven DAA price declines.

---

## Software Requirements

| Software | Version | Purpose |
|----------|---------|---------|
| SQL (PostgreSQL-compatible) | — | Cohort extraction from Medicaid claims database |
| Stata | 16 or later | Data preparation and analysis |

---

## Repository Structure

```
LA_HCV_Github_files/
├── README.md
├── LICENSE
│
├── Build/
│   ├── SQL_Files/
│   │   ├── hcv_prep.sql          # Extracts HCV cohort from Medicaid claims
│   │   ├── hiv_prep.sql          # Extracts HIV cohort from Medicaid claims
│   │   └── diab_prep.sql         # Extracts diabetes cohort from Medicaid claims
│   │
│   └── Stata_Files/
│       ├── hcv_prep_file.do      # Processes HCV analytic file into cohort dataset
│       ├── hiv_prep_file.do      # Processes HIV analytic file into cohort dataset
│       └── diab_prep_file.do     # Processes diabetes analytic file into cohort dataset
│
└── Analysis/
    └── Stata_Files/
        ├── master.do             # Master script: sets globals, builds analytic files, calls all analysis scripts
        │
        ├── Figures/
        │   ├── figure2.do        # Fig. 2: Spending trajectories around DAA initiation
        │   ├── figure3.do        # Fig. 3: HCV vs. diabetes/HIV spending trends and event studies (Panels A–D)
        │   ├── figure4.do        # Fig. 4: New HCV, diabetes, and HIV diagnoses over time (Panels A–B)
        │   ├── app_figure1.do    # Appendix Figure 1
        │   ├── app_figure2.do    # Appendix Figure 2
        │   ├── app_figure3.do    # Appendix Figure 3
        │   ├── app_figure4.do    # Appendix Figure 4
        │   ├── app_figure5.do    # Appendix Figure 5
        │   ├── app_figure6.do    # Appendix Figure 6
        │   ├── app_figure7.do    # Appendix Figure 7
        │   ├── app_figure8.do    # Appendix Figure 8
        │   ├── app_figure9.do    # Appendix Figure 9
        │   └── app_figure10.do   # Appendix Figure 10
        │
        └── Tables/
            ├── table1.do         # Table 1: Summary statistics
            ├── table2.do         # Table 2: DiD estimates of subscription model effects on HCV spending
            ├── table3.do         # Table 3: DiD estimates of subscription model effects on HCV transmission
            ├── table4.do         # Table 4: Cost-benefit analysis (depends on scalars from table2.do and table3.do)
            ├── table5.do         # Table 5: Comparison to Counterfactual Spending
            ├── app_table2.do     # Appendix Table 2
            └── app_table3.do     # Appendix Table 3
```

---

## Replication Instructions

### Step 1: Build Cohort Datasets

The build stage proceeds in two sub-steps for each of the three disease cohorts (HCV, HIV, diabetes) beginning with SQL scripts to extract cohorts from the Medicaid Claims Database and then Stata .do files to construct the final cohort analytic files.

#### 1a. SQL: Extract Cohorts from Medicaid Claims Database

Run the SQL scripts in `Build/SQL_Files/` against the Louisiana Medicaid claims database. Each script follows a five-step process:

1. Flag all claims with relevant ICD-9 and ICD-10 diagnosis codes
2. Identify qualifying members using disease-specific inclusion criteria
3. Assemble all final adjudicated claims for qualifying members, including comorbidity flags (advanced liver disease, opioid use disorder) and treatment flags (DAA medications)
4. Construct enrollment spells with continuous enrollment periods
5. Build the analytic file (one row per claim, with enrollment months retained for members with no claims)

**Note:** The HIV and diabetes analytic files exclude members who appear in the HCV member list or who have ever filled a DAA prescription.

#### 1b. Stata: Prepare Cohort Files

Export each SQL output table as a `.dta` file and place it in your working directory. Then run the Stata scripts in `Build/Stata_Files/`:

```stata
do hcv_prep_file.do
do hiv_prep_file.do
do diab_prep_file.do
```

Each script processes the corresponding analytic file and produces a clean cohort dataset:

| Script | Input | Output |
|--------|-------|--------|
| `hcv_prep_file.do` | `hcv_analytic.dta` | `hcv_cohort_file.dta` |
| `hiv_prep_file.do` | `hiv_analytic.dta` | `hiv_cohort_file.dta` |
| `diab_prep_file.do` | `diab_analytic.dta` | `diab_cohort_file.dta` |

### Step 2: Configure Paths

Open `Analysis/Stata_Files/master.do` and update the five global path macros at the top of the file to match your local directory structure:

```stata
global orig  "/path/to/data_files/original"   // original cohort files from Build step
global data  "/path/to/data_files/created"     // output directory for analytic files
global code  "/path/to/Analysis/Stata_Files"   // location of all analysis .do files
global fig   "/path/to/figures"                // output directory for figures (.eps)
global tab   "/path/to/tables"                 // output directory for tables (.tex)
```

The file also defines a global `$controls` macro used consistently across all regression specifications:

```stata
global controls i.service_yq i.qtr_since_dx i.qtr_since_enroll ///
                i.female i.age i.race i.parish
```

This includes indicator variables for service quarter, quarters since diagnosis, quarters since Medicaid enrollment, sex, age, race, and parish of residence.

### Step 3: Build Analytic Files and Run Analysis

Run `master.do` from Stata. The script proceeds in three stages:

**Stage 1 — Build person-quarter analytic files.**  
`master.do` reads each cohort file produced in Step 1b and collapses it to a person-quarter panel, saving three analytic datasets to `$data`:

| Input (from Build) | Output (analytic file) | Unit of observation |
|--------------------|------------------------|---------------------|
| `hcv_cohort_file.dta` | `hcv_full.dta` | Person × service quarter |
| `hiv_cohort_file.dta` | `hiv_full.dta` | Person × service quarter |
| `diab_cohort_file.dta` | `diab_full.dta` | Person × service quarter |

**Stage 2 — Generate figures.**  
`master.do` calls each figure script in sequence. All figure scripts read from the analytic files above (with the exception of `figure2.do`, which reads directly from `hcv_cohort_file.dta` to construct spending trajectories at the individual level). Output files are saved as `.eps` to `$fig`.

| Script | Output file(s) | Data inputs |
|--------|---------------|-------------|
| `figure2.do` | `fig_2.eps` | `hcv_cohort_file.dta` |
| `figure3.do` | `fig_3a.eps` – `fig_3d.eps` | `hcv_full.dta`, `diab_full.dta`, `hiv_full.dta` |
| `figure4.do` | `fig_4a.eps`, `fig_4b.eps` | `hcv_full.dta`, `diab_full.dta`, `hiv_full.dta` |
| `app_figure1.do` – `app_figure10.do` | `app_fig_1.eps` – `app_fig_10.eps` | Various |

**Stage 3 — Generate tables.**  
`master.do` calls each table script in sequence. Output files are saved as `.tex` fragments to `$tab`.

| Script | Output file | Data inputs | Notes |
|--------|-------------|-------------|-------|
| `table1.do` | `table1.tex` | `hcv_full.dta`, `diab_full.dta`, `hiv_full.dta` | Summary statistics |
| `table2.do` | `table2.tex` | `hcv_full.dta`, `diab_full.dta`, `hiv_full.dta` | DiD spending estimates; stores scalars used by `table4.do` |
| `table3.do` | `table3.tex` | `hcv_full.dta`, `diab_full.dta`, `hiv_full.dta` | Transmission estimates; stores scalars used by `table4.do` |
| `table4.do` | `table4.tex` | `hcv_full.dta` | Cost-benefit analysis; **must run after** `table2.do` and `table3.do` |
| `table5.do` | `table5.tex` | Various | |
| `app_table2.do` – `app_table3.do` | `app_table2.tex` – `app_table3.tex` | Various | |

> **Important:** `table4.do` depends on regression coefficient scalars set during the execution of `table2.do` (year-specific DiD estimates for diabetes and HIV comparison groups) and `table3.do` (year-specific transmission estimates). These scalars persist in the Stata session and are consumed by `table4.do`. Running `table4.do` in isolation without first running `table2.do` and `table3.do` will produce incorrect results. Always run the full analysis through `master.do`.

---

## Cohort Identification Algorithms

Disease cohorts are identified using validated, claims-based algorithms applied to ICD-9 and ICD-10 diagnosis codes. A member qualifies for each cohort as follows:

**HCV** (Gordon *et al.*, 2012): at least one claim with a chronic HCV diagnosis; OR at least two claims on different service dates with an unspecified HCV or carrier diagnosis; OR at least two claims at least six months apart with an unspecified, carrier, or acute HCV diagnosis.

**HIV** (Pocobelli *et al.*, 2024; Macinski *et al.*, 2020): at least one inpatient claim with an HIV diagnosis; OR at least two outpatient claims on different service dates with an HIV diagnosis.

**Diabetes** (Andes *et al.*, 2019; Sakshaug *et al.*, 2014): at least one inpatient claim with a diabetes diagnosis; OR at least two outpatient claims on different service dates within a two-year window with a diabetes diagnosis.

For each condition, the date of the first qualifying claim is defined as the member's index diagnosis date.

---

## References

Andes, L.J., Li, Y., Srinivasan, M., Benoit, S.R., Gregg, E., and Rolka, D.B. (2019). "Diabetes Prevalence and Incidence among Medicare Beneficiaries-United States, 2001-2015. *MMWR Morb Mortal Wkly Rep*, 68:961-966.

Gordon, S.C., Pockros, P.J., Terrault, N.A., Hoop, R.S., Buikema, A., Nerenz, D., and Hamzeh, F.M. (2012). "Impact of Disease Severity on Healthcare Costs in Patients with Chronic Hepatitis C (CHC) Virus Infection." *Hepatology*, 56:1651-1660.

Macinski, S.E., Gunn, J.K.L., Goyal, M., Neighbors, C., Yerneni, R., and Anderson, B.J. (2020). "Validation of an Optimized Algorithm for Identifying Persons Living with Diagnosed HIV from New York State Medicaid Data, 2006-2014." *American Journal of Epidemiology*, 189(5):470-480.

Pocobelli, G., Oliver, M., Albertson-Junkans, L., Gundersen, G., and Kamineni, A. (2024). "Validation of Human Immunodeficiency Virus Diagnosis Codes among Women Enrollees of a U.S. Health Plan." *BMC Health Services Research*, 24(234).

Sakshaug, J.W., Weir, D.R., Nicholas, L.H. (2014). "Identifying Diabetics in Medicare Claims and Survey Data: Implications for Health Services Research." *BMC Health Services Research*, 14(150). 

---

## Citation

If you use this code, please cite:

```
Callison, K., Conti, R.M., Gruber, J., and Wallace, J. (2026). "Spending to Save:
The Subscription Model for Eradicating Hepatitis C in Louisiana."
```

---

## Contact

Kevin Callison — Tulane University  
kcallison@tulane.edu

---

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.
