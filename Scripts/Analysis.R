# analysis_anova.R
# Author: Syed Zaeem Hassan
# Purpose: Run one-way ANOVA on bike prices by body type

# 1. Load dataset (go up one folder to 'data/')
bike_data <- read.csv("../data/Bike_Features.csv", stringsAsFactors = TRUE)

# 2. Clean data
bike_clean <- subset(bike_data, !is.na(On.road.prize) & !is.na(Body.Type))
bike_clean$Body.Type <- as.factor(bike_clean$Body.Type)

# 3. Run ANOVA
anova_model <- aov(On.road.prize ~ Body.Type, data = bike_clean)
anova_result <- summary(anova_model)

# 4. Save outputs (go up one folder to root level)
if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)

# Save CSV output
write.csv(anova_result[[1]], "../outputs/anova_summary.csv", row.names = TRUE)

# Save readable text output
sink("../outputs/anova_summary.txt")
cat("=== One-way ANOVA Summary ===\n")
print(anova_result)
sink()

# Optional: category counts table
counts <- table(bike_clean$Body.Type)
write.csv(counts, "../outputs/bodytype_counts.csv", row.names = TRUE)

cat("✅ ANOVA completed successfully! Files saved in ../outputs/\n")
message("=== Analysis.R (ANOVA on cleaned data) ===")

# Load cleaned data
clean_path <- "../data/Bike_Features_clean.csv"
if (!file.exists(clean_path)) stop("Cleaned file missing. Run clean_eda.R first.")
d <- read.csv(clean_path, stringsAsFactors = TRUE)

# Basic ANOVA
fit <- aov(On.road.price ~ Body.Type, data = d)
sm  <- summary(fit)

# Save CSV + TXT summary
if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)
write.csv(sm[[1]], "../outputs/anova_summary.csv", row.names = TRUE)

sink("../outputs/anova_summary.txt")
cat("=== One-way ANOVA (On.road.price ~ Body.Type) ===\n"); print(sm)
sink()