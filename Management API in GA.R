# Management API

# The Management API v3 covers all API calls that are not data reporting related and are for
# getting meta information about your Google Analytics account or to change account settings.

# Account structure

# The most day-to-day useful function is ga_account_list() which 
# summarises all account web properties and views available to your user.

# ga_account_list() - Get account summary including the ViewId
# ga_accounts() - Get account metadata for your user
# ga_webproperty() - Get web property
# ga_webproperty_list() - List web properties for a particular accountId
# ga_view() - Get single View (Profile)
# ga_view_list() - List Views (Profile) for a particular accountId/webPropertyId


# ga_account_list is most commonly used
# (restricted to top 10 with the head() function)
head(ga_account_list(), n = 10)


# this only lists account meta-data
ga_accounts()



# this gives meta-data for all web-properties for this accountId
ga_webproperty_list(47480439)



# this is meta-data for one particular web-property
ga_webproperty(accountId = 47480439, webPropertyId = "UA-47480439-1")



# this is meta-data for the views under this accountId/webPropertyId
ga_view_list(accountId = 47480439, webPropertyId = "UA-47480439-1")



# this is meta-data for this particular viewId (profileId)
ga_view(accountId = 47480439, webPropertyId = "UA-47480439-1", profileId = 81416941)



# Helper functions

# you can just use `meta` as is to get the available metrics,
# here we just return the first 5 columns and rows for brevity
head(meta[,1:5])



# or ensure an up to date version by calling the metadata API.
head(ga_meta())[,1:5]



# use `aggregateGAData` so you can on the fly create summary data
ga_data <- google_analytics(81416156, 
                            date_range = c("10daysAgo", "yesterday"),
                            metrics = c("sessions","bounceRate"), dimensions = c("hour","date"))



head(ga_data)



# if we want totals per hour over the dates:
ga_aggregate(ga_data[,c("hour","sessions")], agg_names = "hour")



# it knows not to sum metrics that are rates:
ga_aggregate(ga_data[,c("hour","bounceRate")], agg_names = "hour")



amd <- ga_allowed_metric_dim()
head(amd)



# User management
# ga_users_list() - list user access to your Google Analytics accounts, web properties or views
# ga_users_delete() - delete user access via email
# ga_users_delete_linkid() - delete user access via the linkId
# ga_users_add() - add users to accounts
# ga_users_update() - update a user


# default will list all users that match the id you supply
ga_users_list(47480439)
ga_users_list(47480439, webPropertyId = "UA-47480439-2")
ga_users_list(47480439, webPropertyId = "UA-47480439-2", viewId = 81416156)

# only list users who have account level access
ga_users_list(47480439, webPropertyId = NULL, viewId = NULL)
# only list users who have webProperty and above access
ga_users_list(47480439, webPropertyId = "UA-47480439-2", viewId = NULL)



ga_users_add(c("the_email@company.com", "another_email@company.com"), 
             permissions = "EDIT", accountId = 47480439)



ga_users_list(47480439)

ga_users_delete("the_email@company.com", 47480439)

# delete many emails at once
ga_users_delete(c("the_email@company.com", "another_email@company.com"), accountId = 47480439)



# get the linkId for the user you want to delete
ga_users_list(47480439, webPropertyId = "UA-47480439-2", viewId = 81416156)
ga_users_delete_linkid("81416156:114834495587136933146", 47480439, 
                       webPropertyId = "UA-47480439-2", viewId = 81416156)

# check its gone
ga_users_list(47480439, webPropertyId = "UA-47480439-2", viewId = 81416156)

# can only delete at level user has access, the above deletion woud have failed if via:
ga_users_delete_linkid("47480439:114834495587136933146", 47480439)



# the update to perform
o <- list(permissions = list(local = list("EDIT")))



ga_users_update("UA-123456-1:1111222233334444",
                update_object = o,
                accountId = 123456,
                webPropertyId = "UA-123456-1")



# the update to perform
o <- list(permissions = list(local = list("EDIT")))

ga_users_update("UA-123456-1:1111222233334444",
                update_object = o,
                accountId = 123456,
                webPropertyId = "UA-123456-1")



# Custom variables
# Custom variable management for a Google Analytics property.
# 
# ga_custom_vars() - get meta data for a specific custom variable
# ga_custom_vars_list() - list all custom dimensions or metrics
# ga_custom_vars_create() - create a new custom variable
# ga_custom_vars_patch() - update an existing custom variable


# create custom var
ga_custom_vars_create("my_custom_dim",
                      index = 15,
                      accountId = 54019251,
                      webPropertyId = "UA-54019251-4",
                      scope = "HIT",
                      active = FALSE)

# view custom dimension in list
ga_custom_vars_list(54019251, webPropertyId = "UA-54019251-4", type = "customDimensions")

# change a custom dimension
ga_custom_vars_patch("ga:dimension7",
                     accountId = 54019251,
                     webPropertyId = "UA-54019251-4",
                     name = "my_custom_dim2",
                     scope = "SESSION",
                     active = TRUE)

# view custom dimensions again to see change
ga_custom_vars_list(54019251, webPropertyId = "UA-54019251-4", type = "customDimensions")



# AdWords
# ga_adwords() Get Google Analytics - AdWords Link meta data
# ga_adwords_list() List AdWords
# ga_adwords_add_linkid() Create a link between and Adwords (Google ads) account and a Google Analytics property
# ga_adwords_delete_linkid() Delete a Google Analytics webProperty-Google Ads link


# Lists webProperty-Google Ads links
ga_adwords_list(accountId = 65973592, webPropertyId = "UA-65973592-1")

# Get information about a web property-Google Ads link 
ga_adwords(accountId = 65973592, webPropertyId = "UA-65973592-1", webPropertyAdWordsLinkId = "QrcfI2DTSMayqbrLiHYUqw")

# establish a new link between GA and Adwords
ga_adwords_add_linkid(adwordsAccountId = "280-234-7592", linkName = "Google Ads Link", accountId = "65973592", webPropertyId = "UA-65973592-1")

#check that it has been added
ga_adwords_list(accountId = 65973592, webPropertyId = "UA-65973592-1")

# delete the link
ga_adwords_delete_linkid(accountId  = 65973592, webPropertyId ="UA-65973592-1", webPropertyAdWordsLinkId = "ezW2dyaiQcGheWRAo69nCw")

#check that the link has been removed
ga_adwords_list(accountId = 65973592, webPropertyId = "UA-65973592-1")



# Custom Data Sources
# See and upload custom data sources to Google Analytics
# 
# ga_custom_datasource() - List Custom Data Sources
# ga_custom_upload() - Custom Data Source Upload Status
# ga_custom_upload_file()- Upload a file to GA custom uploads
# ga_custom_upload_list() - List the files in a GA custom upload
# Experiments
# ga_experiment() - Experiments Meta data
# ga_experiment_list() - List Experiments
# View Filters
# The filter edit functions are contributed by @zselinger which allow you to update filters for your Google Analytics views at scale.
# 
# ga_filter() - Get specific filter for account
# ga_filter_add() - Create a new filter and add it to the view (optional).
# ga_filter_apply_to_view() - Apply an existing filter to view.
# ga_filter_delete() - Delete a filter from account or remove from view.
# ga_filter_list() - List filters for account
# ga_filter_update() - Updates an existing filter.
# ga_filter_update_filter_link() - Update an existing profile filter link. Patch semantics supported
# ga_filter_view() - Get specific filter for view (profile)
# ga_filter_view_list() - List filters for view (profile)
# Goals
# ga_goal() - Get goal
# ga_goal_list() - List goals
# ga_goal_add() - Create and add Goals to a web property
# ga_goal_update() - Modify an existing goal



# Example: Copying GA goals

# Auth and setup

library(tidyverse)
library(stringr)
library(rlist)

# Copying a single goal

# 1. Retrieve the accountId, webPropertyId and viewId from our source GA view

# Account info and list of goals for source, to be copied
source_account <- ga_account_list() %>% 
  filter(str_detect(accountName, "Demo Account"), str_detect(viewName, "Master"))
source_account


# 2. Get a list of the goals currently configured from our source GA view

source_goals <- ga_goal_list(source_account$accountId, source_account$webPropertyId, source_account$viewId)
source_goals


# 3. Retrieve the accountId, webPropertyId and viewId from our destination GA view

# Account info for destination account
dest_account <- ga_account_list() %>% 
  filter(str_detect(accountName, "Your_Account"), str_detect(viewName, "Filtered"))


# 4. Get the configuration details of a single goal to be copied.
# Get goal ID 1
goal_one <- ga_goal(source_account$accountId, source_account$webPropertyId, source_account$viewId, 
                    goalId = 1) %>% 
  # Strip out instance-specific metadata (property, profile, view data and original creation dates)
  list.remove( c("accountId", "webPropertyId", "selfLink", "internalWebPropertyId", "profileId", "parentLink", "created", "updated"))

goal_one



# 5. Submit the goal details to our destination property.

ga_goal_add(goal_one, dest_account$accountId, dest_account$webPropertyId, dest_account$viewId)


# 6.Copying multiple goals

# For each goal ID in our source view, apply the copy_goal function, 
# using source_account and dest_account account parameters as fixed 2nd / third arguments
map(source_goals$id, copy_goal, source_account, dest_account)




# Write request limits
# At the time of writing, there is a daily limit of 50 write requests per day,
# per Google Cloud project, which restricts the number of times this can be performed.
# However, it is possible to request that this limit be increased.

# Remarketing segments
# Remarketing segments lets you target users in Google Ads from Google Analytics segments.
# 
# ga_remarketing_estimate() - Estimate number of users added to the segment yesterday
# ga_remarketing_get() - Get a remarketing audience
# ga_remarketing_list() - List remarketing audiences
# ga_remarketing_build() - Create definitions to be used within ga_remarketing_create()
# ga_remarketing_create() - Create a remarketing audience

adword_list <- ga_adwords_list(123456, "UA-123456-1")

adword_link <- ga_adword(adword_list$id[[1]])

segment_list <- ga_segment_list()$items$definition

my_remarketing1 <- ga_remarketing_build(segment_list[[1]], 
                                        state_duration = "TEMPORARY",
                                        membershipDurationDays = 90, 
                                        daysToLookBack = 14)
my_remarketing2 <- ga_remarketing_build(segment_list[[2]], 
                                        state_duration = "PERMANENT",
                                        membershipDurationDays = 7, 
                                        daysToLookBack = 31)

# state based only can include exclusions
ga_remarketing_create(adwords_link = adword_link,
                      include = my_remarketing1, exclude = my_remarketing2,
                      audienceType = "STATE_BASED", name = "my_remarketing_seg1")



# Unsampled reports
# Available only for GA360 accounts, you will need to authenticate with the Google drive scope to get download access. 
# 
# ga_unsampled() - Get Unsampled Report Meta Data
# ga_unsampled_download() - Download Unsampled Report from Google Drive
# ga_unsampled_list() - List Unsampled Reports
# 
# Users
# ga_clientid_hash() - Creates the clientID hash that is used in BigQuery GA360 exports
# ga_clientid_deletion() - Delete a website visitor from Google Analytics