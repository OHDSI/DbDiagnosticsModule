# Create a job context for testing purposes
# remotes::install_github("OHDSI/Strategus", ref="develop")
library(Strategus)
library(dplyr)
library(DbDiagnostics)
source("SettingsFunctions.R")

# Generic Helpers ----------------------------
getModuleInfo <- function() {
  checkmate::assert_file_exists("MetaData.json")
  return(ParallelLogger::loadSettingsFromJson("MetaData.json"))
}

# Create DbDianosticsModule settings ---------------------------------------

dbDiagnosticsSettings1 <- DbDiagnostics::createDataDiagnosticsSettings(
  analysisId = 1,
  analysisName = "Eunomia Test",
  minAge = 18,
  maxAge = NA,
  genderConceptIds = c(8532, 8507),
  raceConceptIds = NA,
  ethnicityConceptIds = NA,
  studyStartDate = NA,
  studyEndDate = NA,
  requiredDurationDays = 365,
  requiredDomains = c("condition","drug"),
  desiredDomains = NA,
  requiredVisits = NA,
  desiredVisits = NA,
  targetName = "Celecoxib",
  targetConceptIds = c(1118084),
  comparatorName = "Diclofenac",
  comparatorConceptIds = c(1124300),
  outcomeName = "GI Bleed",
  outcomeConceptIds = c(192671),
  indicationName = NA,
  indicationConceptIds = NA
)

dbDiagnosticsSettings <- list(dbDiagnosticsSettings1)

dbDiagnosticsModuleSpecifications <- createDbDiagnosticsModuleSpecifications(
  dataDiagnosticsSettings = dbDiagnosticsSettings
)

# Module Settings Spec ----------------------------
analysisSpecifications <- createEmptyAnalysisSpecificiations() %>%
  addModuleSpecifications(dbDiagnosticsModuleSpecifications)

executionSettings <-   Strategus::createResultsExecutionSettings(
  resultsConnectionDetailsReference = "dummy",
  resultsDatabaseSchema = "main",
  workFolder = "dummy",
  resultsFolder = "dummy",
  minCellCount = 5
)

# Job Context ----------------------------
module <- "DbDiagnosticsModule"
moduleIndex <- 1
moduleExecutionSettings <- executionSettings
moduleExecutionSettings$workSubFolder <- "dummy"
moduleExecutionSettings$resultsSubFolder <- "dummy"
moduleExecutionSettings$databaseId <- 123
jobContext <- list(
  sharedResources = analysisSpecifications$sharedResources,
  settings = analysisSpecifications$moduleSpecifications[[moduleIndex]]$settings,
  moduleExecutionSettings = moduleExecutionSettings
)
saveRDS(jobContext, "tests/testJobContext.rds")
