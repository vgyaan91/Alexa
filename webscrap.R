# Install the Package rvest
install.packages("rvest")
## Evoke packages
library(rvest)

# Load the website to scrap data
dataset <- read_html("https://www.alexa.com/topsites/countries/IN")

# Now Select the node by using Selector Gadget or inspect option
Sites <- dataset %>% html_nodes("p a") %>% html_text()
Dailytime <- dataset %>% html_nodes(".DescriptionCell+ .right p") %>% html_text()
DailyPageViews <-  dataset %>% html_nodes(".right:nth-child(4) p") %>% html_text()
Trafficpersearch <- dataset %>% html_nodes(".right:nth-child(5) p") %>% html_text()
Sitelinked <- dataset %>% html_nodes(".right:nth-child(6) p") %>% html_text()

# Creata a DataFrame from Scraped Data
Alexatopsites <- data.frame(Sites, Dailytime, DailyPageViews, Trafficpersearch,Sitelinked)
View(Alexatopsites)

# Write the data to a file
getwd()
write.csv(Alexatopsites, file = "Alexa Top Sites.csv")



