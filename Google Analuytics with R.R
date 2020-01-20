# Author: Tanay Mukherjee
# 2019-02-12

## setup
library(googleAnalyticsR)

## authenticate
ga_auth()

## get your accounts
account_list <- ga_account_list()

## account_list will have a column called "viewId"
account_list$viewId

## View account_list and pick the viewId you want to extract data from
ga_id <- 123456

## simple query to test connection
google_analytics(ga_id, 
                 date_range = c("2017-01-01", "2017-03-01"), 
                 metrics = "sessions", 
                 dimensions = "date")


# 1000 rows only
thousand <- google_analytics(ga_id, 
                             date_range = c("2017-01-01", "2017-03-01"), 
                             metrics = "sessions", 
                             dimensions = "date")

# 2000 rows
twothousand <- google_analytics(ga_id, 
                                date_range = c("2017-01-01", "2017-03-01"), 
                                metrics = "sessions", 
                                dimensions = "date",
                                max = 2000)  

# All rows
alldata <- google_analytics(ga_id, 
                            date_range = c("2017-01-01", "2017-03-01"), 
                            metrics = "sessions", 
                            dimensions = "date",
                            max = -1) 


## anti_sample gets all results (max = -1)
gadata <- google_analytics(myID,
                           date_range = c(start_date, end_date),
                           metrics = "pageviews",
                           dimensions = "pageTitle",
                           segments = myseg,
                           anti_sample = TRUE)

## ----

## If you are using anti-sampling, it will always fetch all rows.
## This is because it won't make sense to fetch only the top results as the API
## splits up the calls over all days.
## If you want to limit it afterwards, use R by doing something like:

## limit to top 25
top_25 <- head(gadata[order(gadata$pageviews, decreasing = TRUE), ] , 25)


## Date Ranges
## You can send in dates in YYYY-MM-DD format:

google_analytics(868768, date_range = c("2016-12-31", "2017-02-01"), metrics = "sessions")

yesterday <- Sys.Date() - 1
ThreedaysAgo <- Sys.Date() - 3

google_analytics(868768, date_range = c(ThreedaysAgo, yesterday), metrics = "sessions")

google_analytics(868768, date_range = c("5daysAgo", "yesterday"), metrics = "sessions")

## Compare data ranges
google_analytics(868768, 
                 date_range = c("16daysAgo", "9daysAgo", "8daysAgo", "yesterday"), 
                 metrics = "sessions")

delta_sess <- order_type("sessions","DESCENDING", "DELTA")

## find top 20 landing pages that changed most in sessions comparing this week and last week
gadata <- google_analytics(gaid,
                           date_range = c("16daysAgo", "9daysAgo", "8daysAgo", "yesterday"),
                           metrics = c("sessions"),
                           dimensions = c("landingPagePath"),
                           order = delta_sess,
                           max = 20)

## Anti sampling

## Sampled data example
library(googleAnalyticsR)
ga_auth()
sampled_data_fetch <- google_analytics(id, 
                                       date_range = c("2015-01-01","2015-06-21"), 
                                       metrics = c("users","sessions","bounceRate"), 
                                       dimensions = c("date","landingPagePath","source"))



## Unsampled data example
library(googleAnalyticsR)
ga_auth()
unsampled_data_fetch <- google_analytics(id, 
                                         date_range = c("2015-01-01","2015-06-21"), 
                                         metrics = c("users","sessions","bounceRate"), 
                                         dimensions = c("date","landingPagePath","source"),
                                         anti_sample = TRUE)




## Cases when auto-anti sampling fails
## Use the following method to continue digging deeper

## example setting your own anti_sample_batch to 5 days per batch
unsampled_data_fetch <- google_analytics(id, 
                                         date_range = c("2015-01-01","2015-06-21"), 
                                         metrics = c("users","sessions","bounceRate"), 
                                         dimensions = c("date","landingPagePath","source"),
                                         anti_sample = TRUE,
                                         anti_sample_batch = 5)

