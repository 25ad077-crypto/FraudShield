
# ==========================================
# FraudShield - Data Preprocessing
# ==========================================

library(dplyr)
library(ggplot2)

# 1. Load dataset
if (!file.exists("data/creditcard.csv")) {
  stop("Place creditcard.csv inside the data folder.")
}

data <- read.csv("data/creditcard.csv")

# 2. Display dataset information
cat("FRAUDSHIELD DATA ANALYSIS\n")
cat("========================\n")
cat("Total transactions:", nrow(data), "\n")
cat("Total columns:", ncol(data), "\n\n")

# 3. Check missing values
cat("Missing values:", sum(is.na(data)), "\n")

# Remove incomplete records if any
data <- na.omit(data)

# 4. Check fraud distribution
print(table(data$Class))

fraud_count <- sum(data$Class == 1)
normal_count <- sum(data$Class == 0)

cat("\nLegitimate transactions:", normal_count, "\n")
cat("Fraudulent transactions:", fraud_count, "\n")

fraud_rate <- mean(data$Class == 1) * 100

cat(
  "Fraud percentage:",
  round(fraud_rate, 3),
  "%\n"
)

# 5. Plot transaction distribution
class_data <- data.frame(
  Transaction_Type = c(
    "Legitimate",
    "Fraudulent"
  ),
  Count = c(normal_count, fraud_count)
)

p <- ggplot(
  class_data,
  aes(x = Transaction_Type, y = Count,
      fill = Transaction_Type)
) +
  geom_col() +
  labs(
    title = "FraudShield - Transaction Distribution",
    x = "Transaction Type",
    y = "Number of Transactions"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(p)

# 6. Analyze transaction amounts
amount_summary <- data %>%
  group_by(Class) %>%
  summarise(
    Average_Amount = mean(Amount),
    Median_Amount = median(Amount),
    Transaction_Count = n(),
    .groups = "drop"
  )

print(amount_summary)

# 7. Save processed data
dir.create("output", showWarnings = FALSE)

write.csv(
  data,
  "output/processed_transactions.csv",
  row.names = FALSE
)

write.csv(
  class_data,
  "output/transaction_distribution.csv",
  row.names = FALSE
)

cat("\nPreprocessing completed successfully!\n")
cat("Processed dataset saved in output folder.\n")
