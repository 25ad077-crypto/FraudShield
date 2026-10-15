packages <- c(
  "dplyr",
  "ggplot2",
  "caret",
  "ranger",
  "pROC",
  "shiny",
  "DT"
)

missing <- packages[
  !packages %in% rownames(installed.packages())
]

if (length(missing) > 0) {
  install.packages(missing)
}

cat("All required packages are installed.\n")
