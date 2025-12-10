# Scripts/graphs_pack.R
# Author: Syed Zaeem Hassan
# Purpose: Generate all figures robustly (continues even if one plot fails)

message("=== Graphs Pack: generating figures (robust) ===")

# ---- load data safely ----
find_clean <- function() {
  cands <- c("../Data/Bike_Features_clean.csv", "Data/Bike_Features_clean.csv")
  for (p in cands) if (file.exists(p)) return(p)
  stop("Cleaned file not found. Tried:\n", paste(cands, collapse = "\n"))
}
cp <- find_clean()
d  <- read.csv(cp, stringsAsFactors = TRUE)

if (!dir.exists("../figures")) dir.create("../figures", recursive = TRUE)

# ensure columns
if (!("On.road.price" %in% names(d))) stop("Column 'On.road.price' not found in cleaned data.")
if (!("Body.Type" %in% names(d)))   d$Body.Type <- factor("Unknown")

# basic vectors
price_raw <- suppressWarnings(as.numeric(d$On.road.price))
price_ok  <- price_raw[is.finite(price_raw)]
price_pos <- price_raw[is.finite(price_raw) & price_raw > 0]
d_ok      <- subset(d, is.finite(price_raw))
d_pos     <- subset(d, is.finite(price_raw) & price_raw > 0)

# helper to not stop on errors
safely <- function(label, expr) {
  message("-> ", label)
  tryCatch({
    force(expr); message("✅ ", label, " (done)")
  }, error = function(e) {
    message("❌ ", label, " failed: ", e$message)
  })
}

# 1) Histogram (already worked but keep safe)
safely("Histogram",
       {
         png("../figures/hist_price.png", width=1200, height=700)
         hist(price_ok, breaks=30, main="On-road Price – Histogram",
              xlab="Price (INR)", ylab="Frequency")
         dev.off()
       }
)

# 2) Density (needs finite numbers; at least 2 unique values)
safely("Density",
       {
         if (length(unique(price_ok)) < 2) stop("Not enough distinct values for density()")
         png("../figures/density_price.png", width=1200, height=700)
         plot(density(price_ok), main="On-road Price – Density", xlab="Price (INR)")
         rug(price_ok)
         dev.off()
       }
)

# 3) ECDF (finite numbers)
safely("ECDF",
       {
         png("../figures/ecdf_price.png", width=1200, height=700)
         plot(ecdf(price_ok), main="On-road Price – ECDF",
              xlab="Price (INR)", ylab="Cumulative proportion")
         grid()
         dev.off()
       }
)

# 4) Log10 boxplot by Body.Type (needs positive prices)
safely("Log10 Boxplot by Body.Type",
       {
         if (nrow(d_pos) < 2) stop("Need positive prices for log10 boxplot")
         d_pos$On.road.price <- price_pos
         png("../figures/boxlog_price_by_bodytype.png", width=1500, height=900)
         boxplot(log10(On.road.price) ~ Body.Type, data=d_pos, las=2,
                 main="Log10 Price by Body Type", xlab="Body Type", ylab="log10(Price)")
         dev.off()
       }
)

# 5) Sorted average barplot with labels (finite prices)
safely("Sorted Average Barplot",
       {
         dd <- data.frame(Body.Type = d$Body.Type[is.finite(price_raw)],
                          On.road.price = price_ok, stringsAsFactors = TRUE)
         avg <- aggregate(On.road.price ~ Body.Type, dd, mean)
         if (nrow(avg) < 1) stop("No data to aggregate")
         avg <- avg[order(avg$On.road.price, decreasing=TRUE), ]
         png("../figures/avg_price_sorted.png", width=1500, height=900)
         bp <- barplot(avg$On.road.price, names.arg=avg$Body.Type, las=2,
                       main="Average On-road Price by Body Type (sorted)",
                       xlab="Body Type", ylab="Average price (INR)", cex.names=0.8)
         text(bp, avg$On.road.price, labels=round(avg$On.road.price,0), pos=3, cex=0.7)
         dev.off()
       }
)

# 6) Mean ± SE plot (finite prices)
safely("Mean ± SE Plot",
       {
         dd <- data.frame(
           Body.Type     = d$Body.Type[is.finite(price_raw)],
           On.road.price = price_ok,
           stringsAsFactors = TRUE
         )
         
         # Use fully-qualified functions + avoid naming conflicts
         m_df  <- aggregate(On.road.price ~ Body.Type, dd, FUN = base::mean)
         n_df  <- aggregate(On.road.price ~ Body.Type, dd, FUN = base::length)
         sd_df <- aggregate(On.road.price ~ Body.Type, dd, FUN = stats::sd)
         
         if (nrow(m_df) < 1) stop("No groups to plot")
         
         names(m_df)  <- c("Body.Type","mean_val")
         names(n_df)  <- c("Body.Type","n_val")
         names(sd_df) <- c("Body.Type","sd_val")
         
         mm <- merge(merge(m_df, n_df,  by="Body.Type"), sd_df, by="Body.Type")
         mm$se <- mm$sd_val / sqrt(pmax(mm$n_val, 1))
         mm <- mm[order(mm$mean_val, decreasing=TRUE), ]
         
         png("../figures/anova_means_se.png", width=1500, height=900)
         bp <- barplot(mm$mean_val, names.arg=mm$Body.Type, las=2,
                       main="Mean On-road Price by Body Type (±SE)",
                       ylab="Mean price (INR)", cex.names=0.8)
         arrows(bp, mm$mean_val-mm$se, bp, mm$mean_val+mm$se, angle=90, code=3, length=0.05)
         dev.off()
       }
)
message("Graphs Pack finished. Check the messages above for any plot that was skipped.")
