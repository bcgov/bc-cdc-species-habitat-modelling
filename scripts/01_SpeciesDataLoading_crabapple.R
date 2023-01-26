#01_SpeciesDataLoading_Crabapple

list.of.packages <- c("tidyverse", "lubridate","chron","bcdata", "bcmaps","sf", "rgdal", "readxl", "Cairo",
                      "OpenStreetMap", "ggmap","rgbif")
# Check you have them and load them
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

####################################
#Loading data from GBIF
# IF YOU HAVE ONLY ONE SPECIES ----
myspecies <- c("Malus fusca")

##################################
##################################
# IF YOU HAVE MORE THAN ONE SPECIES ----
#myspecies <- c("Galemys pyrenaicus", "Chioglossa lusitanica")
#gbif_citation(gbif_data)  # unfortunately it is more complicated to obtain with R a proper citation for a dataset with multiple species. To get a DOI for these data, download the dataset directly from www.gbif.org and then import the .csv to R. It is very important to properly cite the data sources! GBIF is not a source, just a repository for many people who put in very hard work to collect these data and make them available
##################################
##################################

# download GBIF occurrence data for this species; this takes time if there are many data points!
gbif_data <- occ_data(scientificName = myspecies, hasCoordinate = TRUE, limit = 20000, decimalLongitude = "-139.01451, -114.08890", decimalLatitude = "48.29752, 60")

# take a look at the downloaded data:
gbif_data

### - Convert to Spatial Layer

myspecies_coords <- gbif_data$data[ , c("decimalLongitude", "decimalLatitude", "individualCount", "occurrenceStatus", "coordinateUncertaintyInMeters", "institutionCode", "references")]

myspecies_coords <- st_as_sf(myspecies_coords, coords = c("decimalLongitude", "decimalLatitude"), crs = st_crs(4326))

##Save to Shape:
st_write(myspecies_coords,"R:/22.0253_SHM_Year2/Worked_Examples/Pacific_Crabapple/Data/Species_Inputs/Raw/crab_apple.shp",)

# if "Records found" is larger than "Records returned", you need to increase the 'limit' argument above -- see help(occ_data) for options and limitations

###################################
#If you have additional data, load it here:
###################################

#Here we load a geodatabase provided by Robyn Renton at the Ministry of Water, Land, and Resource Stewardship.
##This data includes species information for Western Skink (PLSK) and Coastal Tailed Frog (ASTR)
###First, load the data:

# The input file geodatabase
crab_apple <- "R:/22.0253_SHM_Year2/Worked_Examples/Pacific_Crabapple/Data/Species_Inputs/Raw/PacificCrabappleFromVPro/PacificCrabappleFromVPro.shp"

#Second, load the species data of interest - write function that automates this:
Crab_apple_occ <- sf::st_read(crab_apple)

#Look:
crab_apple_point_plot <- ggplot() +
  geom_sf(data = Crab_apple_occ) +
  geom_sf(data = myspecies_coords, aes(color = "red"))

write.