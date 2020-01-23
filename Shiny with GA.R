# Shiny Apps that call Google Analytics API data

# in server.R
library(googleAuthR)
library(googleAnalyticsR)
library(shiny)

shinyServer(function(input, output, session){
  
  # Get auth code from return URL
  access_token  <- callModule(googleAuth, "auth1")
  
  gadata <- reactive({
    
    with_shiny(google_analytics_3,
               id = "222222", # replace with your View ID
               start="2015-08-01", end="2015-08-02", 
               metrics = c("sessions", "bounceRate"), 
               dimensions = c("source", "medium"),
               shiny_access_token = access_token())
  })
  
  output$something <- renderPlot({
    
    # only trigger once authenticated
    req(access_token())
    
    gadata <- gadata()
    
    plot(gadata)
    
  })
  
})


# Authentication modules
# authDropdown and authDropdownUI create a row of selects to help with choosing a GA View.

# ui.R
library(googleAuthR)
library(shiny)

shinyUI(fluidPage(
  
  googleAuthUI("auth1"),
  plotOutput("something")
  
))


# ui.R
googleAuthUI("login"),
authDropdownUI("auth_menu")


# server.R 

(...)

token <- callModule(googleAuth, "login")

ga_accounts <- reactive({
  validate(
    need(token(), "Authenticate")
  )
  
  with_shiny(ga_account_list, shiny_access_token = token())
  
})

selected_id <- callModule(authDropdown, "auth_menu", ga.table = ga_accounts)

(...)


# Parameter selects
# multiSelect and multiSelectUI create select dropdowns with the
# GA API parameters filled in, taken from the meta API.


# Segment helper
# segmentBuilder and segmentBuilderUI creates a segment builder interface.
# This is also available as an RStudio gadget to help create segments more easily.


# Example:

# ui.R
library(googleAuthR)
library(googleAnalyticsR)
library(shiny)
library(highcharter)

shinyUI(
  fluidPage(
    googleAuthUI("login"),
    authDropdownUI("auth_menu"),
    highchartOutput("something")
    
  ))

# in server.R
library(googleAuthR)
library(googleAnalyticsR)
library(shiny)
library(highcharter)

function(input, output, session){
  
  # Get auth code from return URL
  token <- callModule(googleAuth, "login")
  
  ga_accounts <- reactive({
    req(token())
    
    with_shiny(ga_account_list, shiny_access_token = token())
    
  })
  
  selected_id <- callModule(authDropdown, "auth_menu", ga.table = ga_accounts)
  
  gadata <- reactive({
    
    req(selected_id())
    gaid <- selected_id()
    with_shiny(google_analytics_3,
               id = gaid,
               start="2015-08-01", end="2017-08-02", 
               metrics = c("sessions"), 
               dimensions = c("date"),
               shiny_access_token = token())
  })
  
  output$something <- renderHighchart({
    
    # only trigger once authenticated
    req(gadata())
    
    gadata <- gadata()
    
    # creates a line chart using highcharts
    hchart(gadata, "line" , hcaes(x = date, y = sessions))
    
  })
  
}
