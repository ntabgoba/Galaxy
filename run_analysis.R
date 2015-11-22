# Clean up workspace
rm(list=ls())

getwd()
setwd("/Users/ntabgoba/Desktop/Galaxy")
list.files()

#Download the file and put the in file in the data folder

if(!file.exists("./sumsung")){dir.create("./sumsung")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./sumsung/Dataset.zip",method="curl")

#Unzip the file
unzip(zipfile="./sumsung/Dataset.zip",exdir="./sumsung")

#Get the list of the files from unzipped files (are in the folder UCI HAR Dataset). 

path_rf <- file.path("./sumsung" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

#Read data from the the targeted files

#Read activity files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

#Read Subject files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#Read Feature files
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

### Look at properties of above variables
str(dataActivityTest)

str(dataActivityTrain)

str(dataSubjectTrain)

str(dataFeaturesTest)

str(dataFeaturesTrain)

###MERGEs the training and tests sets to create one dataset
#1.Concatenate the data tables by rows

dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#2.Set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#3.Merge columns to get the data frame Data for all data

dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

###Extracts on the measurements on the mean and standard deviation for each measurement

#1.Subset Name of Features by measurements on the mean and s.d
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#2.Subset the data frame Data by seletected names of features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#3. Check the structures of the data frame Data
str(Data)

###Use descriptive activity names to name the activities in the data set
#1.Read descriptive activity names from "activity_label.txt"
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
#2.factorize variable Activity in the data frame Data using descriptive activity names
head(Data$activity,30)

## Label appropriately the data set with descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

names(Data)

##Create a second,independent tidy data set and output it
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

head(Data2)

## Produced Codebook
library(knitr) 
##########################################################################################################