###############################
### Cleaning Data -Coursera ###
########## Project ############
###############################
.libPaths("C:/R-3.3.1/library")
.libPaths() 
install.packages("plyr", lib="C:/R-3.3.1/library")
install.packages("memisc", lib="C:/R-3.3.1/library")

library(plyr);
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
path <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
files

#Reading files and Creating  variables for the Activity files
ActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)


#Reading files and Creating  variables for the Subject files
SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

#Reading files and Creating  variables for the features files
FeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)


#Concatenate tables by row
Subject <- rbind(SubjectTrain, SubjectTest)
Activity<- rbind(ActivityTrain, ActivityTest)
Features<- rbind(FeaturesTrain, FeaturesTest)

#set variable names
names(Subject)<-c("subject")
names(Activity)<- c("activity")
FeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(Features)<- FeaturesNames$V2

###############################################################################
##### 1. Merges the training and the test sets to create one data set. ########
###############################################################################

#Combine all get one dataframe
Combine <- cbind(Subject, Activity)
Data <- cbind(Features, Combine)

########################################################################################################
##### 2.Extracts only the measurements on the mean and standard deviation for each measurement. ########
########################################################################################################

#Subset Name of Features by measurements on the mean and standard deviation
subFeaturesNames<-FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]

#Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#########################################################################################
##### 3. Uses descriptive activity names to name the activities in the data set. ########
#########################################################################################

#Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
head(Data$activity,30)

####################################################################################
##### 4. Appropriately labels the data set with descriptive variable names. ########
####################################################################################

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


#########################################################################################################
##### 5. From the data set in step 4, creates a second, independent tidy data set with the average ###### 
############# of each variable for each activity and each subject. ######################################
#########################################################################################################


#create a new tidy dataset
tidyData<-aggregate(. ~subject + activity, Data, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]

#write tidy data set to new file
write.table(tidyData, file = "tidydata.txt",row.name=FALSE)

#Produce code book (Using memisc library)
codebook<- codebook(tidyData)

#creating a textfile for the codebook
capture.output(codebook, file="codebook.txt")

