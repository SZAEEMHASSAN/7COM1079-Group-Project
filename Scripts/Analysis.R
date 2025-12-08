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

# Mean ± SE by Body.Type
m  <- aggregate(On.road.price ~ Body.Type, d, mean)
n  <- aggregate(On.road.price ~ Body.Type, d, length)
sd <- aggregate(On.road.price ~ Body.Type, d, sd)
colnames(m)  <- c("Body.Type","mean")
colnames(n)  <- c("Body.Type","n")
colnames(sd) <- c("Body.Type","sd")
mm <- merge(merge(m,n,"Body.Type"), sd,"Body.Type")
mm$se <- mm$sd / sqrt(mm$n)
mm <- mm[order(mm$mean, decreasing=TRUE), ]

# Bar plot with error bars
if (!dir.exists("../figures")) dir.create("../figures", recursive = TRUE)
png("../figures/anova_means_se.png", width=1200, height=700)
bp <- barplot(mm$mean, names.arg = mm$Body.Type, las=2,
              main="Mean On-road Price by Body Type (±SE)",
              ylab="Mean price (INR)", cex.names=0.8)
arrows(bp, mm$mean-mm$se, bp, mm$mean+mm$se, angle=90, code=3, length=0.05)
dev.off()

message("✅ ANOVA summary & plot saved.")