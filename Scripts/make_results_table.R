# Scripts/make_results_table.R
# Author: Vaibhav
# Purpose: Combine ANOVA results, effect sizes, and top post-hoc pairs

message("=== make_results_table.R (Vaibhav – Day 5) ===")

if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)

res <- data.frame(kind = character(), metric = character(), value = numeric(), stringsAsFactors = FALSE)

# --- helper to safely pick a column by regex, first match ---
pick_col <- function(df, patterns) {
  for (pat in patterns) {
    hit <- grep(pat, names(df), ignore.case = FALSE, perl = TRUE, value = TRUE)
    if (length(hit) > 0) return(hit[1])
  }
  return(NA_character_)
}

# --- ANOVA summary (handles both 'Pr(>F)' and 'Pr..F.')
if (file.exists("../outputs/anova_summary.csv")) {
  a <- read.csv("../outputs/anova_summary.csv", check.names = FALSE)
  
  f_col <- pick_col(a, c("^F value$", "^F.value$", "^F$"))
  p_col <- pick_col(a, c("^Pr\\(>F\\)$", "^Pr\\.\\.F\\.$", "^Pr.*F.*$"))
  
  Fv <- if (!is.na(f_col)) suppressWarnings(as.numeric(a[[f_col]][1])) else NA_real_
  Pv <- if (!is.na(p_col)) suppressWarnings(as.numeric(a[[p_col]][1])) else NA_real_
  
  if (is.finite(Fv)) {
    res <- rbind(res, data.frame(kind = "ANOVA", metric = "F", value = Fv))
  }
  if (is.finite(Pv)) {
    res <- rbind(res, data.frame(kind = "ANOVA", metric = "p", value = Pv))
  }
}

# --- Effect sizes (eta² / ω²) parsed from text
if (file.exists("../outputs/assumptions_effectsizes.txt")) {
  txt <- readLines("../outputs/assumptions_effectsizes.txt", warn = FALSE)
  grab_num <- function(pat) {
    i <- grep(pat, txt, perl = TRUE)
    if (length(i)) {
      x <- sub(".*?([-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?)\\s*$", "\\1", txt[i[1]])
      suppressWarnings(as.numeric(x))
    } else NA_real_
  }
  eta2   <- grab_num("^\\s*(Eta\\^2|η\\^?2)")
  omega2 <- grab_num("^\\s*(Omega\\^2|Ω\\^?2|omega\\^?2)")
  
  if (is.finite(eta2))   res <- rbind(res, data.frame(kind="EffectSize", metric="eta2",   value=eta2))
  if (is.finite(omega2)) res <- rbind(res, data.frame(kind="EffectSize", metric="omega2", value=omega2))
}

# --- Top 10 post-hoc (Games–Howell), robust to column naming
if (file.exists("../outputs/games_howell_posthoc.csv")) {
  gh <- read.csv("../outputs/games_howell_posthoc.csv", check.names = TRUE)
  # try common p columns
  pcol <- pick_col(gh, c("^p\\.adj$", "^p\\.adj\\.sig.*$", "^p$", "^p\\.value$"))
  if (!is.na(pcol)) {
    gh <- gh[order(gh[[pcol]]), , drop = FALSE]
    top <- head(gh, 10)
    write.csv(top, "../outputs/posthoc_top10.csv", row.names = FALSE)
  }
}

# --- Write consolidated table
write.csv(res, "../outputs/final_results_table.csv", row.names = FALSE)
message("Wrote outputs/final_results_table.csv and outputs/posthoc_top10.csv (if available)")
