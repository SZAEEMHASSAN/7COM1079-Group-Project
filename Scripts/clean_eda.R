# Scripts/clean_eda.R
# Author: Fahad Ali
# Purpose: Clean dataset and create basic EDA outputs for Bike project
# Run this script from inside the Scripts/ folder

message("=== Data Cleaning (dataset-specific) ===")

# 1) Paths
raw_path <- "../data/Bike_Features.csv"
out_clean <- "../data/Bike_Features_clean.csv"
out_hist  <- "../figures/hist_price.png"
out_box   <- "../figures/boxlog_price_by_bodytype.png"
out_cnts  <- "../outputs/bodytype_counts_clean.csv"

# 2) Helpers
std <- function(x) {
  x <- tolower(trimws(x))
  x <- gsub("[^a-z0-9]+", ".", x)
  x <- gsub("\\.+", ".", x)
  x <- gsub("^\\.|\\.$", "", x)
  x
}
mk <- function(p) if (!dir.exists(p)) dir.create(p, recursive = TRUE)

# 3) Load raw
if (!file.exists(raw_path)) stop("Raw dataset not found: ", raw_path)
dat <- read.csv(raw_path, stringsAsFactors = FALSE, check.names = FALSE)

# Standardize headers to safe names:
# "On-road prize" -> "on.road.prize", "Body Type" -> "body.type"
names(dat) <- std(names(dat))

# 4) Explicitly pick the real columns from your CSV
price_col <- "on.road.prize"   # <-- from your file
body_col  <- "body.type"       # <-- from your file
if (!(price_col %in% names(dat))) stop("Price column not found: ", price_col)
if (!(body_col  %in% names(dat))) stop("Body.Type column not found: ", body_col)

# 5) Build minimal frame
price <- suppressWarnings(as.numeric(dat[[price_col]]))
body  <- as.character(dat[[body_col]])

df <- data.frame(
  On.road.price = price,
  Body.Type     = body,
  stringsAsFactors = FALSE
)

# 6) Keep only valid rows:
#    - price present
#    - Body.Type non-empty
#    - Body.Type MUST contain the word 'Bike' or 'Bikes'
has_bikes <- grepl("\\bBikes?\\b", df$Body.Type, ignore.case = TRUE)
keep <- !is.na(df$On.road.price) &
  !is.na(df$Body.Type) &
  nzchar(trimws(df$Body.Type)) &
  has_bikes

clean <- df[keep, , drop = FALSE]
clean$Body.Type <- as.factor(clean$Body.Type)

# 7) Ensure output folders exist
mk("../data"); mk("../figures"); mk("../outputs")

# 8) Save cleaned CSV
write.csv(clean, out_clean, row.names = FALSE)

# 9) Figures
png(out_hist, width = 1000, height = 600)
hist(clean$On.road.price, breaks = 30,
     main = "Histogram: On-road Price",
     xlab = "On-road Price (INR)")
dev.off()

png(out_box, width = 1200, height = 800)
boxplot(log10(On.road.price) ~ Body.Type, data = clean, las = 2,
        main = "Log10 On-road Price by Body Type",
        xlab  = "Body Type", ylab = "log10(Price)")
dev.off()

# 10) Counts for appendix
cnts <- as.data.frame(table(clean$Body.Type))
names(cnts) <- c("Body.Type", "Count")
write.csv(cnts, out_cnts, row.names = FALSE)

cat("Clean CSV:", out_clean, "\n")
cat("Figures :", out_hist, "and", out_box, "\n")
cat("Counts  :", out_cnts, "\n")


# Create a data dictionary from cleaned data
if (exists("clean")) {
  dict <- data.frame(
    Column  = names(clean),
    Type    = sapply(clean, function(x) class(x)[1]),
    Example = sapply(clean, function(x) {
      v <- na.omit(x)
      if (length(v)) as.character(v[1]) else ""
    }),
    stringsAsFactors = FALSE
  )
  
  if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)
  write.csv(dict, "../outputs/data_dictionary.csv", row.names = FALSE)
  message("Data dictionary saved as outputs/data_dictionary.csv")
} else {
  warning("clean object not found — please run earlier cleaning steps first.")
}