#parseXML_gillian_attempt2
#--------------------------
# parseXML_gillian_attempt was my first try at extracting nodes from XML files,
# and I realized that there is a better way I could be utilizing the XML/xml2 packages
# so I am using this script as a second try to extract all nodes from each XML file,
# and then use manipulation to format the data.
#-------------------------
library(xml2)
library(tibble)
library(dplyr)
library(stringr)

# Function to extract and mutate intervention types
mutate_intervention <- function(intervention) {
  intervention_type <- str_extract(intervention, "(Drug|Behavioral|Device|Procedure|Genetic|Other|Dietary|Radiation|Biological|Diagnostic Test)")
  intervention_treatment <- str_replace(intervention, "(Drug|Behavioral|Device|Procedure|Genetic|Other|Dietary|Radiation|Biological|Diagnostic Test)", "")
  
  return(tibble(
    Intervention_Type = intervention_type,
    Intervention_Treatment = intervention_treatment
  ))
}

# Specify the folder containing XML files
folder_path <- "search_result_lung_cancer_nonsmall_over18_feb6"

# Get a list of all XML files in the folder
xml_files <- list.files(folder_path, pattern = "\\.xml$", full.names = TRUE)

# Initialize an empty list to store individual tibbles
tibbles_list <- list()

# Loop through each XML file
for (file_path in xml_files) {
  # Read the file using xmlTreeParse
  trial_data <- read_xml(file_path)
  
  # Extract elements using xml_find_all and simplify the results
  brief_title <- as.character(xml_text(xml_find_all(trial_data, "//brief_title")))
  overall_status <- as.character(xml_text(xml_find_all(trial_data, "//overall_status")))
  start_date <- as.character(xml_text(xml_find_all(trial_data, "//start_date")))
  intervention <- as.character(xml_text(xml_find_all(trial_data, "//intervention")))
  url <- as.character(xml_text(xml_find_all(trial_data, "//required_header/url")))
  brief_summary <- as.character(xml_text(xml_find_all(trial_data, "//brief_summary")))
  eligibility <- as.character(xml_text(xml_find_all(trial_data, "//eligibility/criteria/textblock")))
  
  # Check if phase element exists before extracting
  phase_nodes <- xml_find_all(trial_data, "//phase")
  if (length(phase_nodes) > 0) {
    phase <- as.character(xml_text(phase_nodes))
  } else {
    phase <- "Placeholder"  # or any other default value you want to assign when the element is not present
  }
  
  # Determine the reference length (using Intervention column)
  ref_length <- length(intervention)
  
  # Replace empty strings with a placeholder for start_date
  if (all(start_date == "")) {
    start_date <- "Placeholder"
  }
  
  # Adjust other vectors to match the reference length
  brief_title <- rep(brief_title, length.out = ref_length)
  overall_status <- rep(overall_status, length.out = ref_length)
  start_date <- rep(start_date, length.out = ref_length)
  phase <- rep(phase, length.out = ref_length)
  url <- rep(url, length.out = ref_length)
  brief_summary <- rep(brief_summary, length.out = ref_length)
  eligibility <- rep(eligibility, length.out = ref_length)
  
  # Apply intervention mutation function
  intervention_mutated <- mutate_intervention(intervention)
  
  # Extract only the last part of the file path
  file_name <- basename(file_path)
  
  # Create a tibble for the current file
  trial_tibble <- tibble(
    File_Name = rep(file_name, length.out = ref_length),
    Title = brief_title,
    Status = overall_status,
    Start_Date = start_date,
    Phase = phase,
    Intervention_Type = intervention_mutated$Intervention_Type,
    Intervention_Treatment = intervention_mutated$Intervention_Treatment,
    URL = url,
    Brief_Summary = brief_summary,
    Eligibility = eligibility
  )
  
  # Add the tibble to the list
  tibbles_list[[file_path]] <- trial_tibble
}

# Combine all tibbles into a single large tibble
combined_tibble <- bind_rows(tibbles_list)

# Recruit tibble
# recruit_tibble <- combined_tibble %>%
#   filter(Status == "Recruiting")

# Write the tibble to a CSV file
write.csv(combined_tibble, file = "parsed_result_lung_cancer_nonsmall_over18_feb6.csv", row.names = FALSE)
