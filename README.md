# 7COM1079 — Group Project  Group B 182
### Analysis of Bike Prices vs Body Type (R)

---

## Overview
This project analyses the relationship between **bike body type** and **on-road price (INR)** using R.

The dataset used is `Bike_Features.csv`, which contains multiple technical and categorical features of bikes such as engine displacement, mileage, and body type.

The main goals are:
1. Clean and prepare the dataset (remove invalid or non-categorical labels).
2. Visualise the price distribution across body types.
3. Perform a **One-Way ANOVA** (or **Welch ANOVA**) to check whether mean prices differ across categories.
4. Export clean visualisations and a reproducible analysis pipeline.

---

## Folder Structure

7COM1079-Group-Project/
│
├── data/
│ └── Bike_Features.csv
│
├── Scripts/
│ └── Analysis.R
│
├── figures/
│ ├── fig_price_by_body.png
│ └── fig_price_hist.png
│
└── docs/
└── README.md
---

## How to Run

### Prerequisites
You need **R (≥4.0)** installed.  
No external libraries are required (uses only base R functions).

### Steps
1. Clone or download the repository.
2. Open RStudio or R console inside the Scripts folder.
3. Run the analysis: ("Analysis.R").
4. The script will:
       - Load and clean data from ../data/Bike_Features.csv
       - Generate and display figures
       - Save all images to ../figures/
       - Print statistical test results in the R console