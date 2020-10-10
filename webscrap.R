## Install & Evoke packages
install.packages("rvest")
library(rvest)

# Loading websites to scrap data
url <- read_html("https://www.alexa.com/topsites/countries/IN")


Sites <- url %>% html_nodes(".DescriptionCell a") %>% html_text()
Dailytime <- url %>% html_nodes(".DescriptionCell+ .right p") %>% html_text()
DailyPageViews <-  url %>% html_nodes(".td:nth-child(4) p") %>% html_text()
Trafficpersearch <- url %>% html_nodes(".td:nth-child(5) p") %>% html_text()
Sitelinked <- url %>% html_nodes(".td:nth-child(6) p") %>% html_text()


# Creating a DataFrame
Alexatopsites <- data.frame(Sites, Dailytime, DailyPageViews, Trafficpersearch,Sitelinked)
View(Alexatopsites)

# Write the data to a file
getwd()
write.csv(Alexatopsites, file = "Alexa Top Sites.csv")
