
# ==========================================
# FraudShield - Machine Learning Model
# ==========================================

library(dplyr)
library(caret)
library(ranger)
library(pROC)

# 1. Load processed dataset
data <- read.csv("output/processed_transactions.csv")

# 2. Prepare data
data$Class <- factor(
  data$Class,
  levels = c(0, 1),
  labels = c("Legitimate", "Fraud")
)

# Remove Time because it is not needed for this baseline model
data$Time <- NULL

# 3. Split into training and testing data
set.seed(123)

train_index <- createDataPartition(
  data$Class,
  p = 0.8,
  list = FALSE
)

train_data <- data[train_index, ]
test_data <- data[-train_index, ]

cat("Training transactions:", nrow(train_data), "\n")
cat("Testing transactions:", nrow(test_data), "\n")

# 4. Train Random Forest model
cat("\nTraining FraudShield model...\n")

fraud_model <- ranger(
  Class ~ .,
  data = train_data,
  num.trees = 200,
  probability = TRUE,
  importance = "impurity",
  seed = 123
)

cat("Model training completed!\n")

# 5. Predict test transactions
probabilities <- predict(
  fraud_model,
  data = test_data
)$predictions

# Use a lower threshold to help detect rare fraud cases
fraud_probability <- probabilities[, "Fraud"]

predictions <- factor(
  ifelse(fraud_probability >= 0.10, "Fraud", "Legitimate"),
  levels = c("Legitimate", "Fraud")
)

# 6. Evaluate model
confusion <- confusionMatrix(
  data = predictions,
  reference = test_data$Class,
  positive = "Fraud"
)

cat("\nCONFUSION MATRIX\n")
print(confusion$table)

cat("\nMODEL METRICS\n")
print(confusion$byClass[
  c("Sensitivity", "Specificity", "Pos Pred Value", "F1")
])

cat("\nOverall accuracy:",
    round(confusion$overall["Accuracy"] * 100, 2),
    "%\n")

# 7. Calculate ROC-AUC
roc_result <- roc(
  response = test_data$Class,
  predictor = fraud_probability,
  levels = c("Legitimate", "Fraud"),
  quiet = TRUE
)

cat("ROC-AUC:",
    round(as.numeric(auc(roc_result)), 4),
    "\n")

# 8. Save trained model and evaluation results
dir.create("models", showWarnings = FALSE)
dir.create("output", showWarnings = FALSE)

saveRDS(
  fraud_model,
  "models/fraudshield_model.rds"
)

write.csv(
  data.frame(
    Actual = test_data$Class,
    Predicted = predictions,
    Fraud_Probability = fraud_probability
  ),
  "output/model_predictions.csv",
  row.names = FALSE
)

write.csv(
  data.frame(
    Metric = c(
      "Accuracy",
      "Sensitivity",
      "Specificity",
      "Precision",
      "F1 Score",
      "ROC-AUC"
    ),
    Value = c(
      as.numeric(confusion$overall["Accuracy"]),
      as.numeric(confusion$byClass["Sensitivity"]),
      as.numeric(confusion$byClass["Specificity"]),
      as.numeric(confusion$byClass["Pos Pred Value"]),
      as.numeric(confusion$byClass["F1"]),
      as.numeric(auc(roc_result))
    )
  ),
  "output/model_metrics.csv",
  row.names = FALSE
)

cat("\nFraudShield model saved successfully!\n")
cat("Model: models/fraudshield_model.rds\n")
cat("Predictions: output/model_predictions.csv\n")
cat("Metrics: output/model_metrics.csv\n")
