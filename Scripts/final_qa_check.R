# Scripts/final_qa_check.R
# Author: Ramya Kotagiri
# Purpose: Final consistency check on cleaned dataset

message("=== final_qa_check.R (Ramya) ===")

cp <- "../data/Bike_Features_clean.csv"
if (!file.exists(cp)) stop("Cleaned file missing. Run clean_eda.R first.")
d <- read.csv(cp, stringsAsFactors = TRUE)

rows <- nrow(d); cols <- ncol(d)
has_body <- "Body.Type" %in% names(d)
levels_count <- if (has_body) length(unique(d$Body.Type)) else NA

# basic sanity: missing summary
miss <- colSums(is.na(d))

if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)
sink("../outputs/final_qa_check.txt")
cat("=== Final QA Check (Ramya) ===\n\n")
cat("Rows:", rows, "  Cols:", cols, "\n")
cat("Has Body.Type column:", has_body, "\n")
if (has_body) cat("Body.Type levels:", levels_count, "\n\n")
cat("Missing values per column:\n")
for (nm in names(miss)) cat(sprintf(" - %s: %d\n", nm, miss[[nm]]))
if (has_body) {
  cat("\nTop Body.Type counts:\n")
  print(head(sort(table(d$Body.Type), decreasing = TRUE), 10))
}
sink()

message("✅ Wrote outputs/final_qa_check.txt")