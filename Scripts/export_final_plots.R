# Scripts/export_final_plots.R
dir.create("../Report/figures", showWarnings = FALSE, recursive = TRUE)
plots <- c("../figures/anova_means_se.png",
           "../figures/avg_price_sorted.png",
           "../figures/hist_price.png",
           "../figures/boxlog_price_by_bodytype.png")
kept <- plots[file.exists(plots)]
file.copy(kept, "../Report/figures", overwrite = TRUE)
cat("Copied:", paste(basename(kept), collapse=", "), "\n")
