# FraudShield — Intelligent Financial Fraud Detection

## Project Overview
FraudShield is a machine-learning project developed using R to identify potentially fraudulent financial transactions. It uses a Random Forest classification model to distinguish legitimate transactions from fraudulent ones and presents the results through an interactive Shiny dashboard.

## Problem Statement
Financial fraud can cause significant losses, and fraudulent transactions are often hidden among a large number of legitimate transactions. Detecting these rare cases accurately is a major challenge.

## Proposed Solution
FraudShield analyzes transaction data, trains a Random Forest model, evaluates its performance, and displays transaction statistics and prediction results through a web dashboard.

## Technologies Used
- **Language:** R
- **Machine Learning:** Random Forest (`ranger`)
- **Data Processing:** `dplyr`
- **Visualization:** `ggplot2`
- **Web Dashboard:** Shiny
- **Tables:** DT
- **Evaluation:** `caret`, `pROC`

## Features
- Transaction data preprocessing
- Fraud and legitimate transaction analysis
- Random Forest model training
- Fraud prediction and probability estimation
- Model performance evaluation
- Interactive Shiny dashboard
- Exported prediction and metric files

## Model Performance
Initial test results:
- Accuracy: 99.92%
- Fraud recall: 86.73%
- Fraud precision: 71.43%
- ROC-AUC: 0.9664

These results are from the current test split and threshold. Performance may change on other datasets, and the model is intended for educational demonstration rather than real financial decisions.

## Dataset
Credit Card Fraud Detection dataset by Machine Learning Group — ULB.

Dataset: https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud

Download the dataset separately and place `creditcard.csv` inside the `data/` folder before running preprocessing.

## How to Run
1. Install R and RStudio.
2. Install the required packages.
3. Download the dataset into `data/creditcard.csv`.
4. Run `01_data_preprocessing.R`.
5. Run `02_model_training.R`.
6. Run `app.R` to launch the dashboard.

Install packages using:

```r
install.packages(c(
  "dplyr", "ggplot2", "caret", "ranger",
  "pROC", "shiny", "DT"
))
```

## Project Structure
- `01_data_preprocessing.R` — cleans and analyzes the dataset.
- `02_model_training.R` — trains and evaluates the model.
- `app.R` — launches the Shiny dashboard.
- `data/` — downloaded dataset.
- `models/` — saved trained model.
- `output/` — metrics and predictions.
- `screenshots/` — application screenshots.

## Disclaimer
FraudShield is an educational prototype, not a certified financial fraud detection system. It should not be used to approve or reject real transactions without further validation, security controls, and professional review.

## Author
Developed as an R programming and machine-learning portfolio project.

