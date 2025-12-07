# Scripts/anova_test.R
# Author: Vaibhav Kumar
# Purpose: Welch ANOVA + Games–Howell post-hoc on on-road price by Body.Type
# Run this script from inside the Scripts/ folder

message("=== anova_test.R: start ===")

## 0) Ensure output dirs exist
mk <- function(p) if (!dir.exists(p)) dir.create(p, recursive = TRUE)
mk("../outputs")

## 1) Load dataset
raw_path <- "../data/Bike_Features.csv"
if (!file.exists(raw_path)) stop("Data file not found at: ", raw_path)
bike_data <- read.csv(raw_path, stringsAsFactors = TRUE)

## 2) Minimal cleaning
# Keep rows with both price and body type present
if (!("On.road.prize" %in% names(bike_data))) {
  stop("Expected column 'On.road.prize' not found in data.")
}
if (!("Body.Type" %in% names(bike_data))) {
  stop("Expected column 'Body.Type' not found in data.")
}

bike_clean <- subset(bike_data, !is.na(On.road.prize) & !is.na(Body.Type))
bike_clean$Body.Type <- as.factor(bike_clean$Body.Type)

## 3) Drop categories with < 2 observations (required for ANOVA/Welch)
cnt <- table(bike_clean$Body.Type)
keep_levels <- names(which(cnt >= 2))
bike_clean <- subset(bike_clean, Body.Type %in% keep_levels)
bike_clean$Body.Type <- droplevels(bike_clean$Body.Type)

if (length(levels(bike_clean$Body.Type)) < 2) {
  stop("After filtering, fewer than 2 Body.Type groups remain. Cannot run ANOVA.")
}

## 4) Welch one-way ANOVA (variance not assumed equal)
welch_result <- oneway.test(On.road.prize ~ Body.Type, data = bike_clean, var.equal = FALSE)

## 5) Save Welch summary (human-readable)
sink("../outputs/welch_anova_summary.txt")
cat("=== Welch One-way ANOVA ===\n")
print(welch_result)
cat("\nGroup counts used:\n")
print(table(bike_clean$Body.Type))
sink()

## 6) Save group means (for report)
avg_tbl <- aggregate(On.road.prize ~ Body.Type, data = bike_clean, FUN = mean)
names(avg_tbl) <- c("Body.Type", "Mean_OnRoad_Price")
write.csv(avg_tbl, "../outputs/avg_price_summary_vaibhav.csv", row.names = FALSE)

## 7) Post-hoc: try Games–Howell; if unavailable, fall back to TukeyHSD
use_games_howell <- TRUE
if (!requireNamespace("rstatix", quietly = TRUE)) {
  message("rstatix not found; attempting install...")
  ok <- tryCatch({
    install.packages("rstatix", repos = "https://cloud.r-project.org")
    TRUE
  }, error = function(e) {
    message("Install failed: ", conditionMessage(e))
    FALSE
  })
  if (!ok) use_games_howell <- FALSE
}

if (use_games_howell) {
  suppressPackageStartupMessages(library(rstatix))
  gh <- games_howell_test(bike_clean, On.road.prize ~ Body.Type)
  # Reorder/select useful columns if present
  sel <- intersect(c("group1","group2","estimate","conf.low","conf.high","p.adj","p.adj.signif"), names(gh))
  if (length(sel) > 0) gh <- gh[, sel, drop = FALSE]
  write.csv(gh, "../outputs/games_howell_posthoc.csv", row.names = FALSE)
} else {
  # Classical ANOVA (for Tukey) – note: assumes equal variances
  aov_model <- aov(On.road.prize ~ Body.Type, data = bike_clean)
  tuk <- TukeyHSD(aov_model)
  tk <- as.data.frame(tuk$Body.Type)
  tk$comparison <- rownames(tk)
  tk <- tk[, c("comparison","diff","lwr","upr","p.adj")]
  write.csv(tk, "../outputs/tukey_posthoc_fallback.csv", row.names = FALSE)
}

message("✅ Done: Welch ANOVA + post-hoc. See ../outputs/")