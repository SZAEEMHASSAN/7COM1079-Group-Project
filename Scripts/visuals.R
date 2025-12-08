# Scripts/Visuals.R
# Author: Fahad Ali
# Purpose: Bar plot — average on-road price by body type

# 1) Load data
bike_data <- read.csv("../data/Bike_Features.csv", stringsAsFactors = TRUE)

# 2) Clean
bike_clean <- subset(bike_data, !is.na(On.road.prize) & !is.na(Body.Type))
bike_clean$Body.Type <- as.factor(bike_clean$Body.Type)

# 3) Summary for plot + appendix
price_summary <- aggregate(On.road.prize ~ Body.Type, data = bike_clean, FUN = mean)

# 4) Ensure folders
if (!dir.exists("../figures")) dir.create("../figures", recursive = TRUE)
if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)

# 5) Save plot
png("../figures/avg_price.png", width = 1000, height = 600)
barplot(price_summary$On.road.prize,
        names.arg = price_summary$Body.Type,
        las = 2,
        main = "Average On-road Price by Body Type",
        xlab = "Body Type",
        ylab = "Average On-road Price (INR)")
dev.off()

# 6) Save table for appendix
write.csv(price_summary, "../outputs/avgSortedPrice.csv", row.names = FALSE)

cat("visualisation done: figures/avg_price.png and outputs/avgSortedPrice.csv\n")

message("=== visuals_enhanced.R ===")
cp <- "../data/Bike_Features_clean.csv"
if (!file.exists(cp)) stop("Cleaned file missing. Run clean_eda.R first.")
d <- read.csv(cp, stringsAsFactors = TRUE)

avg <- aggregate(On.road.price ~ Body.Type, d, mean)
colnames(avg) <- c("Body.Type","AveragePrice")
avg <- avg[order(avg$AveragePrice, decreasing=TRUE), ]

if (!dir.exists("../outputs")) dir.create("../outputs", TRUE)
if (!dir.exists("../figures")) dir.create("../figures", TRUE)
write.csv(avg, "../outputs/avgSortedPrice.csv", row.names = FALSE)

png("../figures/avgSortedPrice.png", width=1300, height=700)
bp <- barplot(avg$AveragePrice, names.arg=avg$Body.Type, las=2,
              main="Average On-road Price by Body Type (sorted)",
              xlab="Body Type", ylab="Average price (INR)", cex.names=0.8)
text(x = bp, y = avg$AveragePrice, labels = round(avg$AveragePrice,0),
     pos = 3, cex = 0.7)
dev.off()

message("saved figures/avg_price_sorted.png and outputs/avg_price_sorted.csv")