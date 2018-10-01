# Can we increase the daily time spent of visitors  on our website?

# Evoke the library
library(dplyr)

# Set the Path for data
setwd("_______________")
getwd()
dataset<- read.csv("Alexa Top Sites.csv")
View(dataset)

# Checking the data for missing values
colSums(is.na(dataset))

# Converting into Factors
dataset$Sites<- factor(dataset$Sites)

# Removing comma, "%" & ":" sign and convert it into numeric data type
dataset <- dataset %>%
  mutate(Sitelink = as.numeric(gsub(",", "", dataset$Sitelinked))) %>%
  select(-c(X,Sitelinked))

dataset <- dataset %>%
  mutate(Avg_Traffic = as.numeric(gsub("%", "", dataset$Trafficpersearch))) %>%
  select(-Trafficpersearch)

dataset <- dataset %>%
  mutate(Avg_Time = as.numeric(gsub(":", ".", dataset$Dailytime))) %>%
  select(-Dailytime)

# Creating Dummy Encoding
dataset <- dataset %>%
  mutate(Time_Spent = ifelse(dataset$Avg_Time<2, print(0), print(1))) %>%
  select(-Avg_Time)
  

# Split- To divide the data into Train & Test to Train Our Model & then to test it
library(caTools)
set.seed(123)
split = sample.split(dataset$Time_Spent, SplitRatio = 0.8)
training_set= subset(dataset, split== TRUE)
testing_set = subset(dataset, split == FALSE)

## Fitting the Model
model= glm(Time_Spent~., training_set, family= "binomial")
summary(model)

## NA values are there so remove the column Sites
model= glm(Time_Spent~.-Sites, training_set, family= "binomial")
summary(model)

# Calculating the best AIC(Akaike information criterion) value using step function 
model=step(model)

formula(model)

final_model= glm(Time_Spent~ DailyPageViews + Sitelink, training_set, family = "binomial")
summary(final_model)

## Predict the model on testing set
response_test= predict(final_model, testing_set, Time_Spent= "response")

## Package (ROCR) installed
library(ROCR)

pred= prediction(response, testing_set$Time_Spent)
perf= performance(pred,"tpr", "fpr")

plot(perf, colorize= T, print.cutoffs.at=seq(0.1, by=0.1))

## Now check the accuracy of the Model by Confusion Matrix
table(actualvalue=testing_set$Time_Spent, Predictedvalue= response>0.2)
Accuracy= (0+9)/(0+9+1+1)
Accuracy

## Predict the Model on Training data
response_training= predict(final_model, training_set, Time_Spent= "response")

## Package (ROCR) installed
library(ROCR)
train_pred= prediction(response_training, training_set$Time_Spent)
train_perf= performance(train_pred,"tpr", "fpr")

plot(train_perf, colorize= T, print.cutoffs.at=seq(0.1, by=0.1))

## Now check the accuracy of the Model by Confusion Matrix
table(actualvalue=training_set$Time_Spent, Predictedvalue= response_training>0.1)
Accuracy_train= (3+34)/(3+34+2+1)
Accuracy_train

## Now we can say that: Yes we can increase the time spent by customers on our page
   by focusing on these two parameters : DailyPageViews, Sitelink.
