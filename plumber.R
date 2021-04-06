#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

# library(plumber)
require(plumber)
require(jsonlite)
require(stringr)
require(dplyr)
require(RSQLite)

#* @apiTitle dECMT Cancer Trial Match API

## connect to database
driver <- dbDriver("SQLite")
con <- dbConnect(driver,"trialMatchData.sqlite")


#* get studies matched on condition alone
#* @param condition
#* @get /getStudiesMatchedOnCondition
function(condition) {
  ## if multiple conditions have been passed, split
  condition <- unlist(strsplit(condition, split = ","))
  ## trim whitespace, if any
  condition <- str_squish(condition)
  ## collapse for SQL query
  condition <- paste0("('",paste(condition, collapse = "','"), "')")
  ## form query
  query <- paste0("SELECT * FROM cancerStudies WHERE TARGET_condition IN ", condition)
  ## query database
  studies <- dbGetQuery(con, query)
  ## return studies as a JSON file
  toJSON(studies)
}








# Disconnect from SQLite database
#dbDisconnect(con)




# #* Echo back the input
# #* @param msg The message to echo
# #* @get /echo
# function(msg = "") {
#     list(msg = paste0("The message is: '", msg, "'"))
# }
# 
# #* Plot a histogram
# #* @png
# #* @get /plot
# function() {
#     rand <- rnorm(100)
#     hist(rand)
# }
# 
# #* Return the sum of two numbers
# #* @param a The first number to add
# #* @param b The second number to add
# #* @post /sum
# function(a, b) {
#     as.numeric(a) + as.numeric(b)
# }
