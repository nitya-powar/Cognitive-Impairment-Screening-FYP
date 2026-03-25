library(shiny)
library(lime)
library(randomForest)
source("app_helpers.R")

model_type.randomForest <- function(x, ...) "classification"
predict_model.randomForest <- function(x, newdata, ...) {
  as.data.frame(predict(x, newdata = newdata, type = "prob"))
}

server <- function(input, output, session) {
  random_forest_model <- readRDS("random_forest_model.rds")
  lime_explainer <- readRDS("lime_explainer_RF.rds")
  
  # state before generating the results -> reactive 
  prediction_state <- reactiveVal(
    list(
      status = "idle",
      risk_percent = NULL,
      risk_level = NULL,
      explanation = NULL
    )
  )
  
  # % risk area
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
  
  # top predictors text area
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
  
  # lime plot area
  output$lime_plot <- renderPlot({
    state <- prediction_state()
    req(identical(state$status, "ready"))
    req(!is.null(state$explanation))
    
    plot_features(state$explanation)
  })
  
  # button event trigger
  observeEvent(input$predict, ignoreInit = TRUE, {
    invalid_features <- find_out_of_range_features(input)

    if (length(invalid_features) > 0) {
      showNotification(
        tagList(
          strong("Please correct the following out-of-range inputs:"),
          tags$ul(lapply(invalid_features, tags$li))
        ),
        type = "error",
        duration = 8,
        closeButton = TRUE
      )
      return()
    }

    feature_order <- names(FEATURE_CASTERS)
    input_data <- build_input_data(input, feature_order)
    
    risk_prob <- predict(random_forest_model, newdata = input_data, type = "prob")[, "MCI"]
    risk_percent <- round(risk_prob * 100, 1)
    explanation <- lime::explain(
      x = input_data,
      explainer = lime_explainer,
      n_features = 8,
      labels = "MCI"
    )
    
    # when this is updated, everything that reads prediction_state runs again
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
