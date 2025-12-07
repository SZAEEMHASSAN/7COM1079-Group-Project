# Scripts/clean_eda.R
# Author: Fahad Ali
# Purpose: Clean dataset and create basic EDA outputs (Day 2)

message("=== Data Cleaning (Fahad Ali – Day 2) ===")

# 1) Load raw dataset
raw <- "../data/Bike_Features.csv"
if (!file.exists(raw)) stop("Raw dataset not found at: ", raw)
dat <- read.csv(raw, stringsAsFactors = FALSE, check.names = FALSE)

# 2) Normalise column names
std <- function(x) {
  x <- tolower(trimws(x))
  x <- gsub("[^a-z0-9]+", ".", x)
  x <- gsub("\\.+", ".", x)
  x <- gsub("^\\.|\\.$", "", x)
  x
}
std_names <- std(names(dat))
names(dat) <- std_names  # keep standardized names for matching

# 3) Detect price/body columns (robust; handles 'prize' typo)
price_col <- if ("on.road.price" %in% names(dat)) "on.road.price" else
  if ("on.road.prize" %in% names(dat)) "on.road.prize" else
    grep("on.*road.*pri[cz]e|^pri[cz]e$|amount|cost", names(dat), value = TRUE)[1]

body_col  <- if ("body.type" %in% names(dat)) "body.type" else
  grep("^body.*type$|^bodytype$|^type$", names(dat), value = TRUE)[1]

if (is.na(price_col) || is.na(body_col)) {
  stop("Could not find required columns. Need price (e.g., 'On road price/prize') and body type.")
}

# 4) Coerce + filter rows
dat[[price_col]] <- suppressWarnings(as.numeric(dat[[price_col]]))
keep <- !is.na(dat[[price_col]]) &
  !is.na(dat[[body_col]]) &
  nzchar(trimws(dat[[body_col]])) &
  tolower(trimws(dat[[body_col]])) != "yes"

clean <- data.frame(
  On.road.price = dat[[price_col]][keep],
  Body.Type     = as.factor(dat[[body_col]][keep])
)

# 5) Ensure folders
mk <- function(p) if (!dir.exists(p)) dir.create(p, recursive = TRUE)
mk("../data"); mk("../figures"); mk("../outputs")

# 6) Save cleaned CSV
write.csv(clean, "../data/Bike_Features_clean.csv", row.names = FALSE)

# 7) Plots
png("../figures/hist_price.png", width = 1000, height = 600)
hist(clean$On.road.price, breaks = 30,
     main = "Histogram: On-road Price", xlab = "On-road Price (INR)")
dev.off()

png("../figures/boxlog_price_by_bodytype.png", width = 1200, height = 800)
boxplot(log10(On.road.price) ~ Body.Type, data = clean, las = 2,
        main = "Log10 On-road Price by Body Type",
        xlab  = "Body Type", ylab = "log10(Price)")
dev.off()

# 8) Counts for appendix
cnt <- as.data.frame(table(clean$Body.Type))
names(cnt) <- c("Body.Type", "Count")
write.csv(cnt, "../outputs/bodytype_counts_clean.csv", row.names = FALSE)

cat("✅ Clean CSV: ../data/Bike_Features_clean.csv\n")
cat("✅ Figures : ../figures/hist_price.png, ../figures/boxlog_price_by_bodytype.png\n")
cat("✅ Counts  : ../outputs/bodytype_counts_clean.csv\n")
