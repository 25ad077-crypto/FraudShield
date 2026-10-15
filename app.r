
# ==========================================
# FraudShield - Fraud Detection Dashboard
# ==========================================

library(shiny)
library(DT)
library(ggplot2)
library(dplyr)

# Load trained model and saved data
if (!file.exists("models/fraudshield_model.rds")) {
  stop("Model not found. Run 02_model_training.R first.")
}

if (!file.exists("output/model_predictions.csv")) {
  stop("Predictions not found. Run 02_model_training.R first.")
}

model <- readRDS("models/fraudshield_model.rds")
predictions <- read.csv("output/model_predictions.csv")

metrics <- read.csv("output/model_metrics.csv")

# Load original processed dataset for charts
transactions <- read.csv("output/processed_transactions.csv")

# Dashboard UI
ui <- fluidPage(
  
  titlePanel("FraudShield - Intelligent Fraud Detection"),
  
  sidebarLayout(
    
    sidebarPanel(
      h3("Transaction Risk Checker"),
      
      numericInput(
        "amount",
        "Transaction Amount",
        value = 100,
        min = 0
      ),
      
      numericInput(
        "time",
        "Transaction Time (seconds)",
        value = 10000,
        min = 0
      ),
      
      p("Enter a transaction amount and time. This demo uses a sample transaction profile."),
      
      actionButton(
        "check",
        "Check Transaction Risk",
        class = "btn-primary"
      ),
      
      hr(),
      
      h4("About"),
      p("FraudShield uses a Random Forest model to estimate transaction fraud risk.")
    ),
    
    mainPanel(
      tabsetPanel(
        
        tabPanel(
          "Overview",
          
          br(),
          
          fluidRow(
            column(
              4,
              wellPanel(
                h4("Total Transactions"),
                h2(format(nrow(transactions), big.mark = ","))
              )
            ),
            
            column(
              4,
              wellPanel(
                h4("Fraud Cases"),
                h2(sum(transactions$Class == 1))
              )
            ),
            
            column(
              4,
              wellPanel(
                h4("Model Accuracy"),
                h2(paste0(
                  round(
                    metrics$Value[metrics$Metric == "Accuracy"] * 100,
                    2
                  ),
                  "%"
                ))
              )
            )
          ),
          
          h3("Transaction Distribution"),
          
          plotOutput("distribution_plot"),
          
          h3("Fraud Detection Performance"),
          
          plotOutput("metrics_plot")
        ),
        
        tabPanel(
          "Prediction Results",
          
          br(),
          
          DTOutput("prediction_table")
        ),
        
        tabPanel(
          "Risk Checker",
          
          br(),
          
          h3("Risk Assessment"),
          
          verbatimTextOutput("risk_result")
        )
      )
    )
  )
)

# Dashboard server
server <- function(input, output, session) {
  
  output$distribution_plot <- renderPlot({
    
    chart_data <- data.frame(
      Type = c("Legitimate", "Fraudulent"),
      Count = c(
        sum(transactions$Class == 0),
        sum(transactions$Class == 1)
      )
    )
    
    ggplot(
      chart_data,
      aes(x = Type, y = Count, fill = Type)
    ) +
      geom_col() +
      labs(
        title = "Legitimate vs Fraudulent Transactions",
        x = "Transaction Type",
        y = "Number of Transactions"
      ) +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  output$metrics_plot <- renderPlot({
    
    metric_data <- metrics %>%
      filter(Metric %in% c(
        "Accuracy",
        "Sensitivity",
        "Specificity",
        "Precision",
        "F1 Score",
        "ROC-AUC"
      ))
    
    metric_data$Metric <- factor(
      metric_data$Metric,
      levels = metric_data$Metric
    )
    
    ggplot(
      metric_data,
      aes(x = Metric, y = Value * 100)
    ) +
      geom_col(fill = "steelblue") +
      coord_cartesian(ylim = c(0, 100)) +
      labs(
        title = "Model Performance Metrics",
        x = "Metric",
        y = "Score (%)"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(
          angle = 30,
          hjust = 1
        )
      )
  })
  
  output$prediction_table <- renderDT({
    
    datatable(
      head(predictions, 1000),
      options = list(
        pageLength = 10,
        scrollX = TRUE
      ),
      filter = "top"
    )
  })
  
  risk_message <- eventReactive(input$check, {
    
    # A complete prediction needs all model features:
    # V1 through V28, Amount, and Time.
    # Amount and Time alone are not enough.
    paste(
      "Demo limitation:",
      "this model requires V1-V28, Amount, and Time.",
      "The entered amount and time alone cannot produce",
      "a valid model prediction."
    )
  })
  
  output$risk_result <- renderText({
    risk_message()
  })
}

# Run application
shinyApp(ui = ui, server = server)
