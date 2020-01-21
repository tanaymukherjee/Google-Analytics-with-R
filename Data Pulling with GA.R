# Author: Tanay Mukherjee
# 2019-02-12

# setup
library(googleAnalyticsR)

# authenticate
ga_auth()

# get your accounts
account_list <- ga_account_list()

# account_list will have a column called "viewId"
account_list$viewId

# View account_list and pick the viewId you want to extract data from
ga_id <- 123456

# simple query to test connection
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


# anti_sample gets all results (max = -1)
gadata <- google_analytics(myID,
                           date_range = c(start_date, end_date),
                           metrics = "pageviews",
                           dimensions = "pageTitle",
                           segments = myseg,
                           anti_sample = TRUE)

# ----

# If you are using anti-sampling, it will always fetch all rows.
# This is because it won't make sense to fetch only the top results as the API
# splits up the calls over all days.
# If you want to limit it afterwards, use R by doing something like:

# limit to top 25
top_25 <- head(gadata[order(gadata$pageviews, decreasing = TRUE), ] , 25)


# Date Ranges
# You can send in dates in YYYY-MM-DD format:

google_analytics(868768, date_range = c("2016-12-31", "2017-02-01"), metrics = "sessions")

yesterday <- Sys.Date() - 1
ThreedaysAgo <- Sys.Date() - 3

google_analytics(868768, date_range = c(ThreedaysAgo, yesterday), metrics = "sessions")

google_analytics(868768, date_range = c("5daysAgo", "yesterday"), metrics = "sessions")

# Compare data ranges
google_analytics(868768, 
                 date_range = c("16daysAgo", "9daysAgo", "8daysAgo", "yesterday"), 
                 metrics = "sessions")

delta_sess <- order_type("sessions","DESCENDING", "DELTA")

# find top 20 landing pages that changed most in sessions comparing this week and last week
gadata <- google_analytics(gaid,
                           date_range = c("16daysAgo", "9daysAgo", "8daysAgo", "yesterday"),
                           metrics = c("sessions"),
                           dimensions = c("landingPagePath"),
                           order = delta_sess,
                           max = 20)

# Anti sampling

# Sampled data example
library(googleAnalyticsR)
ga_auth()
sampled_data_fetch <- google_analytics(id, 
                                       date_range = c("2015-01-01","2015-06-21"), 
                                       metrics = c("users","sessions","bounceRate"), 
                                       dimensions = c("date","landingPagePath","source"))



# Unsampled data example
library(googleAnalyticsR)
ga_auth()
unsampled_data_fetch <- google_analytics(id, 
                                         date_range = c("2015-01-01","2015-06-21"), 
                                         metrics = c("users","sessions","bounceRate"), 
                                         dimensions = c("date","landingPagePath","source"),
                                         anti_sample = TRUE)




# Cases when auto-anti sampling fails
# Use the following method to continue digging deeper

# example setting your own anti_sample_batch to 5 days per batch
unsampled_data_fetch <- google_analytics(id, 
                                         date_range = c("2015-01-01","2015-06-21"), 
                                         metrics = c("users","sessions","bounceRate"), 
                                         dimensions = c("date","landingPagePath","source"),
                                         anti_sample = TRUE,
                                         anti_sample_batch = 5)



# Filters
# One filter
campaign_filter <- dim_filter(dimension="campaign",operator="REGEXP",expressions="welcome")

my_filter_clause <- filter_clause_ga4(list(campaign_filter))

data_fetch <- google_analytics(ga_id,date_range = c("2016-01-01","2016-12-31"),
                               metrics = c("itemRevenue","itemQuantity"),
                               dimensions = c("campaign","transactionId","dateHour"),
                               dim_filters = my_filter_clause,
                               anti_sample = TRUE)

# Multiple filters
# create filters on metrics
mf <- met_filter("bounces", "GREATER_THAN", 0)
mf2 <- met_filter("sessions", "GREATER", 2)

# create filters on dimensions
df <- dim_filter("source","BEGINS_WITH","1",not = TRUE)
df2 <- dim_filter("source","BEGINS_WITH","a",not = TRUE)

# construct filter objects
fc2 <- filter_clause_ga4(list(df, df2), operator = "AND")
fc <- filter_clause_ga4(list(mf, mf2), operator = "AND")

# make v4 request
ga_data1 <- google_analytics(ga_id, 
                             date_range = c("2015-07-30","2015-10-01"),
                             dimensions=c('source','medium'), 
                             metrics = c('sessions','bounces'), 
                             met_filters = fc, 
                             dim_filters = fc2, 
                             filtersExpression = "ga:source!=(direct)")

ga_data1


# Multiple reports
# Demo of querying two API requests

# First request we make via make_ga_4_req()
multidate_test <- make_ga_4_req(ga_id, 
                                date_range = c("2015-07-30",
                                               "2015-10-01",
                                               "2014-07-30",
                                               "2014-10-01"),
                                dimensions = c('source','medium'), 
                                metrics = c('sessions','bounces'),
                                order = order_type("sessions", "DESCENDING", "DELTA"))

# Second request - same date ranges and ID required, but different dimensions/metrics/order.
multi_test2 <- make_ga_4_req(ga_id,
                             date_range = c("2015-07-30",
                                            "2015-10-01",
                                            "2014-07-30",
                                            "2014-10-01"),
                             dimensions=c('hour','medium'), 
                             metrics = c('visitors','bounces'))

# Request the two calls by wrapping them in a list() and passing to fetch_google_analytics()
ga_data3 <- fetch_google_analytics(list(multidate_test, multi_test2)) 
ga_data3


# Metric Expressions
# You need to use the ga: prefix when creating custom metrics, unlike normal API requests

my_custom_metric <- c(visitPerVisitor = "ga:visits/ga:visitors")

my_custom_metric <- c(visitPerVisitor = "ga:visits/ga:visitors")
ga_data4 <- google_analytics(ga_id,
                             date_range = c("2015-07-30",
                                            "2015-10-01"),
                             dimensions=c('medium'), 
                             metrics = c(my_custom_metric,
                                         'bounces'), 
                             metricFormat = c("FLOAT","INTEGER"))
ga_data4


# Segments
# v3 segments

# get list of segments
segs <- ga_segment_list()

# segment Ids and name:
segs[,c("name","id","definition")]


# choose the v3 segment
segment_for_call <- "gaid::-4"

# make the v3 segment object in the v4 segment object:
seg_obj <- segment_ga4("PaidTraffic", segment_id = segment_for_call)

# make the segment call
segmented_ga1 <- google_analytics(ga_id, 
                                  c("2015-07-30","2015-10-01"), 
                                  dimensions=c('source','medium','segment'), 
                                  segments = seg_obj, 
                                  metrics = c('sessions','bounces')
)


# or pass the segment v3 defintion in directly:
segment_def_for_call <- "sessions::condition::ga:medium=~^(cpc|ppc|cpa|cpm|cpv|cpp)$"

# make the v3 segment object in the v4 segment object:
seg_obj <- segment_ga4("PaidTraffic", segment_id = segment_def_for_call)

# make the segment call
segmented_ga1 <- google_analytics(ga_id, 
                                  c("2015-07-30","2015-10-01"), 
                                  dimensions=c('source','medium','segment'), 
                                  segments = seg_obj, 
                                  metrics = c('sessions','bounces')
)




# Demo: simple segment
se <- segment_element("sessions", 
                      operator = "GREATER_THAN", 
                      type = "METRIC", 
                      comparisonValue = 1, 
                      scope = "USER")

se2 <- segment_element("medium", 
                       operator = "EXACT", 
                       type = "DIMENSION", 
                       expressions = "organic")

# choose between segment_vector_simple or segment_vector_sequence
# Elements can be combined into clauses, which can then be combined into OR filter clauses
sv_simple <- segment_vector_simple(list(list(se)))

sv_simple2 <- segment_vector_simple(list(list(se2)))

# Each segment vector can then be combined into a logical AND
seg_defined <- segment_define(list(sv_simple, sv_simple2))

# Each segement defintion can apply to users, sessions or both.
# You can pass a list of several segments
segment4 <- segment_ga4("simple", user_segment = seg_defined)

# Add the segments to the segments param
segment_example <- google_analytics(ga_id, 
                                    c("2015-07-30","2015-10-01"), 
                                    dimensions=c('source','medium','segment'), 
                                    segments = segment4, 
                                    metrics = c('sessions','bounces')
)

segment_example


# Demo: Sequence segment

se2 <- segment_element("medium", 
                       operator = "EXACT", 
                       type = "DIMENSION", 
                       expressions = "organic")

se3 <- segment_element("medium",
                       operator = "EXACT",
                       type = "DIMENSION",
                       not = TRUE,
                       expressions = "organic")

# step sequence
# users who arrived via organic then via referral
sv_sequence <- segment_vector_sequence(list(list(se2), 
                                            list(se3)))

seq_defined2 <- segment_define(list(sv_sequence))

segment4_seq <- segment_ga4("sequence", user_segment = seq_defined2)

# Add the segments to the segments param
segment_seq_example <- google_analytics(ga_id, 
                                        c("2016-01-01","2016-03-01"), 
                                        dimensions=c('source','segment'), 
                                        segments = segment4_seq,
                                        metrics = c('sessions','bounces')
)

segment_seq_example


# Some more examples, using different match types:
con1 <-segment_vector_simple(list(list(segment_element("ga:dimension1", 
                                                       operator = "REGEXP", 
                                                       type = "DIMENSION", 
                                                       expressions = ".*", 
                                                       scope = "SESSION"))))

con2 <-segment_vector_simple(list(list(segment_element("ga:deviceCategory", 
                                                       operator = "EXACT", 
                                                       type = "DIMENSION", 
                                                       expressions = "Desktop", 
                                                       scope = "SESSION"))))

seq1 <- segment_element("ga:pagePath", 
                        operator = "EXACT", 
                        type = "DIMENSION", 
                        expressions = "yourdomain.com/page-path", 
                        scope = "SESSION")


seq2 <- segment_element("ga:eventAction", 
                        operator = "REGEXP", 
                        type = "DIMENSION", 
                        expressions = "english", 
                        scope = "SESSION",
                        matchType = "IMMEDIATELY_PRECEDES")

allSEQ <- segment_vector_sequence(list(list(seq1), list(seq2)))

results <- google_analytics(ga_id, 
                            date_range = c("2016-08-08","2016-09-08"),
                            segments = segment_ga4("sequence+condition",
                                                   user_segment = segment_define(list(con1,con2,allSEQ))
                            ),
                            metrics = c('ga:users'),
                            dimensions = c('ga:segment'))

# Users whose first session to website was social:
seg_social <- segment_element("channelGrouping",
                              operator = "EXACT",
                              type = "DIMENSION",
                              expressions = "Social")
seg_first_visit <- segment_element("sessionCount",
                                   operator = "EXACT",
                                   type = "DIMENSION",
                                   expressions = "1")
# social referrral followed by first sessionCount
segment_social_first <- segment_vector_sequence(list(list(seg_social), list(seg_first_visit)))
sd_segment <- segment_define(list(segment_social_first))
segment_social <- segment_ga4("social_first", user_segment = sd_segment)
segment_data <- google_analytics_4(my_viewId,
                                   date_range = c("8daysAgo", "yesterday"),
                                   metrics = c("sessions", "users", sessions_per_user = "ga:sessions/ga:users"),
                                   dimensions = c("date", "country", "channelGrouping", "sessionCount"),
                                   segments = segment_social,
                                   metricFormat = c("FLOAT", "INTEGER", "INTEGER"))


# RStudio Addin: Segment helper
# There is an RStudio Addin to help create segments via a UI rather than the lists above.

# You can call it via googleAnalyticsR:::ga
  

# Cohort reports

# first make a cohort group
cohort4 <- make_cohort_group(list("Jan2016" = c("2016-01-01", "2016-01-31"), 
                                  "Feb2016" = c("2016-02-01","2016-02-28")))

# then call cohort report.  No date_range and must include metrics and dimensions
#   from the cohort list
cohort_example <- google_analytics(ga_id, 
                                   dimensions=c('cohort'), 
                                   cohort = cohort4, 
                                   metrics = c('cohortTotalUsers'))

cohort_example


# Pivot Requests


# filter pivot results to 
pivot_dim_filter1 <- dim_filter("medium",
                                "REGEXP",
                                "organic|social|email|cpc")

pivot_dim_clause <- filter_clause_ga4(list(pivot_dim_filter1))

pivme <- pivot_ga4("medium",
                   metrics = c("sessions"), 
                   maxGroupCount = 4, 
                   dim_filter_clause = pivot_dim_clause)

pivtest1 <- google_analytics(ga_id, 
                             c("2016-01-30","2016-10-01"), 
                             dimensions=c('source'), 
                             metrics = c('sessions'), 
                             pivots = list(pivme))


names(pivtest1)


# GA360 Quota System
# If you have GA360, you have access to resource based quotas that increase the number of sessions before sampling kicks in from 1 to 100 million sessions.

# To access this quota, set useResourceQuotas = TRUE in the command.

google_analytics(ga_id, 
                 date_range = c("2017-01-01", "2017-03-01"), 
                 metrics = "sessions", 
                 dimensions = "date",
                 max = -1,
                 useResourceQuotas = TRUE)



# Customising API fetches
# Batching large results

google_analytics(ga_id, 
                 date_range = c("2017-01-01", "2017-03-01"), 
                 metrics = "sessions", 
                 dimensions = "date",
                 max = -1,
                 slow_fetch = TRUE)


# Caching
ga_cache_call("my_cache_folder")

# will make the call and save files to my_cache_folder
google_analytics(ga_id, 
                 date_range = c("2017-01-01", "2017-03-01"), 
                 metrics = "sessions", 
                 dimensions = "date",
                 max = -1)

# making the same exact call again will read from disk, and be much quicker
google_analytics(ga_id, 
                 date_range = c("2017-01-01", "2017-03-01"), 
                 metrics = "sessions", 
                 dimensions = "date",
                 max = -1)


# Rows per call
# making the same exact call again will read from disk, and be much quicker
google_analytics(ga_id, 
                 date_range = c("2017-01-01", "2017-03-01"), 
                 metrics = "sessions", 
                 dimensions = "date",
                 rows_per_call = 40000,
                 slow_fetch = TRUE,
                 max = -1)


# Fetching from multiple views
library(googleAnalyticsR)
library(future.apply)

# setup multisession R for your parallel data fetches 
plan(multisession)

# the ViewIds to fetch all at once
gaids <- c(12345634, 9888890,10624323)

my_fetch <- function(x) {
  google_analytics(x, 
                   date_range = c("2017-01-01","yesterday"), 
                   metrics = "sessions", 
                   dimensions = c("date","medium"))
}

# makes 3 API calls at once
all_data <- future_lapply(gaids, my_fetch)
