# Statistical models and visualisations with Google Analytics data

# Pre-packaged examples
# A ready-made model is available in the googleAnalyticsModelR package.
# This function loads the pre-made model object
# created by the ga_model_* functions in googleAnalyticsR.

library(prophet)
library(googleAnalyticsR)
library(googleAnalyticsModelR)

ga_auth(email = Sys.getenv("GARGLE_EMAIL"))
my_view_id <- 81416156

forecast_data <- ga_model_prophet(my_view_id, interactive_plot = TRUE)
forecast_data$plot


# Time-normalised visits to your website:
output <- ga_time_normalised(my_view_id, interactive_plot = TRUE)
output$plot


# As we have a standardised model structure, it makes it easier to use the output
# in other functions. For example, you can make a webpage suitable for embedding in
# Twitter tweets and upload via googleCloudStorageR using ga_model_tweet():

library(googleCloudStorageR)

ga_model_tweet(forecast_data, 
               "@HoloMarkeD", 
               title = "ga_model example - prophet forecasting",
               bucket = "mark-edmondson-public-read")


# A simple example loading a model directly
library(googleAnalyticsR)  # load library

# authenticate
ga_auth(email = Sys.getenv("GARGLE_EMAIL"))

# your own Google Analytics viewID
my_viewid <- 81416156

# load the model (equivalent to ga_model_load())
decomp_ga <- ga_model_example("decomp_ga.gamr")

# apply model to your data
d1 <- ga_model(my_viewid, model = decomp_ga)


# This model allows you to alter the date range of the data fetched:
# change default date range to 20 days ago to yesterday
d2 <- ga_model(my_viewid, model = decomp_ga, date_range = c("20daysAgo","yesterday"))


# You can examine the properties of the model and the arguments it was
# sent via its print method:

decomp_ga
## ==ga_model object==
## Description:  Performs decomposition and creates a plot 
## Data args:    viewId date_range 
## Input data:   date sessions 
## Model args:   df 
## Output args:  x y 
## Packages:


d2
## ==ga_model_result object==
## Input names:        date sessions 
## Input dimensions:   20 2 
## Output names:       x seasonal trend random figure type 
## Plot class:         NULL 
## Model args passed:  date_range = c("20daysAgo", "yesterday") 
## ==ga_model object==
## Description:  Performs decomposition and creates a plot 
## Data args:    viewId date_range 
## Input data:   date sessions 
## Model args:   df 
## Output args:  x y 
## Packages:


# And if you want to review the code of the model,
# use ga_model_write() to write the functions out to a file.

ga_model_write(decomp_ga, "my_model.R")

# Shiny modules
shiny::runApp(system.file("shiny/hello-world-models", package="googleAnalyticsR"))


# The model code is encapsulated in the Shiny module so
# the actual Shiny app is relatively simple:

library(shiny)
library(googleAuthR)
library(googleAnalyticsR) 

gar_set_client(web_json = "ga-web-client.json",
               scopes = "https://www.googleapis.com/auth/analytics.readonly")

# loads a pre-existing model
model <- ga_model_example("decomp_ga.gamr", location = "googleAnalyticsR")

## ui.R
ui <- fluidPage(title = "googleAnalyticsR Test Deployment",
                
                authDropdownUI("auth_menu"),
                h2("Model Description"),
                textOutput("model_description"),
                h2("Model Output"),
                model$shiny_module$ui("model1")
                
)

## server.R
server <- function(input, output, session){
  
  gar_shiny_auth(session)
  
  al <- reactive(ga_account_list())
  
  # module for authentication
  view_id <- callModule(authDropdown, "auth_menu", ga.table = al)
  output$model_description <- renderText(model$description)
  
  # module to display model results
  callModule(model$shiny_module$server, "model1", view_id = view_id)
  
}

shinyApp(gar_shiny_ui(ui, login_ui = silent_auth), server)


# If you want to pass reactive input objects to your model's module,
# do so by wrapping them in shiny::reactive() e.g.

callModule(model$shiny_module$server,
           "model1",
           view_id = view_id,
           reactive_var = reactive(input$my_option))


# Creating model .gamr objects
get_model_data <- function(viewId,
                           date_range = c(Sys.Date()- 300, Sys.Date()),
                           ...){
  google_analytics(viewId,
                   date_range = date_range,
                   metrics = "sessions",
                   dimensions = "date",
                   max = -1)
}

decompose_sessions <- function(df, ...){
  decompose(ts(df$sessions, frequency = 7))
}

decomp_ga <- ga_model_make(get_model_data,
                           required_columns = c("date", "sessions"),
                           model_f = decompose_sessions,
                           output_f = graphics::plot,
                           description = "Performs decomposition and creates a plot",
                           outputShiny = shiny::plotOutput,
                           renderShiny = shiny::renderPlot)


# Advanced use
# The more arguments you provide to the model creation functions,
# the more complicated it is for the end user, but the more flexible the model.
# It is suggested making several narrow usage models is better than one complicated one.

# For instance, you could modify the above model to allow the end user to
# specify the metric, timespan and seasonality of the decomposition:

get_model_data <- function(viewId,
                           date_range = c(Sys.Date()- 300, Sys.Date()),
                           metric,
                           ...){
  o <- google_analytics(viewId,
                        date_range = date_range,
                        metrics = metric,
                        dimensions = "date",
                        max = -1)
  # rename the metric column so its found for modelling
  o$the_metric <- o[, metric]
  
  o
  
}

decompose_sessions <- function(df, frequency, ...){
  decompose(ts(df$the_metric, frequency = frequency))
}

decomp_ga_advanced <- ga_model_make(get_model_data,
                                    required_columns = c("date"), # less restriction on column
                                    model_f = decompose_sessions,
                                    output_f = graphics::plot,
                                    description = "Performs decomposition and creates a plot",
                                    outputShiny = shiny::plotOutput,
                                    renderShiny = shiny::renderPlot)



# It would then be used via:
result <- ga_model(81416156, decomp_ga_advanced, metric="users", frequency = 30)


# Working with the model object
# The model objects prints to console in a friendly manner:

decomp_ga_advanced

## ==ga_model object==
## Description:  Performs decomposition and creates a plot 
## Data args:    viewId date_range metric 
## Input data:   date 
## Model args:   df frequency 
## Output args:  x y 
## Packages:

# You can save and load model objects from a file.
# It is suggested to save them with the .gamr suffix.
# save model to a file
ga_model_save(decomp_ga_advanced, filename = "my_model.gamr")

# load model again
ga_model_load("my_model.gamr")


# You can use models directly from the file:
ga_model(81416156, "my_model.gamr")


# If you need to change parts of a model,
# ga_model_edit() lets you change individual aspects:

ga_model_edit(decomp_ga_advanced, description = "New description")

## ==ga_model object==
## Description:  New description 
## Data args:    viewId date_range metric 
## Input data:   date 
## Model args:   df frequency 
## Packages:

# You can also pass it the filename, which will load, make the edit,
# then save the model to disk again:
ga_model_edit("my_model.gamr", description = "New description")


# If you want to examine or change the functions in a model,
# you can use ga_model_write() to write them to a file,
# or examine them directly from the model object.
# The structure of the model object can be examined using str():

str(decomp_ga_advanced, give.attr = FALSE)
## List of 7
##  $ data_f           :function (viewId, date_range = c(Sys.Date() - 300, Sys.Date()), metric, 
##     ...)  
##  $ required_columns : chr "date"
##  $ model_f          :function (df, frequency, ...)  
##  $ output_f         :function (x, y, ...)  
##  $ required_packages: NULL
##  $ description      : chr "Performs decomposition and creates a plot"
##  $ shiny_module     :List of 2
##   ..$ ui    :function (id, ...)  
##   ..$ server:function (input, output, session, view_id, ...)


# And you can access various elements by the usual list methods:
decomp_ga_advanced$data_f

## function(viewId,
##                            date_range = c(Sys.Date()- 300, Sys.Date()),
##                            metric,
##                            ...){
##    o <- google_analytics(viewId,
##                     date_range = date_range,
##                     metrics = metric,
##                     dimensions = "date",
##                     max = -1)
##     # rename the metric column so its found for modelling
##     o$the_metric <- o[, metric]
##     
##     o
##     
##  }


decomp_ga_advanced$description
## [1] "Performs decomposition and creates a plot"


# GA Effect with ga_models

# Get data

get_ci_data <- function(viewId, 
                        date_range = c(Sys.Date()-600, Sys.Date()),
                        ...){
  
  google_analytics(viewId, 
                   date_range = date_range,
                   metrics = "sessions",
                   dimensions = c("date", "channelGrouping"), 
                   max = -1)
}

# response_dim is the channel to predict.
# predictors help with forecast
do_ci <- function(df, 
                  event_date,
                  response = "Organic Search",
                  predictors = c("Video","Social","Direct"),
                  ...){
  
  message("CausalImpact input data columns: ", paste(names(df), collapse = " "))
  # restrict to one response 
  stopifnot(is.character(response), 
            length(response) == 1,
            assertthat::is.date(event_date),
            is.character(predictors))
  
  pivoted <- df %>% 
    tidyr::spread(channelGrouping, sessions)
  
  stopifnot(response %in% names(pivoted))
  
  ## create a time-series zoo object
  web_data_xts <- xts::xts(pivoted[-1], order.by = as.Date(pivoted$date), frequency = 7)
  
  pre.period <- as.Date(c(min(df$date), event_date))
  post.period <- as.Date(c(event_date + 1, max(df$date)))
  
  predictors <- intersect(predictors, names(web_data_xts))
  
  ## data in order of response, predictor1, predictor2, etc.
  model_data <- web_data_xts[,c(response,predictors)]
  
  # deal with names
  names(model_data) <- make.names(names(model_data))
  # remove any NAs
  model_data[is.na(model_data)] <- 0
  
  CausalImpact::CausalImpact(model_data,  pre.period, post.period)
  
}


dygraph_plot <- function(impact, event_date, ...){
  
  ## the data for the plot is in here
  ci <- impact$series
  
  ci <- xts::xts(ci)
  
  ## the dygraph output
  dygraph(data=ci[,c('response', 
                     'point.pred', 'point.pred.lower', 'point.pred.upper')], 
          main="Expected (95% confidence level) vs Observed", group="ci") %>%
    dyEvent(x = event_date, "Event") %>%
    dySeries(c('point.pred.lower', 'point.pred','point.pred.upper'), 
             label='Expected') %>%
    dySeries('response', label="Observed")
}


req_packs <- c("CausalImpact", "xts", "tidyr", "googleAnalyticsR", "assertthat", "dygraphs")

ci_model <- ga_model_make(get_ci_data,
                          required_columns = c("date","channelGrouping","sessions"),
                          model_f = do_ci,
                          output_f = dygraph_plot,
                          required_packages = req_packs,
                          description = "Causal Impact on channelGrouping data",
                          outputShiny = dygraphs::dygraphOutput,
                          renderShiny = dygraphs::renderDygraph)
# print out model details
ci_model

## ==ga_model object==
## Description:  Causal Impact on channelGrouping data 
## Data args:    viewId date_range 
## Input data:   date channelGrouping sessions 
## Model args:   df event_date response predictors 
## Output args:  impact event_date 
## Packages:     CausalImpact xts tidyr googleAnalyticsR assertthat dygraphs

# save it to a file for use later
ga_model_save(ci_model, "causalImpact_model.gamr")

library(googleAnalyticsR)
library(CausalImpact)
library(xts)
library(tidyr)
library(dygraphs)

ga_auth(email = Sys.getenv("GARGLE_EMAIL"))

ci <- ga_model(81416156, ci_model, event_date = as.Date("2019-01-01"))

# print to show the plot object
ci$plot

# Ref: https://code.markedmondson.me/googleAnalyticsR/articles/models.html


