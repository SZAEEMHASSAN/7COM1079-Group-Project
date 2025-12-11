data_path <- "../data/Bike_Features.csv"
if (!file.exists(data_path)) stop("Dataset not found at ../data/Bike_Features.csv")
df <- read.csv(data_path, stringsAsFactors = FALSE)

# Explicit columns (from your CSV):
price_raw <- df[["On.road.prize"]]
body_raw  <- df[["Body.Type"]]
if (is.null(price_raw) || is.null(body_raw)) {
  stop("Required columns not found: On.road.prize and Body.Type")
}

# price -> numeric; body -> character
price <- suppressWarnings(as.numeric(gsub("[^0-9.]", "", as.character(price_raw))))
body  <- trimws(as.character(body_raw))

# basic NA cleanup
price[price == 0] <- NA
body[body %in% c("", "NA", "Yes")] <- NA

dat <- data.frame(price = price, body = body, stringsAsFactors = FALSE)
dat <- dat[!is.na(dat$price) & !is.na(dat$body), , drop = FALSE]

# remove non-body junk
dat <- dat[!grepl("mm", dat$body, ignore.case = TRUE), ]
dat <- dat[!grepl(" L$|Litre|Litres", dat$body, ignore.case = TRUE), ]
dat <- dat[!grepl("Halogen|LED|fork|Suspension|bo\\b", dat$body, ignore.case = TRUE), ]

# merge similar labels (baseline)
merge_one <- function(x, pattern, to) gsub(pattern, to, x, ignore.case = TRUE)
dat$body <- merge_one(dat$body, "Adventure Tourer Bikes, Off Road Bikes", "Adventure Tourer Bikes")
dat$body <- merge_one(dat$body, "Adventure Tourer Bikes, Tourer Bikes, Off Road Bikes", "Adventure Tourer Bikes")
dat$body <- merge_one(dat$body, "Adventure Tourer Bikes, Sports Tourer Bikes", "Adventure Tourer Bikes")
dat$body <- merge_one(dat$body, "Sports Naked Bikes, Sports Bikes", "Sports Naked Bikes")
dat$body <- merge_one(dat$body, "Super Bikes, Sports Bikes", "Super Bikes")
dat$body <- merge_one(dat$body, "Cruiser Bikes, Cafe Racer Bikes", "Cruiser Bikes")
dat$body <- merge_one(dat$body, "Cruiser Bikes, Tourer Bikes", "Cruiser Bikes")
dat$body <- merge_one(dat$body, "Sports Naked Bikes, Cafe Racer Bikes", "Sports Naked Bikes")
dat$body <- merge_one(dat$body, "Adventure Tourer Bikes, Cruiser Bikes, Off Road Bikes", "Adventure Tourer Bikes")
dat <- dat[!grepl("\\+", dat$body), , drop = FALSE]

# ORDER by freq
bt <- sort(table(dat$body), decreasing = TRUE)
dat$body <- factor(dat$body, levels = names(bt))

cat("Counts per body (after clean):\n"); print(sort(table(dat$body), decreasing = TRUE))

# Collapse rare categories to "Other" so the figure doesn't compress.
min_n <- 5
tbl <- sort(table(dat$body), decreasing = TRUE)
keep_lvls <- names(tbl)[tbl >= min_n]

dat_plot <- dat
dat_plot$body <- as.character(dat_plot$body)
dat_plot$body[!dat_plot$body %in% keep_lvls] <- "Other"
dat_plot$body <- factor(dat_plot$body, levels = c(keep_lvls, "Other"))

# short labels for axis
short_labels <- function(lv){
  x <- lv
  x <- gsub("Adventure Tourer.*", "Adventure", x)
  x <- gsub("Sports Naked.*",   "Sports Naked", x)
  x <- gsub("Sports Tourer.*",  "Sports Tourer", x)
  x <- gsub("Super Bikes.*",    "Super Bikes", x)
  x <- gsub("Cafe Racer.*",     "Cafe Racer", x)
  x <- gsub("Cruiser.*",        "Cruiser", x)
  x <- gsub("Commuter.*",       "Commuter", x)
  x <- gsub("Electric.*",       "Electric", x)
  x <- gsub("Moped.*",          "Moped", x)
  x <- gsub("Tourer.*",         "Tourer", x)
  x
}






# valid groups for testing (>=2 obs, variance > 0)
gsize <- tapply(dat$price, dat$body, length)
gvar  <- tapply(dat$price, dat$body, function(x) var(x, na.rm = TRUE))
keep  <- names(gsize)[gsize >= 2 & !is.na(gvar) & gvar > 0]
dat2  <- droplevels(dat[dat$body %in% keep, , drop = FALSE])
k     <- nlevels(dat2$body)

cat("\nValid groups after cleaning:", k, "\n")
if (k < 2) stop("Not enough valid groups left for ANOVA/Welch (need ≥2).")

fit_aov <- aov(price ~ body, data = dat2)
resid_aov <- residuals(fit_aov)
shap <- if (length(resid_aov) >= 3 && length(resid_aov) <= 5000) shapiro.test(resid_aov) else NULL
vars <- tapply(dat2$price, dat2$body, var, na.rm = TRUE)
vr   <- if (length(vars) >= 2) max(vars) / min(vars) else Inf

cat("\n--- Assumption checks ---\n")
if (!is.null(shap)) cat("Shapiro p (residual normality):", signif(shap$p.value, 4), "\n")
cat("Variance ratio (max/min):", if (is.finite(vr)) signif(vr, 4) else "Inf", " (≤4 ≈ OK for ANOVA)\n")

use_anova <- (is.null(shap) || shap$p.value > 0.05) && is.finite(vr) && vr < 4

cat("\n--- Chosen test ---\n")
if (use_anova) {
  cat("Using ONE-WAY ANOVA\n\n")
  s <- summary(fit_aov)
  print(s)
  tab <- s[[1]]
  cat("\nANOVA result: F =", signif(unname(tab$`F value`[1]), 4),
      " p =", signif(unname(tab$`Pr(>F)`[1]), 4), "\n")
} else {
  cat("Using WELCH ANOVA\n\n")
  w <- oneway.test(price ~ body, data = dat2, var.equal = FALSE)
  print(w)
  cat("\nWelch result: F =", signif(unname(w$statistic), 4),
      " df =", signif(unname(w$parameter), 4),
      " p =", signif(unname(w$p.value), 4), "\n")
}

cat("\nINTERPRETATION GUIDE:\n")
cat("- p < 0.05 → Mean price differs significantly across body types.\n")
cat("- p ≥ 0.05 → No strong evidence of a difference in mean price.\n")