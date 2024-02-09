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
library(writexl)

# Specify the folder containing XML files
folder_path <- "search_result_colon_cancer_over18_jan22"

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
  
  # Check if intervention_type node exists
  intervention_type_nodes <- xml_find_all(trial_data, "//intervention/intervention_type")
  if (length(intervention_type_nodes) > 0) {
    intervention_type <- as.character(xml_text(intervention_type_nodes))
  } else {
    intervention_type <- rep("NA", length.out = ref_length)  # Placeholder for missing intervention_type
  }
  
  # Check if intervention_name node exists
  intervention_name_nodes <- xml_find_all(trial_data, "//intervention/intervention_name")
  if (length(intervention_name_nodes) > 0) {
    intervention_name <- as.character(xml_text(intervention_name_nodes))
  } else {
    intervention_name <- rep("NA", length.out = ref_length)  # Placeholder for missing intervention_name
  }
  
  url <- as.character(xml_text(xml_find_all(trial_data, "//required_header/url")))
  brief_summary <- as.character(xml_text(xml_find_all(trial_data, "//brief_summary")))
  eligibility <- as.character(xml_text(xml_find_all(trial_data, "//eligibility/criteria/textblock")))
  
  # Check if phase element exists before extracting
  phase_nodes <- xml_find_all(trial_data, "//phase")
  if (length(phase_nodes) > 0) {
    phase <- as.character(xml_text(phase_nodes))
  } else {
    phase <- "Placeholder"
  }
  
  # Use Intervention_Name for reference length
  ref_length <- length(intervention_name)
  
  # Replace empty strings with a placeholder for start_date
  if (all(start_date == "")) {
    start_date <- "Placeholder"
  }
  
  # Replace empty strings with a placeholder for intervention_name
  intervention_name <- ifelse(intervention_name == "", "NA", intervention_name)
  
  # Adjust other vectors to match the reference length
  brief_title <- rep(brief_title, length.out = ref_length)
  overall_status <- rep(overall_status, length.out = ref_length)
  start_date <- rep(start_date, length.out = ref_length)
  phase <- rep(phase, length.out = ref_length)
  url <- rep(url, length.out = ref_length)
  brief_summary <- rep(brief_summary, length.out = ref_length)
  eligibility <- rep(eligibility, length.out = ref_length)
  
  # Extract only the last part of the file path
  file_name <- basename(file_path)
  
  # Create a tibble for the current file
  trial_tibble <- tibble(
    File_Name = rep(file_name, length.out = ref_length),
    Title = brief_title,
    Status = overall_status,
    Start_Date = start_date,
    Phase = phase,
    Intervention_Type = intervention_type,
    Intervention_Name = intervention_name,
    URL = url,
    Brief_Summary = brief_summary,
    Eligibility = eligibility
  )
  
  # Add the tibble to the list
  tibbles_list[[file_path]] <- trial_tibble
}

# Combine all tibbles into a single large tibble
combined_tibble <- bind_rows(tibbles_list)

# Write the tibble to an Excel file
write_xlsx(combined_tibble, path = "search_result_data_colon_cancer_over18_jan22.xlsx")
