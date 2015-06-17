## Notes on Shiny:
## 1.) ui.R is the UI for the app. 
## 2.) server.R is the logic for the app
## 3.) Any time you see "input$..." it is referencing a variable inputted by the user on in the UI
## 4.) Likewise, "output$..." is preparing an output to be displayed in the UI. However, in the UI, 
##     it will be reffered to by a "renderSomething" function, with "outputVariableName" as an argument.
## 5.) Reactive expressions, which are used heavily in this app, automatically update when a relevant input
##     variable is changed.

shinyUI(
  ## For the nav bar at the top
  navbarPage(title="EP Forecasting Tool",
             inverse=TRUE, collapsible=TRUE,
             windowTitle="EP Forecasting Tool",
             tabPanel("Inputs",
                      fluidPage(
                        
                        ##### Head of page #####
                        tags$head(
                          ##### CSS For The App #####
                          tags$style(
                            HTML("
                                 
                                 body {
                                 padding-top:25px;
                                 }
                                 hr { 
                                 display: block;
                                 margin-top: 0.5em;
                                 margin-bottom: 0.5em;
                                 margin-left: 0;
                                 margin-right:0;
                                 border-style: inset;
                                 border-color: black;
                                 border-width: 1px;
                                 }
                                 
                                 #inputDashboard {
                                 background-color: #CDDEFF;
                                 border: 2px solid #000099;
                                 border-radius: 25px; 
                                 font-family: proxima-nova-1,proxima-nova-2,Lato,sans-serif;
                                 }
                                 .number  {
                                 font-size: 20px;
                                 font-family: times;
                                 }
                                .leftBox {
                                border-right: 12px;
                                border-color: black;
                                }
                                 ")
                          )
                        ),
                        
                        ###### Page 1: Input ########
                        
                        ## Section 1
                        fluidRow(
                          column(4),
                          column(4,
                                 ## Title
                                 div(tags$u(h1("EP Forecasting Tool"), align="center", float="left", width=8)),
                                 div(
                                   h3("1.) Select the File Containing Your Historical Data"),
                                   br(),
                                   strong("Note: "),
                                   span("Your data must meet the following criteria in order for this tool to work:"),
                                   br(),
                                   tags$ul(
                                     tags$li("In a CSV file"),
                                     tags$li("You must have at least 1 year of historical data"),
                                     tags$li("The data should be for regular, consistant time intervals (i.e. days, months, quarters, etc.)"),
                                     tags$li("The first column of your data should be your period labels (i.e. 'Q1 2015')"),
                                     tags$li("The second column should contain the historical values for the variable to be forecasted"),
                                     align="left"
                                   ),
                                   br())
                          ),
                          column(4)
                        ),
                        ## The Button to Upload a File
                        fluidRow(
                          column(4),
                          column(4,
                                 fileInput("inputFile", label = h4("Select your file:")),
                                 br(),
                                 hr(),
                                 align="center"
                          ),
                          column(4)
                        ),
                        
                        br(),
                        ## Section 2
                        fluidRow(
                          column(4),
                          column(4,
                                 h2("2.) Select which types of forecasting you would like to run:"),
                                 br(),
                                 p("For more details on each of them, check out the Methodology page."),
                                 br()
                          ),
                          column(4)
                        ),
                        fluidRow(
                          column(4),
                          column(2,
                                 ## ARIMA Checkbox
                                 checkboxInput("doArima", label = "ARIMA", value = FALSE),
                                 br(),
                                 ## Holt-Winters Chechbox
                                 checkboxInput("doHW", label = "Holt-Winters Exponential Smoothing", value = FALSE),
                                 br()
                          ),
                          column(2,
                                 ## Holt Checkbox
                                 checkboxInput("doHolt", label = "Holt's Exponential Smoothing", value = FALSE),
                                 br(),
                                 ## CAGR Checkbox
                                 checkboxInput("doCAGR", label = "Compound Annual Growth Rate (CAGR)", value = FALSE),
                                 br()
                          ),
                          column(4)
                        ),
                        
                        ## A horizontal line
                        fluidRow(
                          column(4),
                          column(4, 
                                 hr()
                          ),
                          column(4)
                        ),
                        
                        br(),            
                        
                        ## Section 3
                        fluidRow(
                          column(4),
                          column(4,
                                 h2("3.) This program's like your mother. It wants to know all the details..."),
                                 br()
                          ), 
                          column(4)
                        ),
                        
                        fluidRow(
                          column(5),
                          column(2,
                                 ## Time series frequency button: The id# equals the number of periods per year
                                 radioButtons("frequency", 
                                              label = span("What is the frequency of your data?"),
                                              choices = list("Annual" = 1,
                                                             "Quarterly" = 4, 
                                                             "Monthly" = 12,
                                                             "Daily" = 365),
                                              selected = 4),
                                 br()
                          ),
                          column(5)
                        ),
                        fluidRow(
                          column(4),
                          column(2,
                                 ## When is the start of the historical data
                                 numericInput("startYear", 
                                              label = span("In what year does the historical data start?"), 
                                              value = 2014),
                                 br(),
                                 numericInput("startTime",
                                              label = span("In which period (quarter, month, etc.) does the historical data start? (Select 1 for annual data)"),
                                              value = 1),
                                 br()
                          ),
                          column(2,
                                 ## When is the end of the historical data
                                 numericInput("endYear",
                                              label = span("In what year does the historical data end?"),
                                              value = 2015),
                                 br(),
                                 numericInput("endTime", 
                                              label = span("In which period does the historical data end? (Select 1 for annual data)"),
                                              value = 4),
                                 br()
                                 
                          ),
                          column(4)
                        ),
                        ## A horizontal line
                        fluidRow(
                          column(4),
                          column(4, 
                                 hr()
                          ),
                          column(4)
                        ),
                        br(),
                        
                        ## Section 4
                        fluidRow(
                          column(4),
                          column(4,
                                 h2("4.) Last questions..."),
                                 br()
                          ),
                          column(4)
                        ),
                        
                        fluidRow(
                          column(4),
                          column(4,
                                 fluidRow(
                                   column(6,
                                          textInput("confidence1", label = span("Confidence Level to Predect At:"), 
                                                    value = "80"),
                                          align="center"
                                   ),
                                   column(6,
                                          ## Number of periods to forecast
                                          numericInput("forecast_periods",
                                                       label = span("Number of periods to forecast:"),
                                                       value = 12),
                                          align="center"
                                   )
                                 ),
                                 fluidRow(
                                   column(6,
                                          textInput("confidence2", label = span("Second Confidence Level To Predict At:"), 
                                                    value = "95"),
                                          align="center"
                                   ),
                                   column(6,
                                          ## Name of output file
                                          textInput("outputName", label = span("Name your output file (no file extension):"), 
                                                    value = "Enter text..."),
                                          align="center"
                                   )
                                 )
                          ),
                          column(4)
                        ),
                        fluidRow(
                          column(5),
                          column(2,
                                 submitButton("Let's Forecast!"),
                                 br(),
                                 align="center"
                          ),
                          column(5)
                        ),
                        
                        br(),
                        ## The status report
                        fluidRow(
                          column(4),
                          column(4,
                                 verbatimTextOutput("statusReport"),
                                 br()
                          ),
                          column(4)
                        )
                      )       
             ),
             
             ##### Page 2: Outputs ######
             tabPanel("Outputs",
                      fluidPage(
                        ## Top Row
                        fluidRow(
                          ## Top left quadrant: Displays ARIMA plot
                          column(6,
                                 plotOutput("arimaPlot"),
                                 br(),
                                 fluidRow(
                                   column(8,
                                          fluidRow(
                                            h4("ARIMA Model Orders"),
                                            helpText("For these to take effect, you must uncheck the box to have R estimate the orders."),
                                            column(6,
                                                   h5("Non-Seasonal:"),
                                                   selectInput("arimap", label = span("Order of autoregressive part:"), 
                                                               choices = list("0" = 0,
                                                                              "1" = 1,
                                                                              "2" = 2,
                                                                              "3" = 3),
                                                               selected = 0),
                                                   selectInput("arimad", label = span("Degree of first differencing:"), 
                                                               choices = list("0" = 0,
                                                                              "1" = 1,
                                                                              "2" = 2),
                                                               selected = 0),
                                                   selectInput("arimaq", label = span("Order of moving average part:"), 
                                                               choices = list("0" = 0,
                                                                              "1" = 1,
                                                                              "2" = 2,
                                                                              "3" = 3),
                                                               selected = 0),
                                                   align="center"
                                            ),
                                            column(6,
                                                   h5("Seasonal:"),
                                                   selectInput("arimaP", label = span("Order of autoregressive part:"), 
                                                               choices = list("0" = 0,
                                                                              "1" = 1,
                                                                              "2" = 2,
                                                                              "3" = 3),
                                                               selected = 0),
                                                   selectInput("arimaD", label = span("Degree of seasonal differencing:"), 
                                                               choices = list("0" = 0,
                                                                              "1" = 1,
                                                                              "2" = 2),
                                                               selected = 0),
                                                   selectInput("arimaQ", label = span("Order of moving average part:"), 
                                                               choices = list("0" = 0,
                                                                              "1" = 1,
                                                                              "2" = 2,
                                                                              "3" = 3),
                                                               selected = 0),
                                                   align="center"
                                            )
                                          ),
                                          align="center"
                                   ),
                                   column(4,
                                          checkboxInput("arimaAuto",
                                                        label= span("Let R estimate the best orders (recommended, overrides the above inputs)"),
                                                        value=TRUE),
                                          submitButton("Update Models"),
                                          br(),
                                          p("AIC (measures model quality - lower is better) : ", textOutput("arimaAIC"))
                                   )
                                 ),
                                 align="center",
                                 style="border-right-style: solid; border-right-color: #000000"
                          ),
                          ## Top right quadrant: Displays Holt Plot
                          column(5,
                                 plotOutput("holtPlot"),
                                 br(),
                                 fluidRow(
                                   column(1),
                                   column(5,
                                          h4("Smoothing Parameters:"),
                                          helpText("Note: Trend cannot be greater than Level. Must uncheck box for R to estimate the parameters for these to take effect."),
                                          sliderInput("holtAlpha",
                                                      label ="Level (Alpha)", 
                                                      min = 0,
                                                      max = 1,
                                                      value = 0,
                                                      step= 0.05
                                          ),
                                          sliderInput("holtBeta",
                                                      label ="Trend (Beta)", 
                                                      min = 0,
                                                      max = 1,
                                                      value = 0,
                                                      step= 0.05
                                          ),
                                          checkboxInput("holtExp",
                                                        label="Fit exponential trend instead of linear?",
                                                        value=FALSE),
                                          checkboxInput("holtDamp",
                                                        label="Dampen the model?",
                                                        value=TRUE),
                                          align ="center"
                                   ),
                                   column(5,
                                          checkboxInput("holtAuto",
                                                        label= span("Let R estimate the best parameters (recommended, overrides custom inputs)"),
                                                        value=TRUE),
                                          br(),
                                          submitButton("Update Models"),
                                          br(),
                                          p("AIC (measures model quality - lower is better) : ", textOutput("holtAIC")),
                                          align="center"
                                   ),
                                   column(1)
                                 ),
                                 align="center"
                          )
                          
                        ),
                        ## Horizontal line bisecting page
                        hr(),
                        ## Second row
                        fluidRow(
                          ## Bottom left quadrant: Displays Holt-Winters Plot
                          column(6,
                                 br(),
                                 plotOutput("hwPlot"),
                                 br(),
                                 fluidRow(
                                   column(1),
                                   column(5,
                                          h4("Smoothing Parameters:"),
                                          helpText("Note: Trend cannot be greater than Level. Must uncheck box for R to estimate the parameters for these to take effect."),
                                          sliderInput("hwAlpha",
                                                      label ="Level (Alpha)", 
                                                      min = 0,
                                                      max = 1,
                                                      value = 0,
                                                      step= 0.05
                                          ),
                                          sliderInput("hwBeta",
                                                      label ="Trend (Beta)", 
                                                      min = 0,
                                                      max = 1,
                                                      value = 0,
                                                      step= 0.05
                                          ),
                                          sliderInput("hwGamma",
                                                      label ="Seasonality (Gamma)", 
                                                      min = 0,
                                                      max = 1,
                                                      value = 0,
                                                      step= 0.05
                                          ),
                                          selectInput("hwseasonal", label="Additive or multiplicative?",choices=list("Additive" = 1, "Multiplicative" = 2), selected=1),
                                          checkboxInput("hwDamp",
                                                        label="Dampen the model?",
                                                        value=TRUE),
                                          align ="center"
                                   ),
                                   column(5,
                                          checkboxInput("hwAuto",
                                                        label= span("Let R estimate the best parameters (recommended, overrides custom inputs)"),
                                                        value=TRUE),
                                          br(),
                                          submitButton("Update Models"),
                                          br(),
                                          p("AIC (measures model quality - lower is better) : ", textOutput("hwAIC")),
                                          align="center"
                                   ),
                                   column(1)
                                 ),
                                 align="center",
                                 style="border-right-style: solid; border-right-color: #000000"
                          ),
                          ## Bottom right quadrant: displays CAGR plot
                          column(6,
                                 br(),
                                 plotOutput("cagrPlot"),
                                 br(),
                                 p("CAGR: ", textOutput("CAGR")),
                                 align="center"
                          )
                        ),
                        ## Bottom section of page
                        fluidRow(
                          br(),
                          h4("For more information on each of the methods, see the \"Methodology\" tab."),
                          br(),
                          h5(tags$b(tags$u("Note:")), " As a rule of thumb, remember that the model with the lowest AIC is usually the best model, statistically."),
                          align="center"
                        ),
                        fluidRow(
                          br(),
                          ## The download button
                          downloadButton('downloadData', 'Download Data From Graphs'),
                          br(),
                          br(),
                          br(),
                          align="center"
                        )
                      )
             ),
             
             ###### Page 3: Methodology #####
             tabPanel("Methodology",
                      fluidPage(
                        fluidRow(
                          br(),
                          ## Page Title/Header
                          h1(tags$u("Forecasting Methodologies")),
                          br(),
                          align="center"
                        ),
                        ## Top Row
                        fluidRow(
                          column(1),
                          ## Top left quadrant: description of ARIMA
                          column(5,
                                 h3("ARIMA: Autoregressive Integrated Moving Average"),
                                 br(),
                                 p(
                                   "ARIMA is an acronym for “Autoregressive Integrated Moving Average,” and aims to
                                   describe autocorrelations in the data. While the only variable it takes into account
                                   is historical numbers of what it is trying to forecast, it essentially creates
                                   multiple variables for a regression model by looking at various characteristics of
                                   the historical data, such as seasonality, moving averages, year-over-year changes, etc."
                                 ),
                                 p(
                                   "This program is capable of estimating the parameters to use when creating the model. However, if
                                  you'd like to adjust the inputs yourself, simply uncheck the box on the outputs page, and choose
                                  the values you would like to use. One metric that you can use to judge the \"goodness of fit\" 
                                  is paying attention to the AIC. The lower, the better."   
                                 ),
                                 br(),
                                 p("More information on ARIMA models can be found ", tags$a(href="https://www.otexts.org/fpp/8", "here.")),
                                 br(),
                                 align="center"
                          ),
                          ## Top right column: description of Holt's Exponential Smoothing
                          column(5,
                                 h3("Holt’s Exponential Smoothing"),
                                 br(),
                                 p(
                                   "This method involves a forecast equation and two smoothing equations (one for the level
                                   and one for the trend (slope)). The name of “exponential smoothing” comes from the idea
                                   that the weights applied to the historical observations decrease exponentially the further
                                   back in time you go. Exponential smoothing is a middle-ground between two extremes: the
                                   naïve method, which assumes that the most current observation is the only important one,
                                   and the average method, where all future forecasts are equal to a simple average of the 
                                   observed data. Holt modified this method to better include trends."
                                 ),
                                 p(
                                   "The parameters for the level and trend can be estimated by R. If you woul like to adjust
                                   them yourselves, uncheck the box for having R estimate the parameters, and manually adjust
                                   the parameters by moving the sliders. Note that neither parameter can be 0 or 1. One indicator
                                   of your model quality is the AIC score, which you should aim to lower."
                                 ),
                                 p(
                                   "You also have the option of choosing if you want to dampen the model, and if you want to
                                   fit and exponential or linear trend. You can modify these options even while R is estimating
                                   the parameters for level and trend. Dampening models has shown to reduce over-forecasting.
                                   Exponential models tend to be less conservative than linear models do to exponential growth
                                   or decline, but in some scenarios can provbe to be a better fit."
                                 ),
                                 br(),
                                 p("More information on Holt's Exponential Smoothing can be found ", tags$a(href="https://www.otexts.org/fpp/7", "here.")),
                                 br(),
                                 align="center",
                                 style="border-left-style: solid; border-left-color: #000000"
                          ),
                          column(1)
                        ), 
                        ## Horizontal row bisecting page
                        hr(),
                        ## Second row
                        fluidRow(
                          column(1),
                          ## Lower left quadrant: Description of Holt-Winters 
                          column(5,
                                 br(),
                                 h3("Holt-Winters Seasonal Method"),
                                 br(),
                                 p(
                                   "Holt and Winters extended Holt’s original method to capture seasonality (increases and
                                   decreases that are fixed to a time period). Like Holt's original method, it has equations
                                   for level and trend. Also like the Holt model, Holt-Winters models can be dampened. What makes 
                                   these models different is that they add a third equation to account for seasonality."
                                 ),
                                 p(
                                   "For the seasonal component, you have the option of choosing the additive or multiplicative
                                   method. In the additive method, the seasonal component is an absolute number for each given
                                   period within a year, while it is a percentage when using the multiplicative method. As such,
                                   you should use the additive method when seasonal variations are roughly constant throughout, 
                                   while you should choose the multiplicative method if the seasonal variations change proportionally
                                   to the level of the series."
                                 ),
                                 br(),
                                 p("More information on Holt-Winters Exponential Smoothing can be found ", tags$a(href="https://www.otexts.org/fpp/7/5", "here.")),
                                 br(),
                                 align="center"
                          ),
                          ## Lower right quadrant: description of CAGR
                          column(5,
                                 br(),
                                 h3("Compund Annual Growth Rate (CAGR)"),
                                 br(),
                                 p(
                                   "A CAGR, or Compound Annual Growth Rate, represents the growth of a value over time, taking compounding into account. It is 
                                   computed by the end value divided by the beginning value, raised to the power of (1/#periods):"
                                 ),
                                 br(),
                                 tags$img(src="CAGR.png"),
                                 br(),
                                 br(),
                                 p("More information on Compound Annual Growth Rate can be found ", 
                                   tags$a(href="http://www.investopedia.com/ask/answers/071014/what-formula-calculating-compound-annual-growth-rate-cagr-excel.asp", "here.")
                                 ),
                                 br(),
                                 align="center",
                                 style="border-left-style: solid; border-left-color: #000000"
                          ),
                          column(1)
                        ),
                        br(),
                        br()
                      )
             )
  )
)