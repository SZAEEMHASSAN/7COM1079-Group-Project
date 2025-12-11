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