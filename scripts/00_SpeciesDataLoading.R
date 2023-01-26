#01_SpeciesDataLoading_westernskink

list.of.packages <- c("tidyverse", "lubridate","chron","bcdata", "bcmaps","sf", "rgdal", "readxl", "Cairo",
                      "OpenStreetMap", "ggmap","rgbif")
# Check you have them and load them
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

####################################
#Loading data from GBIF
# IF YOU HAVE ONLY ONE SPECIES ----
myspecies <- c("Plestiodon skiltonianus")

##################################
##################################
# IF YOU HAVE MORE THAN ONE SPECIES ----
#myspecies <- c("Galemys pyrenaicus", "Chioglossa lusitanica")
#gbif_citation(gbif_data)  # unfortunately it is more complicated to obtain with R a proper citation for a dataset with multiple species. To get a DOI for these data, download the dataset directly from www.gbif.org and then import the .csv to R. It is very important to properly cite the data sources! GBIF is not a source, just a repository for many people who put in very hard work to collect these data and make them available
##################################
##################################

# download GBIF occurrence data for this species; this takes time if there are many data points!
gbif_data <- occ_data(scientificName = myspecies, hasCoordinate = TRUE, limit = 20000, decimalLongitude = "-124, -114", decimalLatitude = "49, 50")

# take a look at the downloaded data:
gbif_data

# if "Records found" is larger than "Records returned", you need to increase the 'limit' argument above -- see help(occ_data) for options and limitations

###################################
#If you have additional data, load it here:
###################################

#Here we load a geodatabase provided by Robyn Renton at the Ministry of Water, Land, and Resource Stewardship.
##This data includes species information for Western Skink (PLSK) and Coastal Tailed Frog (ASTR)
###First, load the data:

# The input file geodatabase
fgdb <- "data/ModelData.gdb/ModelData.gdb"

# List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list <- ogrListLayers(fgdb)
print(fc_list)

#Second, load the species data of interest - write function that automates this:
fc_PLSK_range <- sf::st_read(fgdb, layer = fc_list[[1]])
fc_PLSK_EO <- sf::st_read(fgdb, layer = fc_list[[3]])
fc_PLSK_EO_Ext <- sf::st_read(fgdb, layer = fc_list[[4]])
fc_PLSK_WSI_SO <- sf::st_read(fgdb, layer = fc_list[[5]])
fc_PLSK_iNat_obsc <- sf::st_read(fgdb, layer = fc_list[[6]])

##Take a look?
ggplot() +
  geom_sf(data = fc_PLSK_range) +
  geom_sf(data = fc_PLSK_EO_Ext) +
  geom_sf(data = fc_PLSK_EO) +
  geom_sf(data = fc_PLSK_WSI_SO, color = "blue") +
  geom_sf(data = myspecies_coords, color = "red") 


#################################################
### - Convert to Spatial Layer

myspecies_coords <- gbif_data$data[ , c("decimalLongitude", "decimalLatitude", "individualCount", "occurrenceStatus", "coordinateUncertaintyInMeters", "institutionCode", "references")]

myspecies_coords <- st_as_sf(myspecies_coords, coords = c("decimalLongitude", "decimalLatitude"), crs = st_crs(4326))


#####################################################################################
###--- Import spatial files
# Set study region as BC / Central Okanagan
bc <- bc_bound()
bc_latlon <- st_transform(bc, crs=4326)
ca_box <- st_bbox(bc_latlon)

CO <- nr_districts() %>% filter(ORG_UNIT %in% c("DOS", "DRM", "DCS", "DSE"))
CO_latlon <- st_transform(CO, crs=4326)
st_bbox(CO_latlon)

###################################################
### - VIsualize the data

ggplot() +
  #geom_sf(data = bc,  color = "blue", fill = NA, lwd=1.5) +
  geom_sf(data = CO, color = "black", fill = NA, lwd = 0.5) +
  geom_sf(data = myspecies_coords, color = "red") #+
  #coord_sf(datum = NA) +
  #theme_minimal()

# get the DOIs for citing these data properly:
gbif_cit <- gbif_citation(gbif_data)
# These citations MUST be included in documentation - How to automate? 

## to see how the data are organized:
# names(gbif_data)
# names(gbif_data$meta)
# names(gbif_data$data)

# CLEAN THE DATASET! ----
names(myspecies_coords)
sort(unique(myspecies_coords$individualCount))  # notice if some points correspond to zero abundance
sort(unique(myspecies_coords$occurrenceStatus))  # check for different indications of "absent", which could be in different languages! and remember that R is case-sensitive

#################################################
#IF ABSENCE FOUND:
#################################################
# absence_rows <- which(myspecies_coords$individualCount == 0 | myspecies_coords$occurrenceStatus %in% c("absent", "Absent", "ABSENT", "ausente", "Ausente", "AUSENTE"))
# length(absence_rows)
# if (length(absence_rows) > 0) {
#   myspecies_coords <- myspecies_coords[-absence_rows, ]
# }


