# script for extracting clinical trial information from clinical trials.gov(classic)
library(ctrdata)
citation("ctrdata")
# Please review and respect register copyrights:
ctrOpenSearchPagesInBrowser(
  copyright = TRUE
)
# Open browser with example search:CTGOV (CLASSIC), CTGOV2 (NEWEST VERSION)
ctrOpenSearchPagesInBrowser(
  url ="age=over-18&blood&cmml",
  register = "CTGOV"
)

q <- ctrGetQueryUrl("https://classic.clinicaltrials.gov/ct2/results?age=under-18&blood&aml&flt3&term=npm1")
db <- nodbi::src_sqlite(
  dbname = "some_database_name.sqlite_file",
  collection = "some_collection_name"
)
ctrLoadQueryIntoDb(
  queryterm = q,
  euctrresults = TRUE,
  con = db
)
qSs
ctrOpenSearchPagesInBrowser(url = q)
# Count number of trial records
ctrLoadQueryIntoDb(
  queryterm = q,
  only.count = TRUE
)$n

db <- nodbi::src_sqlite(
  dbname = "sqlite_file.sql",
  collection = "test"
)

# Show which queries have been downloaded into database
dbQueryHistory(con = db)
result <- dbGetFieldsIntoDf(
  fields = c(
    "a7_trial_is_part_of_a_paediatric_investigation_plan",
    "p_end_of_trial_status",
    "a2_eudract_number"
  ),
  con = db
)

#find fields
dbFindFields(namepart = "date", con = db)

#view specific record using jsonview. this will have to be installed from github
# remotes::install_github("https://github.com/hrbrmstr/jsonview")
#result <- dbGetFieldsIntoDf("clinical_results.outcome_list.outcome", db)
#jsonview::json_tree_view(result[["clinical_results.outcome_list.outcome"]][
#result[["_id"]] == "NCT00520936"
#])

