# Big Query Exports from Google Analytics 360 to R

# Setup
install.packages("bigQueryR")
devtools::install_github("MarkEdmondson1234/bigQueryR")

#Once installed, authenticate to BigQuery:
library(bigQueryR)

# go through Google oAuth2 flow
# needs email that has access to the BigQuery dataset
bqr_auth()

# get lists of your project and datasets
bqr_list_projects()
bqr_list_datasets("project-id")


# If you want to authenticate with Google Analytics and BigQuery in the same session
# (or others) then its best to authenticate with googleAuthR::gar_auth()
# with the appropriate scopes set. The below lets you authenticate with Google Analytics,
# Google Cloud Storage and BigQuery:

options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/analytics",
                                        "https://www.googleapis.com/auth/cloud-platform",
                                        "https://www.googleapis.com/auth/bigquery"))
googleAuthR::gar_auth()


# You may also want to use a JSON file to authenticate with BigQuery.
# Make sure to add the service email to the users of the Google project,
# and then download the JSON file and authenticate via:
googleAuthR::gar_auth_service("gwt-download-XXXX.json")


# Exporting data
# For BigQuery Google Analytics 360 exports, the dataset is the same as
# the GA View ID you are exporting.

bq <- google_analytics_bq("project-id", "dataset-id-ga-viewid", 
                          start = "2016-01-01", end = "2016-02-01", 
                          metrics = "users", 
                          dimensions = c("source","medium"))
head(bq)


bq2 <- google_analytics_bq("project-id", "dataset-id-ga-viewid", 
                           start = "2016-01-01", end = "2016-02-01", 
                           metrics = "users", 
                           dimensions = c("source","medium","landingPagePath"))

> Error in google_analytics_bq("project-id", "dataset-id-ga-viewid", start = "2016-01-01",  : 
                                 dimension not yet supported. Must be one of referralPath, campaign, source, medium, keyword, adContent, adwordsCampaignID, adwordsAdGroupID, transactionId, date, visitorId, visitId, visitStartTime, visitNumber                                                   
                               

# Raw BigQuery SQL
q <- "SELECT
  date,
  SUM (totals.visits) visits,
  SUM (totals.pageviews) pageviews,
  SUM (totals.transactions) transactions,
  SUM (totals.transactionRevenue)/1000000 revenue
FROM [87010628.ga_sessions_20160327],[87010628.ga_sessions_20160328],[87010628.ga_sessions_20160329]
GROUP BY date
ORDER BY date ASC "

bq3 <- google_analytics_bq("project-id", "dataset-id-ga-viewid", 
                           query = q)


# If you pass in the parameter return_query_only you can output the query
# for use within the interface:

just_query <- google_analytics_bq("project-id", "dataset-id-ga-viewid", 
                                  start = "2016-01-01", end = "2016-02-01", 
                                  metrics = "users", 
                                  dimensions = c("source","medium"),
                                  return_query_only = TRUE)
just_query

# Output like:
# [1] "SELECT trafficSource.source as source, trafficSource.medium as medium, COUNT(fullVisitorId) as users 
# FROM (TABLE_DATE_RANGE([dataset-id-ga-viewid.ga_sessions_], TIMESTAMP('2016-01-01'),
# TIMESTAMP('2016-02-01'))) GROUP BY source, medium  LIMIT 100"


# Implemented metrics and dimensions

# The metrics and dimensions implemented so far are in the two lookups below.
#   They include the BigQuery exclusive hitTimestamp, fullVisitorId, visitId etc.

lookup_bq_query_m <- c(visits = "SUM(totals.visits) as sessions",
                       sessions = "SUM(totals.visits) as sessions",
                       pageviews = "SUM(totals.pageviews) as pageviews",
                       timeOnSite = "SUM(totals.timeOnSite) as timeOnSite",
                       bounces = "SUM(totals.bounces) as bounces",
                       transactions = "SUM(totals.transactions) as transactions",
                       transactionRevenue = "SUM(totals.transactionRevenue)/1000000 as transactionRevenue",
                       newVisits = "SUM(totals.newVisits) as newVisits",
                       screenviews = "SUM(totals.screenviews) as screenviews",
                       uniqueScreenviews = "SUM(totals.uniqueScreenviews) as uniqueScreenviews",
                       timeOnScreen = "SUM(totals.timeOnScreen) as timeOnScreen",
                       users = "COUNT(fullVisitorId) as users",
                       exits = "COUNT(hits.isExit) as exits",
                       entrances = "COUNT(hits.isEntrance) as entrances",
                       eventValue = "SUM(hits.eventinfo.eventValue) as eventValue",
                       metricXX = {a function to output hit level custom metrics})

lookup_bq_query_d <- c(referralPath = "trafficSource.referralPath as referralPath",
                       hitTimestamp = "(visitStartTime + (hits.time/1000)) as hitTimestamp",
                       campaign = "trafficSource.campaign as campaign",
                       source = "trafficSource.source as source",
                       medium = "trafficSource.medium as medium",
                       keyword = "trafficSource.keyword as keyword",
                       adContent = "trafficSource.adContent as adContent",
                       adwordsCampaignID = "trafficSource.adwordsClickInfo.campaignId as adwordsCampaignId",
                       adwordsAdGroupID = "trafficSource.adwordsClickInfo.adGroupId as adwordsAdGroupId",
                       # adwords...etc...
                       transactionId = "hits.transaction.transactionId as transactionId",
                       date = "date",
                       fullVisitorId = "fullVisitorId",
                       userId = "userId",
                       visitorId = "visitorId",
                       visitId = "visitId",
                       visitStartTime = "visitStartTime",
                       visitNumber = "visitNumber",
                       browser = "device.browser as browser",
                       browserVersion = "device.browserVersion as browserVersion",
                       operatingSystem = "device.operatingSystem as operatingSystem",
                       operatingSystemVersion = "device.operatingSystemVersion as operatingSystemVersion",
                       mobileDeviceBranding = "device.mobileDeviceBranding as mobileDeviceBranding",
                       flashVersion = "device.flashVersion as flashVersion",
                       language = "device.language as language",
                       screenColors = "device.screenColors as screenColors",
                       screenResolution = "device.screenResolution as screenResolution",
                       deviceCategory = "device.deviceCategory as deviceCategory",
                       continent = "geoNetwork.continent as continent",
                       subContinent = "geoNetwork.subContinent as subContinent",
                       country = "geoNetwork.country as country",
                       region = "geoNetwork.region as region",
                       metro = "geoNetwork.region as metro",
                       pagePath = "hits.page.pagePath as pagePath",
                       eventCategory = "hits.eventInfo.eventCategory as eventCategory",
                       eventAction = "hits.eventInfo.eventAction as eventAction",
                       eventLabel = "hits.eventInfo.eventLabel as eventLabel",
                       dimensionXX = {a function to output hit level custom dimensions})