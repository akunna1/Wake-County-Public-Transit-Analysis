# -------------------------------
# 📦 Install and Load Libraries
# -------------------------------

# Uncomment and run this once if packages not installed
# packages <- c("tidytransit", "sf", "dplyr", "tidycensus", "ggplot2", "tmap", "units", "tidyr")
# lapply(packages, install.packages, character.only = TRUE)

library(tidytransit)
library(sf)
library(dplyr)
library(tidycensus)
library(ggplot2)
library(tmap)
library(units)
library(tidyr)

# Enable shapefile caching for tidycensus/tigris
options(tigris_use_cache = TRUE)

# -------------------------------
# 🚍 Load GTFS Data (GoRaleigh, 2025)
# -------------------------------

gtfs_path <- "C:/Users/User/Desktop/GIS_New/feb92025gtfsedit.zip"
gtfs <- read_gtfs(gtfs_path)

# Convert stops to spatial points
stops_sf <- gtfs$stops %>%
  filter(!is.na(stop_lat), !is.na(stop_lon)) %>%
  st_as_sf(coords = c("stop_lon", "stop_lat"), crs = 4326)

# -------------------------------
# 🗺️ Load Census Tracts (TIGER/Line Shapefile, 2022)
# -------------------------------

tracts_sf <- st_read("C:/Users/User/Desktop/GIS_New/tl_2022_37_tract/tl_2022_37_tract.shp")
wake_tracts_sf <- tracts_sf %>% filter(COUNTYFP == "183")  # Wake County FIPS

# -------------------------------
# 🌐 Load ACS Data (2022, No Geometry)
# -------------------------------

# Set your Census API key (run once)
census_api_key("9b273705a6c31dfaec55bc510a12dc8db0bea347", install = TRUE, overwrite = TRUE)

# Download ACS data
acs_data_no_geom <- get_acs(
  geography = "tract",
  state = "NC",
  county = "Wake",
  variables = c(
    income = "B19013_001",         # Median household income
    no_vehicle = "B08201_002",     # Households with no vehicle
    total_households = "B08201_001",
    household_size = "B25010_001"  # Average household size
  ),
  year = 2022,
  geometry = FALSE
)

# Reshape data
acs_summary <- acs_data_no_geom %>%
  select(GEOID, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(pct_no_vehicle = no_vehicle / total_households)

# -------------------------------
# 🧬 Join ACS Data with Tract Geometry
# -------------------------------

acs_joined <- wake_tracts_sf %>%
  left_join(acs_summary, by = "GEOID") %>%
  st_as_sf()

# -------------------------------
# 📏 Create Buffers Around Bus Stops
# -------------------------------

stops_proj <- st_transform(stops_sf, 3857)
stop_buffers <- st_buffer(stops_proj, dist = 400)
stop_buffers_wgs84 <- st_transform(stop_buffers, 4326)

# -------------------------------
# 🔍 Tag Tracts with Transit Access
# -------------------------------

acs_joined <- st_transform(acs_joined, st_crs(stop_buffers_wgs84))
acs_joined$has_transit_access <- st_intersects(acs_joined, stop_buffers_wgs84, sparse = FALSE) %>%
  rowSums() > 0

# -------------------------------
# 🎨 Common Map Layout Settings
# -------------------------------

common_layout <- tm_layout(
  frame = FALSE,
  fontfamily = "serif",
  legend.title.size = 1,
  legend.text.size = 0.8,
  legend.outside = TRUE,
  legend.outside.position = "right",
  title.size = 1.3,
  title.fontface = "bold",
  title.position = c("center", "top"),
  bg.color = "white",
  inner.margins = c(0.04, 0.04, 0.08, 0.02)
)

# -------------------------------
# 🗺️ Map 1: % Households Without Vehicles
# -------------------------------

map1 <- tm_shape(acs_joined) +
  tm_polygons("pct_no_vehicle", palette = "Blues", title = "% Households w/o Vehicle") +
  tm_shape(stop_buffers_wgs84) +
  tm_borders(col = "red", lwd = 1.2) +
  tm_add_legend(type = "line", col = "red", lwd = 2, label = "400m Buffer Around Bus Stops (Transit Access Zone)") +
  tm_layout(
    title = "Transit Access vs Car Ownership (2022)\nWake County Census Tracts + GoRaleigh 400m Buffers"
  ) +
  common_layout

# -------------------------------
# 🗺️ Map 2: Median Household Income
# -------------------------------

map2 <- tm_shape(acs_joined) +
  tm_polygons("income", palette = "Greens", title = "Median Income (USD)") +
  tm_shape(stop_buffers_wgs84) +
  tm_borders(col = "red", lwd = 1.2) +
  tm_add_legend(type = "line", col = "red", lwd = 2, label = "400m Buffer Around Bus Stops (Transit Access Zone)") +
  tm_layout(
    title = "Transit Access vs Median Income (2022)\nWake County Census Tracts + GoRaleigh 400m Buffers"
  ) +
  common_layout

# -------------------------------
# 🗺️ Map 3: Average Household Size
# -------------------------------

map3 <- tm_shape(acs_joined) +
  tm_polygons("household_size", palette = "Purples", title = "Avg Household Size") +
  tm_shape(stop_buffers_wgs84) +
  tm_borders(col = "red", lwd = 1.2) +
  tm_add_legend(type = "line", col = "red", lwd = 2, label = "400m Buffer Around Bus Stops (Transit Access Zone)") +
  tm_layout(
    title = "Transit Access vs Household Size (2022)\nWake County Census Tracts + GoRaleigh 400m Buffers"
  ) +
  common_layout

# -------------------------------
# 🖼️ Display Maps Separately
# -------------------------------

tmap_mode("plot")

print(map1)
print(map2)
print(map3)
