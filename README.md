# Wake-County-Public-Transit-Analysis
Which Neighborhoods in Wake County, NC have the least access to public transit?

#### Links/Sources:
- https://goraleigh.org/developer-resources
- https://api.census.gov/data/key_signup.html
- https://www.census.gov/cgi-bin/geo/shapefiles/

#### Description:
This project analyzes public transit access in Wake County, NC, by focusing on the least accessible neighborhoods. The analysis utilizes the 2025 GoRaleigh GTFS data, which includes transit route information, bus stops, stop times, and route shapes, and combines it with the 2022 U.S. Census data. The goal is to identify areas with limited access to public transit and how various socioeconomic factors, such as car ownership, income levels, and household sizes, correlate with these areas.

For this project, the 2025 GTFS data is crucial as it provides insights into bus routes and service frequencies, while the 2022 Census data offers a comprehensive look at household characteristics within Wake County. By mapping out neighborhoods with limited transit access and overlaying socioeconomic data, the project aims to shed light on areas where the public transit infrastructure may need improvement. The analysis uses buffers around bus stops (400m radius) to determine which areas fall within transit reach and highlights neighborhoods that may face transportation challenges.

Future Improvements: Future improvements for this project could include expanding the analysis to include data from other transit systems in the region or integrating more granular demographic data from the Census. This would provide a deeper understanding of how transit access intersects with other factors and further inform decisions about transportation planning and development in Wake County. Additionally, using a crosswalk file to translate the 2022 Census data to 2025 estimates would align the demographic data with the latest transit data, improving the accuracy of the analysis and enhancing its relevance for future planning.


