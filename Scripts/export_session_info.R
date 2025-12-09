# Scripts/export_session_info.R
# Author: Syed Zaeem Hassan
# Purpose: Export R session info for reproducibility

# make sure outputs folder exists
if (!dir.exists("../outputs")) dir.create("../outputs", recursive = TRUE)

# open a file connection
con <- file("../outputs/sessionInfo.txt", "wt", encoding = "UTF-8")

# write session info inside the file
writeLines(c("=== R Session Info ===", ""), con)
capture.output(sessionInfo(), file = con, append = TRUE)

close(con)
message("✅ sessionInfo.txt written with content.")