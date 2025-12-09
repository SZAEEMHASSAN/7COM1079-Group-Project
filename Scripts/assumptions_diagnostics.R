# Scripts/assumptions_diagnostics.R
# Author: Vaibhav Sirigada
# Purpose: Check ANOVA assumptions on cleaned data and compute effect sizes

message("=== assumptions_diagnostics.R (Vaibhav) ===")

cp <- "../data/Bike_Features_clean.csv"
if (!file.exists(cp)) stop("Cleaned file missing. Run clean_eda.R first.")
d <- read.csv(cp, stringsAsFactors = TRUE)

# Keep groups with >= 3 obs for more stable diagnostics
keep <- names(which(table(d$Body.Type) >= 3))
d <- subset(d, Body.Type %in% keep)
d$Body.Type <- droplevels(d$Body.Type)
if (nlevels(d$Body.Type) < 2) stop("Not enough Body.Type groups after filtering (need >= 2 groups).")

# ANOVA and residuals
fit <- aov(On.road.price ~ Body.Type, data = d)
res <- residuals(fit)

# Normality (Shapiro on residuals; with large n it's sensitive, so treat as indicative)
sh <- shapiro.test(res)

# Homogeneity (Levene’s test) — use 'car' if available, otherwise fallback to variance ratio summary
lev_res <- NULL
if (requireNamespace("car", quietly = TRUE)) {
  lev_res <- car::leveneTest(On.road.price ~ Body.Type, data = d)
} else {
  vr <- by(d$On.road.price, d$Body.Type, var, na.rm = TRUE)
  lev_res <- list(note = "Package 'car' not installed; reporting group variances instead.",
                  group_variances = vr)
}

# Effect sizes (eta^2, omega^2)
anova_tab <- summary(fit)[[1]]
SS_between <- anova_tab["Body.Type","Sum Sq"]; SS_within <- anova_tab["Residuals","Sum Sq"]
df_between <- anova_tab["Body.Type","Df"];     df_within <- anova_tab["Residuals","Df"]
eta2   <- SS_between / (SS_between + SS_within)
omega2 <- (SS_between - df_between * (SS_within/df_within)) /
  ((SS_between + SS_within) + (SS_within/df_within))

# Save outputs
if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)
sink("../outputs/assumptions_effectsizes.txt")
cat("=== Assumptions & Effect Sizes (Vaibhav) ===\n\n")
cat("Groups used (>=3 obs):\n", paste(levels(d$Body.Type), collapse=", "), "\n\n")
cat("Shapiro-Wilk on ANOVA residuals:\n"); print(sh); cat("\n")

cat("Levene/homoscedasticity check:\n")
if (inherits(lev_res, "data.frame")) print(lev_res) else print(lev_res)
cat("\n")

cat(sprintf("Effect sizes:\n  Eta^2   = %.4f\n  Omega^2 = %.4f\n", eta2, omega2))
sink()

message("Wrote outputs/assumptions_effectsizes.txt")