###############################
### Cleaning Data -Coursera ###
########## Project ############
###############################
.libPaths("C:/R-3.3.1/library")
.libPaths() 
install.packages("plyr", lib="C:/R-3.3.1/library")
#install.packages("knitr", lib="C:/R-3.3.1/library")
install.packages("memisc", lib="C:/R-3.3.1/library")
library(plyr);
#library(knitr)
library(memisc)


############################
### Downloading the data ###
############################
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

#Unizip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#Create a path/folder "UCI HAR Dataset" for unzipped files
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

#Reading files and Creating  variables for the Activity files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)


#Reading files and Creating  variables for the Subject files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#Reading files and Creating  variables for the features files
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)


#Checking structure of variables
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

#class(dataActivityTest)

#Concatenate tables by row
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#set variable names
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#Combine all get one dataframe
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#Subset Name of Features by measurements on the mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#structure of Data
str(Data)
###############################################################################################################

#Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
head(Data$activity,30)

#t is replaced by time
names(Data)<-gsub("^t", "time", names(Data))
#f is replaced by frequency
names(Data)<-gsub("^f", "frequency", names(Data))
#Acc is replaced by Accelerometer
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
#Gyro is replaced by Gyroscope
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
#Mag is replaced by Magnitude
names(Data)<-gsub("Mag", "Magnitude", names(Data))
#BodyBody is replaced by Body
names(Data)<-gsub("BodyBody", "Body", names(Data))

names(Data)

#create a new tidy dataset
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]

#write tidy data set to new file
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

#Produce code book (Using memisc library)
codebook<- codebook(Data2)

#creating a textfile for the codebook
capture.output(codebook, file="codebook.txt")
