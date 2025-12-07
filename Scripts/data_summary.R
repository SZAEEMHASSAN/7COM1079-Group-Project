# Scripts/data_summary_ramya.R
# Author: Ramya K (rk25acq)
# Purpose: Generate dataset QA summary and missing value report

message("=== Data Summary by Ramya (QA Check) ===")

# 1) Load cleaned dataset
clean_path <- "../data/Bike_Features_clean.csv"
if (!file.exists(clean_path)) stop("Cleaned file not found! Please run clean_eda.R first.")
data <- read.csv(clean_path, stringsAsFactors = TRUE)

# 2) Check missing values
missing_summary <- data.frame(
  Column = names(data),
  Missing_Count = colSums(is.na(data)),
  Missing_Percent = round(colSums(is.na(data)) / nrow(data) * 100, 2)
)

# 3) Summary stats for numeric columns
num_cols <- sapply(data, is.numeric)
num_summary <- data.frame(
  Column = names(data)[num_cols],
  Min  = sapply(data[, num_cols, drop = FALSE], min,  na.rm = TRUE),
  Mean = sapply(data[, num_cols, drop = FALSE], mean, na.rm = TRUE),
  Max  = sapply(data[, num_cols, drop = FALSE], max,  na.rm = TRUE)
)

# 4) Category counts for Body.Type
body_counts <- as.data.frame(table(data$Body.Type))
names(body_counts) <- c("Body.Type", "Count")

# 5) Ensure outputs folder
if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)

# 6) Save results
write.csv(missing_summary, "../outputs/missing_values_ramya.csv", row.names = FALSE)
write.csv(num_summary,     "../outputs/data_summary_ramya.csv", row.names = FALSE)
write.csv(body_counts,     "../outputs/bodytype_counts_ramya.csv", row.names = FALSE)

cat("A summaries created:\n")
cat(" - missing_values_ramya.csv\n - data_summary_ramya.csv\n - bodytype_counts_ramya.csv\n")
