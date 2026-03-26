library(shiny)

source("app_inputs.R")
source("app_server.R")

APP_CSS <- "
body, html {
  margin: 0;
  padding: 0;
}

.title-box {
  background: linear-gradient(135deg, #4a6fa5, #166088);
  color: white;
  padding: 25px;
  border-radius: 10px;
  margin: 20px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  text-align: center;
}

.title-box h2 {
  margin: 0;
  font-size: 32px;
  font-weight: 600;
}

.title-box p {
  margin-top: 10px;
  opacity: 0.9;
  font-size: 16px;
}

.container-fluid {
  min-height: calc(100vh - 80px);
}

.app-grid {
  display: grid;
  grid-template-columns: minmax(300px, 1fr) minmax(380px, 1.25fr) minmax(420px, 1.6fr);
  gap: 16px;
  margin: 0 20px;
  align-items: stretch;
}

.app-grid > div {
  min-width: 0;
}

@media (max-width: 1200px) {
  .app-grid {
    grid-template-columns: 1fr;
  }
}

.disclaimer {
  height: 80px;
  position: fixed;
  bottom: 0;
  width: 100%;
  background: #fff3cd;
  border-top: 2px solid #ffc107;
  color: #856404;
  padding: 15px;
  text-align: center;
  font-size: 14px;
  margin: 0;
  left: 0;
}
"

input_panel_style <- paste(
  "border-radius: 10px;",
  "height: min(620px, calc(100vh - 260px));",
  "overflow-y: auto;"
)

results_panel_style <- paste(
  "background-color: #f9f9f9;",
  "border-radius: 10px;",
  "height: min(620px, calc(100vh - 260px));",
  "display: flex;",
  "flex-direction: column;",
  "overflow: hidden;"
)

results_box_style <- paste(
  "background: white;",
  "border-radius: 8px;",
  "padding: 10px;",
  "overflow-y: auto;"
)

ui <- fluidPage(
  tags$head(tags$style(HTML(APP_CSS))),
  div(
    class = "title-box",
    h2("🔬 Cognitive Impairment Screening Assistant"),
    p("Early detection of Cognitive Impairment using laboratory biomarkers")
  ),
  div(
    class = "app-grid",
    div(
      wellPanel(
        style = paste("background-color: #f8f9fa;", input_panel_style),
        demographicInputs()
      )
    ),
    div(
      wellPanel(
        style = paste("background-color: #f0f7ff;", input_panel_style),
        labInputs()
      )
    ),
    div(
      wellPanel(
        style = results_panel_style,
        h4(
          "Results",
          style = "color: #2c3e50; text-align: center; flex: 0 0 auto; margin-bottom: 12px;"
        ),
        div(
          style = "flex: 1 1 auto; min-height: 0; display: flex; flex-direction: column; gap: 12px;",
          div(
            style = "flex: 0 0 180px; display: flex; gap: 12px; min-height: 0;",
            div(
              style = paste("flex: 0 0 42%;", results_box_style),
              uiOutput("risk_area")
            ),
            div(
              style = paste("flex: 1 1 auto;", results_box_style),
              uiOutput("factors_area")
            )
          ),
          div(
            style = "flex: 1 1 auto; min-height: 0;",
            plotOutput("lime_plot", height = "100%")
          )
        )
      )
    )
  ),
  fluidRow(
    column(
      12,
      align = "center",
      actionButton(
        "predict",
        "Generate Results",
        style = paste(
          "background-color: #4a6fa5; color: white; padding: 12px 40px;",
          "font-size: 16px; border-radius: 25px; margin: 10px;"
        )
      )
    )
  ),
  div(
    class = "disclaimer",
    "⚠️ Disclaimer: This tool is for research/screening purposes only. Not for clinical diagnosis.",
    br(),
    "Always consult a healthcare professional for medical advice."
  )
)

shinyApp(ui = ui, server = server)
