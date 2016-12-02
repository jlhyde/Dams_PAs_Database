##project goals: create database of dams and PAs in Brazil
install.packages("dplyr")
library(dplyr)
library(stringr)

#import dams and PAs data
pas_data <- read.csv("R_Data/PA_Database.csv", stringsAsFactors = FALSE, na.strings = "")
dams <- read.csv("./Dams_DB.csv", stringsAsFactors = FALSE, na.strings = "")

#add TI area to table
pas_df <- data.frame(pas_data)
TI_total_area <- read.csv("R_Data/TI_area_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_TI_area <- merge(pas_df, TI_total_area, by="Name", all=T)

#add TI never forested areas
TI_never <- read.csv("R_Data./TI_never_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_TI_never_area <- merge(PAs_TI_area, TI_never, by="Name", all=T)

##add TI deforested area
TI_def <- read.csv("./TI_def_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_all_TI_areas <- merge(PAs_TI_never_area, TI_def, by="Name", all=T)

#create data frame for UC area data and add to TI df
UC_total_area <- read.csv("R_Data/UC_area_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_TI_w_UC_area <- merge(PAs_all_TI_areas, UC_total_area, by="Name", all=T)

#add UC never deforested are
UC_never <- read.csv("R_Data/UC_never_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_TI_UC_never_area <- merge(PAs_TI_w_UC_area, UC_never, by="Name", all=T)

#add deforested areas
UC_def <- read.csv("R_Data/UC_def_final.csv", stringsAsFactors = FALSE, na.strings = "")
pas_all_areas <- merge(PAs_TI_UC_never_area, UC_def, by="Name", all=T)

#export file to csv
write.csv(pas_all_areas, file = "PAs_w_areas.csv", na = "")

#import edited PAs file
new_pas_data <- read.csv("./PAs_w_areas_edited.csv", stringsAsFactors = FALSE, na.strings = "")

#fix caps
new_pas_data$Name <- str_to_title(new_pas_data$Name)

## extract municipalities and creat seperate table of IDs and municipalities
munic_table <- data.frame(ID = new_pas_data$OBJECTID, Municipality = new_pas_data$Municipality,
                          stringsAsFactors = FALSE)
#create empty dataframe
new_munic_table <- data.frame(ID = numeric(0),
                              Municipality = character(0))

for (i in 1:nrow(munic_table)){
  #create vector from strings in municipality column
  munic <- strsplit(munic_table[i,"Municipality"], ",")
  for(m in munic[[1]]){
    #reads through each vector and assigns it to cooresponding ID
    dummy <- data.frame(ID = numeric(1), Municipality = character(1))
    dummy$ID <- munic_table[i,"ID"]
    dummy$Municipality <- m
    new_munic_table <- rbind(new_munic_table, dummy)
  }
}

final_munic_table <- new_munic_table[!is.na(new_munic_table$Municipality),]

write.csv(final_munic_table, file = "PA_munic_table.csv")

# create table for PA IDs and managing organization or tribe

org_table <- data.frame(ID = new_pas_data$OBJECTID, 
                        Organization = new_pas_data$Organization_group_name,
                        stringsAsFactors = FALSE)
#create empty dataframe
new_org_table <- data.frame(ID = numeric(0),
                              Organization = character(0))

for (i in 1:nrow(org_table)){
  #create vector from strings in organization column
  org <- strsplit(org_table[i,"Organization"], ",")
  for(x in org[[1]]){
    #reads through each vector and assigns it to cooresponding ID
    dummy <- data.frame(ID = numeric(1), Organization = character(1))
    dummy$ID <- org_table[i,"ID"]
    dummy$Organization <- x
    new_org_table <- rbind(new_org_table, dummy)
  }
}

final_org_table <- new_org_table[!is.na(new_org_table$Organization),]

write.csv(final_org_table, file = "PA_org_table.csv")

##state and municipality table 
state_table <- data.frame(State = new_pas_data$State, Municipality = new_pas_data$Municipality,
                          stringsAsFactors = FALSE)
#create empty dataframe
new_state_table <- data.frame(State = character(0),
                              Municipality = character(0),
                              stringsAsFactors = FALSE)

for (i in 1:nrow(state_table)){
  #create vector from strings in municipality column
  munic <- strsplit(state_table[i,"Municipality"], ",")
  for(n in munic[[1]]){
    #reads through each vector and assigns it to cooresponding ID
    dummy <- data.frame(State = character(1), Municipality = character(1))
    dummy$State <- state_table[i,"State"]
    dummy$Municipality <- n
    new_state_table <- rbind(new_state_table, dummy)
  }
}

final_state_table <- new_state_table %>% 
  filter(!is.na(Municipality)) %>% 
  distinct()

##this file will be edited in Excel to remove instances where there are two states 
#in the same column, since I need to manually determine which state has which corresponding municipality
write.csv(final_state_table, file = "state_munic_table.csv")