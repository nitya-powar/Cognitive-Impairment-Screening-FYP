library(shiny)
library(lime)
library(randomForest)
source("app_helpers.R")

model_type.randomForest <- function(x, ...) "classification"
predict_model.randomForest <- function(x, newdata, ...) {
  as.data.frame(predict(x, newdata, type = "prob"))
}

server <- function(input, output, session) {
  rf_model <- readRDS("../outputs/models/random_forest_model.rds")
  lime_explainer <- readRDS("../outputs/lime_explainer_RF.rds")
  
  prediction_state <- reactiveVal(
    list(
      status = "idle",
      risk_percent = NULL,
      risk_level = NULL,
      explanation = NULL
    )
  )
  
  output$risk_area <- renderUI({
    state <- prediction_state()
    
    if (!identical(state$status, "ready")) {
      return(NULL)
    }
    
    tagList(
      h3("Risk Assessment", style = "text-align: center; color: #2c3e50;"),
      div(
        style = "text-align: center; font-size: 42px; color: #4a6fa5; font-weight: bold;",
        paste0(state$risk_percent, "%")
      ),
      div(
        style = "text-align: center; font-size: 18px; color: #666; margin-top: 10px;",
        state$risk_level
      )
    )
  })
  
  output$factors_area <- renderUI({
    state <- prediction_state()
    
    if (!identical(state$status, "ready")) {
      return(NULL)
    }
    
    top_explanation <- head(state$explanation, 5)
    
    tagList(
      h4("Top Factors", style = "margin-top: 0; color: #2c3e50;"),
      lapply(seq_len(nrow(top_explanation)), function(i) {
        format_explanation_item(top_explanation[i, , drop = FALSE])
      })
    )
  })
  
  output$lime_plot <- renderPlot({
    state <- prediction_state()
    req(identical(state$status, "ready"))
    req(!is.null(state$explanation))
    
    plot_features(state$explanation)
  })
  
  observeEvent(input$predict, ignoreInit = TRUE, {
    feature_order <- names(FEATURE_CASTERS)
    input_data <- build_input_data(input, feature_order)
    
    risk_prob <- predict(rf_model, input_data, type = "prob")[, "MCI"]
    risk_percent <- round(risk_prob * 100, 1)
    explanation <- lime::explain(
      x = input_data,
      explainer = lime_explainer,
      n_features = 8,
      n_labels = 1
    )
    
    prediction_state(
      list(
        status = "ready",
        risk_percent = risk_percent,
        risk_level = get_risk_level(risk_percent),
        explanation = explanation
      )
    )
  })
}
