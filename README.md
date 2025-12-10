# 7COM1079-Group-Project
# Bike Features Analysis

This project explores how different bike body types affect prices
using R programming (cleaning, visualisation, and ANOVA testing).

## How to reproduce
1. Run `scripts/analysis.R`
2. Figures will be saved in the `fig/` folder.
3. Report is in `report/Group_Project_Report.docx`.

## Contributors
- Syed Zaeem Hassan
- Fahad Ali
- Vaibhav Sirigada
- Ramya Kotagiri


## How to Run the Project
1. Open the project in RStudio.  
2. Set the working directory to `Scripts/`.  
3. Run the command:
   ```r
   source("run_all.R")

## Statistical Assumptions (ANOVA)

We validated assumptions on the cleaned dataset: residual normality (Shapiro–Wilk),
homogeneity of variances (Levene’s test), and reported effect sizes (eta², ω²).
See `outputs/assumptions_effectsizes.txt` for details.

## QA Summary
Final QA check and consistency summary written.

## Results (Summary)
- One-way ANOVA shows price differs by Body.Type (see `outputs/anova_summary.txt`).
- Post-hoc comparisons reported in `outputs/games_howell_posthoc.csv`.
- Effect sizes & assumptions: `outputs/assumptions_effectsizes.txt`.
- Key figures: see `Report/figures/`.

# Statistical Interpretation (Summary)

ANOVA indicates significant differences in on-road price across **Body Type** categories.
Post-hoc (Games-Howell) results show which pairs differ most — see  
`outputs/posthoc_top10.csv` for exact comparisons.

Effect sizes (η² and ω²) suggest the magnitude of variation between groups.
Together, these confirm that bike body type meaningfully influences pricing.


# Submission Checklist – Ramya
Cleaned dataset present → `data/Bike_Features_clean.csv`  
ANOVA + post-hoc + effect sizes outputs verified → `outputs/`  
QA summaries regenerated → `outputs/missing_values_ramya.csv`, `outputs/final_qa_check.txt`  
All figures copied to `Report/figures/`  
README and report updated  
Final ZIP created in `release/`  

All project files verified and synced for submission.