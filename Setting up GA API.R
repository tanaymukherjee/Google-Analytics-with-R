# Setting up GA API

# 1. Install
install.packages("googleAnalyticsR", dependencies = TRUE)

# Development version off GitHub
remotes::install_github("MarkEdmondson1234/googleAnalyticsR")

# Dependencies
# googleAnalyticsR requires the packages described in the Imports field of the DESCRIPTION file to be installed first, which it will do via install.packages("googleAnalyticsR", dependencies = TRUE)
 
# Note that on linux systems, due to its reliance on httr and in turn curl, it may require installation of these dependencies via apt-get or similar: libssl-dev and libcurl4-openssl-dev.
 
# If you install httpuv then the authentication flows will occur behind the scenes - this is normally installed by default but if you do not include it you will need to use the more manual OOB method to generate authentication tokens.
 

# 2. Make your first API call
## setup
library(googleAnalyticsR)

## This should send you to your browser to authenticate your email. 
# Authenticate with an email that has access to the 
# Google Analytics View you want to use.
ga_auth()

## get your accounts
account_list <- ga_account_list()

## account_list will have a column called "viewId"
account_list$viewId

## View account_list and pick the viewId you want to extract data from. 
ga_id <- 123456

## simple query to test connection, get 10 rows
google_analytics(ga_id,
                 date_range = c("2017-01-01", "2017-03-01"),
                 metrics = "sessions",
                 dimensions = "date",
                 max = 10)


# 3. Choose authentication method

# TL;DR
# Recommended long term defaults are:
#   
#   Create your own GCP project, download the client JSON and save to a global location, which you point to via a environment argument GAR_CLIENT_JSON in an .Renviron file e.g. GAR_CLIENT_JSON=~/dev/auth/client.json
# Authenticate with ga_auth(email="your@email.com") to create an authentication token cache, and repeat the ga_auth(email="your@email.com") call to default to that email in future API calls
# Set an environment argument GARGLE_EMAIL in the same .Renviron file to your email to auto-authenticate on package load e.g. GARGLE_EMAIL=your@email.com
# Details
# To access the GA API authentication is required.
# 
# The example in the previous section used the simplest among the three available ways to authenticate to the API. If you are planning to make systematic use of the API however, it's worth to know all the available options in order to choose the most suitable.
# 
# Note that no matter which method you use, the authentication is actually done via the googleAuthR package. In its documentation pages you can read more about advanced use cases.
# 
# To authenticate you need a client project (that authentication is performed through) and the user email to authenticate with (that gives access to that user's Google Analytics accounts)
# 
# Email authentication
# As of version googleAnalyticsR>=0.6.0.9000 authentication is done via the gargle package. This creates a global cache that is accessed via the email you authenticate with.
# 
# If you use ga_auth() the first time then it will ask you to create email credentials. You can then authenticate in the browser via your email. The next time you wish to authenticate, ga_auth() will give you an option to use those credentials again:


library(googleAnalyticsR)
ga_auth()


# 'Professional' mode: Your own Google Project

#Setting client.id from gar_auth_configure(path = json)
library(googleAnalyticsR)
ga_auth()

googleAuthR::gar_set_client("~/dev/auth/gcp_client.json")
library(googleAnalyticsR)
ga_auth()


options(googleAuthR.client_id = "uxxxxxxx2fd4kesu6.apps.googleusercontent.com")
options(googleAuthR.client_secret = "3JhLa_GxxxxxCQYLe31c64")
options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/analytics")


# clientId examples

googleAuthR::gar_set_client("~/dev/auth/gcp_client.json",
                            scopes = c("https://www.googleapis.com/auth/analytics",
                                       "https://www.googleapis.com/auth/webmasters"))

googleAuthR::gar_set_client(web_json = "~/dev/auth/gcp_web_client.json",
                            scopes = c("https://www.googleapis.com/auth/analytics",
                                       "https://www.googleapis.com/auth/webmasters"))



# 'Server' mode: Google Cloud service account


library(googleAuthR)
library(googleAnalyticsR)
gar_auth_service("your_auth_file.json")

# test authentication
al <- ga_account_list()



# 4 (optional): Review useful auth options

# Auto-authentication

# Multiple GA accounts
library(googleAnalyticsR)
ga_auth(email="mark@work.com")
client_one <- google_analytics(ga_id_one, 
                               date_range = my_date_range,
                               metrics = "sessions", 
                               dimensions = c("date", "medium"))

ga_auth(email="mark@work3.com")
client_one <- google_analytics(ga_id_two, 
                               date_range = my_date_range,
                               metrics = "sessions", 
                               dimensions = c("date", "medium"))


