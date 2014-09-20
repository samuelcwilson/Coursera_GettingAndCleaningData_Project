# Course Project for Getting and Cleaning Data
# Create one R Script called run_analysis.R that does the following:  Merge the training and testing 
# sets to create one data set; extracts only the measurements on teh mean and STDEV for each measurement;
# Uses descriptive activity names; and labels the variables; and finally create a tidy data set.

# load librarys and set working directory
library(plyr)
library(RCurl)
library(reshape2)
setwd("~/Coursea")

# Download data, save it locally, exact it
URL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile<-"C:\Users\Samuel\Documents\Coursea\Galaxy_Data.zip"
download.file(URL,destfile)
unzip(destfile)

# Load the training data
trainSub<-read.table("UCI HAR Dataset/train/subject_train.txt", col.names="Subject")
trainY<-read.table("UCI HAR Dataset/train/y_train.txt", col.names="Class")
trainX<-read.table("UCI HAR Dataset/train/x_train.txt")

# Load the test data
testSub<-read.table("UCI HAR Dataset/test/subject_test.txt", col.names="Subject")
testY<-read.table("UCI HAR Dataset/test/y_test.txt", col.names="Class")
testX<-read.table("UCI HAR Dataset/test/x_test.txt")

# Load variable names and labels
names<-read.table("UCI HAR Dataset/features.txt",col.names=c("Column","Desc"),stringsAsFactors=FALSE)[,2]
labels<-read.table("UCI HAR Dataset/activity_labels.txt",col.names=c("Class","Label"))

# Some clean Up variable names
names<-gsub("\\()","",names)
names<-gsub("\\(\\)","",names)
names<-gsub("\\-X","",names)
names<-gsub("\\-Y","",names)
names<-gsub("\\-Z","",names)
names<-gsub("^t","Time-",names)
names<-gsub("^f","Frequency-",names)
names<-gsub("std","STD",names)
names<-gsub("mean","Mean",names)

# Feed names to datasets
colnames(testX)<-names
colnames(trainX)<-names

# Start Combining
fullDataX<-rbind(testX,trainX)
fullDataY<-rbind(testY,trainY)
fullSub<-rbind(testSub,trainSub)

# Add Labels to Actvities
fullDataY$Activity<-labels$Label[match(fullDataY$Class,labels$Class)]

# Finish Combining -- Now have master data set
fullData<-cbind(fullSub,fullDataY,fullDataX)

# Find the Means and STDEVs
indexMean <- grep("mean",colnames(fullData),ignore.case=TRUE)
indexStdev <- grep("STD",colnames(fullData),ignore.case=TRUE)
dataMeanStdev<-fullData[c(1:3,indexMean,indexStdev)]

# Final Dataset 
finalData<-dataMeanStdev

# Melt the Data Set
dataMelt<-melt(finalData,id=c("Subject","Class","Activity"), measure.vars = c(4:89), variable.name = "Variable", value.name = "Signal" )

# Cast the Melted Data Frame and get the Means
dataTidy<-dcast(dataMelt,Subject+Activity ~ Variable,mean, value.var="Signal")

# Final Data Sets
# Steps 1-4 "finalData" which contains all the data with descriptive variable names
# Step 5 "dataTidy" which contains all the means for each activity and each person

write.table(finalData, "Final Complete Dataset.txt")
write.table(dataTidy, "Final Tidy Dataset.txt")

