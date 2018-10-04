# Which variable has more effect on Daily Time spent on website.

# Evoke the library
library(dplyr)

# Set the Path for data
setwd("H:\\Data Science\\Data Science\\R\\Projects\\Alexa")
getwd()
dataset<- read.csv("Alexa Top Sites.csv")
View(dataset)

# Checking the data for missing values
colSums(is.na(dataset))

# Converting into Factors
dataset$Sites<- factor(dataset$Sites)

# Removing comma, "%" & ":" sign and convert it into numeric
dataset <- dataset %>%
  mutate(Sitelink = as.numeric(gsub(",", "", dataset$Sitelinked))) %>%
  select(-c(X,Sitelinked))

dataset <- dataset %>%
  mutate(Avg_Traffic = as.numeric(gsub("%", "", dataset$Trafficpersearch))) %>%
  select(-Trafficpersearch)

dataset <- dataset %>%
  mutate(Avg_Time = as.numeric(gsub(":", ".", dataset$Dailytime))) %>%
  select(-Dailytime)



#Split- To divide the data into Train & Test to Train Our Model & then to test it
library(caTools)
set.seed(123)
split = sample.split(dataset$Avg_Time, SplitRatio = 0.8)
training_set= subset(dataset, split== TRUE)
testing_set = subset(dataset, split == FALSE)

# Fitting Multiple LinearRegression to the Traning Set
M_MLR = lm(formula = Avg_Time~., data = training_set)
summary(M_MLR)

# NA values are coming so Sites column can't be taken
M_MLR = lm(formula = Avg_Time~.-Sites, data = training_set)
summary(M_MLR)

# Check which variables have noise on others
library(car)
vif(M_MLR)

# Not able to Remove any Column as VIF has not more than 5
M_MLR = lm(formula = Avg_Time~. - Sites, data = training_set)
summary(M_MLR)

# Now Doing Forward Selection
M_MLR = lm(formula = Avg_Time~ + DailyPageViews, data = training_set)
summary(M_MLR)
# DailyPageViews has less p- value so we consider it in our Model

M_MLR = lm(formula = Avg_Time~ + DailyPageViews + Sitelink, data = training_set)
summary(M_MLR)
# Sitelink has higher p- value so we don't consider it in our Model

M_MLR = lm(formula = Avg_Time~ + DailyPageViews + Avg_Traffic, data = training_set)
summary(M_MLR)
# Avg_Traffic has higher p- value so we don't consider it in our Model

# Our Final Model has only one column DailyPageViews
M_MLR = lm(formula = Avg_Time~ + DailyPageViews, data = training_set)
summary(M_MLR)

# Predicting the Test Set results
Y_pred = predict(M_MLR,newdata = testing_set)
Y_pred
testing_set

# RMSE 
range(dataset$Avg_Time)
mean((training_set$Avg_Time-predict(M_MLR,newdata=training_set))**2, na.rm = TRUE) %>%
  sqrt()


# Visualizing Training Set results
library(ggplot2)
ggplot() +
  geom_point(aes(x=training_set$Avg_Time, y=training_set$DailyPageViews),
             color = "Red") + 
  geom_line(aes(x=training_set$Avg_Time, y=predict(M_MLR, newdata = training_set)),
            color = "Blue") +
  geom_abline() + 
  ggtitle("Avg Time Vs Daily Page Views (Training Set)") +
  xlab("Avg Time") +
  ylab("Daily Page Views")

# Visualizing Testing Set results
library(ggplot2)
ggplot() +
  geom_point(aes(x=testing_set$Avg_Time, y=testing_set$DailyPageViews),
             color = "Red") + 
  geom_line(aes(x=training_set$Avg_Time, y=predict(M_MLR, newdata = training_set)),
            color = "Blue") +
  geom_abline() + 
  ggtitle("Avg Time Vs Daily Page Views (Testing Set)") +
  xlab("Avg Time") +
  ylab("Daily Page Views")


plot(M_MLR, which = 1)
plot(M_MLR, which = 2)
abline(lm(Avg_Time~DailyPageViews, data = training_set))
plot(M_MLR, which = 3)
plot(M_MLR, which = 4)

# Time Spent on website by customers have only affected by DailyPageViews column.
