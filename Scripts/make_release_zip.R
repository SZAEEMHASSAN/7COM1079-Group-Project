
# Scripts/make_release_zip.R
if (!dir.exists("../release")) dir.create("../release", recursive = TRUE)
files <- c(
  "../README.md",
  "../Report/Group Project Report.docx",
  "../Report/daily_log.md",
  "../Report/figures",
  "../Scripts",
  "../outputs",
  "../figures",
  "../data/Bike_Features_clean.csv"
)
files <- files[file.exists(files) | dir.exists(files)]
zipfile <- "../release/7COM1079-Group-Project_v1.zip"
if (file.exists(zipfile)) file.remove(zipfile)
utils::zip(zipfile, files)
cat("ZIP written:", zipfile, "\n")

