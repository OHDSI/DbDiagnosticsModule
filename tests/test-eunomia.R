library(testthat)
library(Eunomia)
connectionDetails <- getEunomiaConnectionDetails()

workFolder <- tempfile("work")
dir.create(workFolder)
resultsfolder <- tempfile("results")
dir.create(resultsfolder)
jobContext <- readRDS("tests/testJobContext.rds")
jobContext$moduleExecutionSettings$workSubFolder <- workFolder
jobContext$moduleExecutionSettings$resultsSubFolder <- resultsfolder
jobContext$moduleExecutionSettings$resultsConnectionDetails <- connectionDetails

# # Create the db_profile_results
# sql <- "CREATE TABLE IF NOT EXISTS main.db_profile_results
# (
#     cdm_source_name character,
#     release_key character,
#     analysis_id integer,
#     stratum_1 character,
#     stratum_2 character,
#     stratum_3 character,
#     stratum_4 character,
#     stratum_5 character,
#     count_value numeric,
#     visit_concept_name character,
#     visit_ancestor_concept_id character,
#     visit_ancestor_concept_name character
# );
# "
# conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)
# DatabaseConnector::executeSql(connection = conn,
#                               sql = sql,
#                               progressBar = FALSE)
# DatabaseConnector::disconnect(conn)

# Run DBProfile on Eunomia
DbDiagnostics::executeDbProfile(connectionDetails = connectionDetails,
                                cdmDatabaseSchema = "main",
                                resultsDatabaseSchema = "main",
                                writeTo = "main",
                                vocabDatabaseSchema = "main",
                                cdmSourceName = "Eunomia")

test_that("Run module", {
  source("Main.R")
  #debugonce(execute)
  #debugonce(DbDiagnostics::executeDbDiagnostics)
  execute(jobContext)
  resultsFiles <- list.files(resultsfolder)
  expect_true("cg_cohort_definition.csv" %in% resultsFiles)
})

unlink(workFolder)
unlink(resultsfolder)
unlink(connectionDetails$server())
