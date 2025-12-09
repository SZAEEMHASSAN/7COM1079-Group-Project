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
