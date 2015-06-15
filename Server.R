## Notes on Shiny:
## 1.) ui.R is the UI for the app. 
## 2.) server.R is the logic for the app
## 3.) Any time you see "input$..." it is referencing a variable inputted by the user on in the UI
## 4.) Likewise, "output$..." is preparing an output to be displayed in the UI. However, in the UI, 
##     it will be reffered to by a "renderSomething" function, with "outputVariableName" as an argument.
## 5.) Reactive expressions, which are used heavily in this app, automatically update when a relevant input
##     variable is changed.


## Load the required packages:
library("openxlsx")
library("stats")
library("fpp")
library("portes")
library(scales)

shinyServer(function(input, output) {
  
  ##### Section 1: Data Preperation #####
  
  ##### Section 1.0: Data Intake #####
  
  ## Status report for first page
  output$statusReport <- reactive({
    x <- "Status: Waiting..."
    if((input$doArima | input$doHolt | input$doHW | input$doCAGR) && !is.null(input$inputFile)){
      x <- "Status: Analyzing... Check the \"Outputs\" tab!"
    }
    x
  })
  
  ## Reads in the historical data from the uploaded file
  readData <- reactive({
    inFile <- input$inputFile
    if (is.null(inFile))
      return(NULL)
    data <- read.csv(inFile$datapath)
    data
  })
  
  ## Returns the historical values to be used in forecasting
  historical <- reactive({
    data <- readData()
    ## Remove any commas and dollar signs, and convert to a number
    data[,2] <- as.numeric(sub("\\,","",
                               sub("\\$","",data[,2])
                               )
                           )
    data
  })
  
  ## Creates a data frame with labels for each of the periods
  
  
  ## Converts the historical data to a time series
  tsData <- reactive({
    data <- historical()
    data <- data[,2]
    ts <- ts(data,
             #start=c(input$startYear, input$startTime), 
             #end=c(input$endYear, input$endTime), 
             frequency = strtoi(input$frequency)
    )
    print("TS:")
    print(ts)
    ts
  })
  
  ##### Section 1.1: ARIMA #####
  
  ## Create an ARIMA model for forecasting
  arimaModel <- reactive({
    ts <- tsData()
    if(input$arimaAuto){
      fit <- auto.arima(ts)
      print(fit)
    }
    else{
       fit <- arima(ts,order=c(strtoi(input$arimaP),
                              strtoi(input$arimaD), 
                              strtoi(input$arimaQ)))
      print(fit)
    }
    fit
  })
  
  ## Get an AIC value to judge the quality of the model
  output$arimaAIC <- renderText({
    if(is.null(input$inputFile)){
      aic <- "No file found..."
    }
    else if(input$doArima ){
      model <- arimaModel()
      aic <- AIC(model)
      aic <- round(aic, 3)
    }
    else{
      aic <- ""
    }
    aic
  })
  
  ## Creates an ARIMA model and returns a forecast based on that model.
  arimaData <- reactive({
    fit <- arimaModel()
    print("Fit: ")
    print(fit)
    f <- forecast(fit#,
                  #h = input$forecast_periods,
                  #level=c(strtoi(input$confidence1), strtoi(input$confidence2))
    )
    print("Forecast:")
    print(f)
    f
  })
  
  ##### Section 1.2: Holt #####
  
  ## Use Holt's Exponential Smoothing for a forecast of the given
  ## number of periods
  holtData <- reactive({
    ts <- tsData()
    ## If the user wants R to estimate the smoothing parameters
    if(input$holtAuto){
      h <- holt(ts,
                h = input$forecast_periods,
                damped=TRUE,
                exponential= input$holtExp,
                level=c(strtoi(input$confidence1), strtoi(input$confidence2))
      )
    }
    ## If the user wants custom smoothing parameters
    else{
      h <- holt(ts,
                h = input$forecast_periods,
                damped = TRUE,
                exponential= input$holtExp,
                alpha = input$holtAlpha,
                beta = input$holtBeta,
                level=c(strtoi(input$confidence1), strtoi(input$confidence2))
      )
    }
    h
  })
  
  ## Get an AIC value to judge the quality of the model
  output$holtAIC <- renderText({
    ## If no file has been uploaded:
    if(is.null(input$inputFile)){
      aic <- "No file found..."
    }
    ## Display the AIC if the user selected Holt
    else if(input$doHolt){
      holt <- holtData()
      model <- holt$model
      aic <- AIC(model)
      aic <- round(aic,3)
    }
    ## Otherwise, display blank text
    else{
      aic <- ""
    }
    aic
  })
  
  ##### Section 1.3: Holt-Winters #####
  
  ## Use Holt-Winters seasonal method of Exponential Smoothing
  ## for a forecast of the given number of periods
  hwData <- reactive({
    ts <- tsData()
    ## If the user wants R to estimate the smoothing parameters
    if(input$hwAuto){
      hw <- hw(ts,
               h = input$forecast_periods,
               damped=TRUE,
               level=c(strtoi(input$confidence1), strtoi(input$confidence2))
      )
    }
    ## If the user wants custom smoothing parameters
    else{
      hw <- hw(ts,
               h = input$forecast_periods,
               damped = TRUE,
               alpha = input$hwAlpha,
               beta = input$hwBeta,
               gamma = input$hwGamma,
               level=c(strtoi(input$confidence1), strtoi(input$confidence2))
      )
    }
    hw
  })
  
  ## Get an AIC value to judge the quality of the model
  output$hwAIC <- renderText({
    ## If no file has been uploaded:
    if(is.null(input$inputFile)){
      aic <- "No file found..."
    }
    ## Display the AIC if the user selected Holt
    else if(input$doHW){
      hw <- hwData()
      model <- hw$model
      aic <- AIC(model)
      aic <- round(aic,3)
    }
    ## Otherwise, display blank text
    else{
      aic <- ""
    }
    aic
  })
  
  ##### Section 1.4: CAGR #####
  
  ## Calc the actual CAGR rate
  calcCAGR <- reactive({
    if(!is.null(input$inputFile)){
      ## Get the time series data
      ts <- tsData()
      ## Take the first known non-zero value:
      for(i in 1:length(ts)){
        x <- ts[i]
        if(x > 0){
          first <- x
          offset <- i-1
          break
        }
      }
      ## This should never need to be called:
      if(first <= 0){
        warning("The first value in the time series may lead to an inaccurate 
          CAGR forecast because the first value is less than or equal to 0.") 
      }
      ## Take the last known value
      last <- ts[length(ts)]
      ## Make sure it's not zero
      if(last == 0){
        warning("The last value in the time series is zero, and therefore will not yield an accurate CAGR calculation.")
      }
      ## Calculate the CAGR:
      ## Compute the actual growth rate:
      CAGR <- ((last/first))^(1/(length(ts)-offset))
      CAGR
    }
  })
  
  ## Prepare the text output do display the cagr rate in the UI
  output$CAGR <- renderText({
    if(is.null(input$inputFile)){
      cagr <- "No file found"
    }
    else if(input$doCAGR){
      cagr <- as.numeric(calcCAGR()-1)
      cagr <- paste(round(cagr*100,2), "%", sep="")
    }
    else{
      cagr <- ""
    }
    cagr
  })
  
  ## Project out using the CAGR 
  cagrData <- reactive({
    if(!is.null(input$inputFile)){
      ## Get the time series data
      ts <- tsData()
      ## Take the first known non-zero value:
      for(i in 1:length(ts)){
        x <- ts[i]
        if(x > 0){
          first <- x
          offset <- i-1
          break
        }
      }
      ## This should never need to be called:
      if(first <= 0){
        warning("The first value in the time series may lead to an inaccurate 
          CAGR forecast because the first value is less than or equal to 0.") 
      }
      ## Take the last known value
      last <- ts[length(ts)]
      ## Make sure it's not zero
      if(last == 0){
        warning("The last value in the time series is zero, and therefore will not yield an accurate CAGR calculation.")
      }
      CAGR <- calcCAGR()
      cagrData <- last
      ## For each period of forecasting, take the last calculated value, and grow it by the CAGR
      for (p in 1:input$forecast_periods) {
        n <- round(as.numeric(cagrData[length(cagrData)]*(CAGR)), 2)
        cagrData <- c(cagrData, n)
        cagrData
      }
      ## Remove the first value in the list, because it was the last value of historical data
      cagrData <- cagrData[2:length(cagrData)]
    }
  })
  
  
  ################# Section 2: Plots #######################
  
  ##### Section 2.1: ARIMA #####
  
  ## Prepares the plot for the Arima forecast
  output$arimaPlot <- renderPlot({
    ## Check to see if the user want's an ARIMA plot
    if(input$doArima && !is.null(input$inputFile)){
      data <- arimaData()
      plot(data,
           xlab="Years",
           ylab="Quantity"
      )
    }
    ## If they don't, return a blank plot
    else{
      ## Returns a blank plot
      plot(1, type="n", axes=F, xlab="", ylab="")
    }
  })
  
  ##### Section 2.2: Holt #####
  
  ## Prepares the plot for the Holt Forecast
  output$holtPlot <- renderPlot({
    ## Check to see if the use wants a Holt plot
    if(input$doHolt && !is.null(input$inputFile)){
      data <- holtData()
      plot(data,
           xlab="Years",
           ylab="Quantity"
      )
    }
    ## If they don't, return a blank plot
    else{
      ## Returns a blank plot
      plot(1, type="n", axes=F, xlab="", ylab="")
    }
  })
  
  ##### Section 2.3: Holt-Winters #####
  
  ## Prepares the plot for the Holt-Winters Forecast
  output$hwPlot <- renderPlot({
    ## Check to see if the user wants a Holt-Winters plot
    if(input$doHW && !is.null(input$inputFile)){
      data <- hwData()
      plot(data,
           xlab="Years",
           ylab="Quantity"
      )
    }
    ## If they don't, return a blank plot
    else{
      ## Plots a blank plot
      plot(1, type="n", axes=F, xlab="", ylab="")
    }
  })
  
  #### Section 2.4: CAGR #####
  
  ## Prepares the plot for the CAGR Projections
  output$cagrPlot <- renderPlot({
    ## Check to see if the user wants a CAGR plot
    if(input$doCAGR && !is.null(input$inputFile)){
      data <- cagrData()
      plot(data, 
           ## type b = both, meaning both points and lines on the plot
           type='b', 
           ## plot labels
           main="Forecast From Compound Annual Growth Rate (CAGR)",
           xlab="Periods",
           ylab="Quantity")
    }
    ## If they don't, return a blank plot
    else{
      ## Plots a blank plot
      plot(1, type="n", axes=F, xlab="", ylab="")
    }
  })
  
  ##### Section 3: Download Handler #####
  
  ##### Section 3.1: Summary Sheet #####
  
  ## Creates a summary sheet with the historical data and the expected value from
  ## each chosen forecasting method.
  createSummarySheet <- reactive({
    ## Start with getting the historical data, and storing it in a well-formatted dataframe
    data <- historical()
    historical <- data.frame(data[,2])
    empty <- data.frame(matrix(nrow=input$forecast_periods, ncol=1))
    names(empty) <- names(historical)
    resultDF <- rbind(historical,empty)
    colnames(resultDF) <- c("Historical")
    ## Get the ARIMA data, convert it to a dataframe, take the first column (the expected value),
    ## make sure it's not in scientific format, and round it to 2 decimal places. Append it to the
    ## historical data, and add the column to the accumulating dataframe.
    ## Then give the column an appropriate name. 
    if(input$doArima){
      arima <- round(
        as.numeric(
          format(
            data.frame(arimaData())[,1],
            scientific=FALSE
          ) 
        ),
        2)
      arima <- data.frame(arima)
      names(arima) <- names(historical)
      newCol <- rbind(historical, arima)
      resultDF <- cbind(resultDF, newCol)
      colnames(resultDF)[ncol(resultDF)] <- "ARIMA"
    }
    ## Get the Holt data, convert it to a dataframe, take the first column (the expected value),
    ## make sure it's not in scientific format, and round it to 2 decimal places. Append it to the
    ## historical data, and add the column to the accumulating dataframe.
    ## Then give the column an appropriate name.  
    if(input$doHolt){
      holt <- round(
        as.numeric(
          format(
            data.frame(holtData())[,1],
            scientific=FALSE
          ) 
        ),
        2)
      holt <- data.frame(holt)
      names(holt) <- names(historical)
      newCol <- rbind(historical, holt)
      resultDF <- cbind(resultDF, newCol)
      colnames(resultDF)[ncol(resultDF)] <- "Holt"
    }
    ## Get the Holt-Winters data, convert it to a dataframe, take the first column (the expected value),
    ## make sure it's not in scientific format, and round it to 2 decimal places. Append it to the
    ## historical data, and add the column to the accumulating dataframe.
    ## Then give the column an appropriate name. 
    if(input$doHW){
      hw <- round(
        as.numeric(
          format(
            data.frame(hwData())[,1],
            scientific=FALSE
          ) 
        ),
        2)
      hw <- data.frame(hw)
      names(hw) <- names(historical)
      newCol <- rbind(historical, hw)
      resultDF <- cbind(resultDF, newCol)
      colnames(resultDF)[ncol(resultDF)] <- "Holt-Winters"
    }
    ## Get the CAGR data, convert it to a dataframe, take the first column (the expected value),
    ## make sure it's not in scientific format, and round it to 2 decimal places. Then give the column 
    ## an appropriate name. 
    if(input$doCAGR){
      cagr <- cagrData()
      cagr <- data.frame(cagr)
      names(cagr) <- names(historical)
      newCol <- rbind(historical, cagr)
      resultDF <- cbind(resultDF, newCol)
      colnames(resultDF)[ncol(resultDF)] <- "CAGR"
    }
    ## Create a workbook (using openxlsx) to store the data in
    wb <- createWorkbook(creator="Endeavour Partners")
    ## Add a sheet to save the summary to
    addWorksheet(wb, sheetName="Summary")
    ## Save the data to the sheet
    writeData(wb, "Summary", resultDF)
    wb
  })
  
  ##### Section 3.2: Details #####
  
  ## Prepares the desired detailed data for the user to download
  ## For more info on how this works, look at the openxlsx package
  prepareOutput <- reactive({
    ## Creates a new workbook with a summary table as the first sheet
    wb <- createSummarySheet()
    ## If the user wants the ARIMA forecast, 
    ## write that to a new sheet in the workbook
    if(input$doArima){
      addWorksheet(wb, "ARIMA Forecast")
      writeData(wb, "ARIMA Forecast", data.frame(arimaData()))
    }
    ## If the user wants the Holt forecast, 
    ## write that to a new sheet in the workboook
    if(input$doHolt){
      addWorksheet(wb, "Holt Forecast")
      writeData(wb, "Holt Forecast", data.frame(holtData()))
    }
    ## If the user wants the Holt-Winters forecast, 
    ## write that to a new sheet in the workbook
    if(input$doHW){
      addWorksheet(wb, "Holt-Winters Forecast")
      writeData(wb, "Holt-Winters Forecast", data.frame(hwData()))
    }
    ## If the user wants the CAGR forecast, 
    ## write that to a new sheet in the workbook
    if(input$doCAGR){
      addWorksheet(wb, "CAGR Projection")
      writeData(wb, "CAGR Projection", cagrData())
    }
    ## Finally, write the historical data to a new 
    ## sheet, for easy reference
    addWorksheet(wb, "Historical Data")
    writeData(wb, "Historical Data", historical())
    ## return the workbook
    wb
  })
  
  ##### Section 3.3: Download #####
  
  ## Handles downloading the data for the user when they click the 
  ## "Download" button on the "Outputs" page
  output$downloadData <- downloadHandler(
    ## Create the filename
    filename = function() { paste(input$outputName, '.xlsx', sep='') },
    ## Get the content and write it to a temporary file ("file")
    content = function(file){
      ## A temporary name
      fname <- paste(input$outputName, '.xlsx', sep='')
      ## Get the workbook with the requested data from the function above
      wb <- prepareOutput()
      ## Save the workbook with the temporary file name
      ## This saves it as an Excel workbook, which is important as the
      ## temporary file used in the download does not have a filetype
      saveWorkbook(wb, fname)
      ## Essentially saves the Excel workbook to the temporary file for downloading
      file.rename(fname,file)
    }
  )
})
