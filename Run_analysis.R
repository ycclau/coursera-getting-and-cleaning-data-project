library(data.table)
library(dplyr)

filename <- "getdata%2Fprojectfiles%2FUCI HAR Dataset.zip"

if(!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL,destfile = filename,method = "curl")
}

if(!file.exists("UCI HAR Dataset")){
    unzip(filename)
}

activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activitylabels[,2] <- as.character(activitylabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

#2
has_meanFreq_mean_std <- grepl(".*mean.*|.*std.*",features[,2])
has_meanFreq <- grepl("meanFreq",features[,2])
featuresWanted <- has_meanFreq_mean_std & !has_meanFreq
featuresWanted.names <- features[featuresWanted,2]

#4
featuresWanted.names <- gsub('mean','Mean',featuresWanted.names)
featuresWanted.names <- gsub('std','Std',featuresWanted.names)
featuresWanted.names <- gsub('[-()]','',featuresWanted.names)

train <- read.table(file = "UCI HAR Dataset/train/X_train.txt")[,featuresWanted]
trainActivities <- read.table(file = "UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table(file = "UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects,trainActivities,train)

test <- read.table(file = "UCI HAR Dataset/test/X_test.txt")[,featuresWanted]
testActivities <- read.table(file = "UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table(file = "UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects,testActivities,test)

#1
allData <- rbind(test,train)
colnames(allData) <- c("Subject","Activity",featuresWanted.names)

#3
allData$Activity <- factor(allData$Activity, levels = activitylabels[,1], labels = activitylabels[,2])
allData$Subject <- as.factor(allData$Subject)

#5
allMean <- colMeans(allData[,3:length(allData)],na.rm = FALSE)
tidyFile <- matrix(c(featuresWanted.names, allMean),ncol = 2)
colnames(tidyFile) <- c("Activity","Mean")
write.table(tidyFile, "UCI HAR Dataset/Tidy File.txt",col.names = TRUE,row.name=FALSE)
