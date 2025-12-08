# Scripts/data_summary.R
# Author: Ramya K (rk25acq)
# Purpose: QA summaries and missing-value checks from cleaned dataset

message("=== Data Summary (Ramya QA) ===")

# 1) Paths
clean_path  <- "../data/Bike_Features_clean.csv"
out_missing <- "../outputs/missing_values_ramya.csv"
out_num     <- "../outputs/data_summary_ramya.csv"
out_counts  <- "../outputs/bodytype_counts_ramya.csv"

# 2) Load cleaned data
if (!file.exists(clean_path)) stop("Cleaned file not found! Please run clean_eda.R first.")
data <- read.csv(clean_path, stringsAsFactors = TRUE)

# 3) Missing-value summary
missing_summary <- data.frame(
  Column = names(data),
  Missing_Count   = colSums(is.na(data)),
  Missing_Percent = round(colSums(is.na(data)) / nrow(data) * 100, 2)
)

# 4) Numeric summary (min, mean, max)
num_cols <- sapply(data, is.numeric)
num_summary <- data.frame(
  Column = names(data)[num_cols],
  Min  = sapply(data[, num_cols, drop = FALSE], min,  na.rm = TRUE),
  Mean = sapply(data[, num_cols, drop = FALSE], mean, na.rm = TRUE),
  Max  = sapply(data[, num_cols, drop = FALSE], max,  na.rm = TRUE)
)

# 5) Body-type counts
body_counts <- as.data.frame(table(data$Body.Type))
names(body_counts) <- c("Body.Type", "Count")

# 6) Save outputs
if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)
write.csv(missing_summary, out_missing, row.names = FALSE)
write.csv(num_summary,     out_num,     row.names = FALSE)
write.csv(body_counts,     out_counts,  row.names = FALSE)

cat("✅ QA files written:\n")
cat(" -", out_missing, "\n")
cat(" -", out_num, "\n")
cat(" -", out_counts, "\n")


cp <- "../data/Bike_Features_clean.csv"
if (!file.exists(cp)) stop("Cleaned file missing. Run clean_eda.R first.")
d <- read.csv(cp, stringsAsFactors = TRUE)

if (!dir.exists("../outputs")) dir.create("../outputs", TRUE)
miss <- colSums(is.na(d))
nlev <- if ("Body.Type" %in% names(d)) length(unique(d$Body.Type)) else NA

con <- file("../outputs/qa_report_ramya.txt", "wt", encoding = "UTF-8")
writeLines("QA Report – Cleaned Dataset", con)
writeLines(paste("Rows:", nrow(d), " | Cols:", ncol(d)), con)
writeLines(paste("Unique Body.Type levels:", nlev), con)
writeLines("\nMissing values per column:", con)
for (i in names(miss)) writeLines(sprintf(" - %s: %d", i, miss[[i]]), con)
close(con)