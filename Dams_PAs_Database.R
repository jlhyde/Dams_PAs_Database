##project goals: create database of dams and PAs in Brazil
install.packages("dplyr")
library(dplyr)

#import dams and PAs data
pas_data <- read.csv("./Database.csv", stringsAsFactors = FALSE, na.strings = "")
dams <- read.csv("./Dams_DB.csv", stringsAsFactors = FALSE, na.strings = "")

#add TI area to table
pas_df <- data.frame(pas_data)
TI_total_area <- read.csv("./TI_area_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_TI_area <- merge(pas_df, TI_total_area, by="Name", all=T)

#add TI never forested areas
TI_never <- read.csv("./TI_never_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_TI_never_area <- merge(PAs_TI_area, TI_never, by="Name", all=T)

##add TI deforested area
TI_def <- read.csv("./TI_def_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_all_TI_areas <- merge(PAs_TI_never_area, TI_def, by="Name", all=T)

#create data frame for UC area data and add to TI df
UC_total_area <- read.csv("./UC_area_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_TI_w_UC_area <- merge(PAs_all_TI_areas, UC_total_area, by="Name", all=T)

#add UC never deforested are
UC_never <- read.csv("./UC_never_final.csv", stringsAsFactors = FALSE, na.strings = "")
PAs_TI_UC_never_area <- merge(PAs_TI_w_UC_area, UC_never, by="Name", all=T)

#add deforested areas
UC_def <- read.csv("./UC_def_final.csv", stringsAsFactors = FALSE, na.strings = "")
pas_all_areas <- merge(PAs_TI_UC_never_area, UC_def, by="Name", all=T)

write.csv(pas_all_areas, file = "PAs_w_areas.csv", na = "")




## extract municipalities and creat seperate table of IDs and municipalities
munic_table <- data.frame(ID = pas_data$OBJECTID, Municipality = pas_data$Municipality,
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
