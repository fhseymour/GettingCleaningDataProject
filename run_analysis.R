# Coursera Getting and Cleaning Data Project
# FHS, January 18, 2015,

# Script run_analysis.R that performs the following:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

############################################################################
# step 1, download and merge the training and test sets into one dataset

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "./data/SamsungSmartphoneAccelerate.zip"
# create local data directory if it doesn't already exist
if(!file.exists("./data")) {dir.create("./data")} 
# only downloads and unzips big file, if it doesn't already exist
if(!file.exists(fileName)) {
    download.file(fileUrl,destfile=fileName,method="curl")
    unzip(fileName)
    file.rename("UCI HAR Dataset", "data/UCI_HAR_Dataset") # move files into local data directory
}

# load global features and activity labels
features <- read.table("data/UCI_HAR_Dataset/features.txt")
activity_labels <- read.table("data/UCI_HAR_Dataset/activity_labels.txt")

rowCount <- -1 # for quicker script testing, variable for nrows in read.table

subject_train <- read.table("data/UCI_HAR_Dataset/train/subject_train.txt", nrows=rowCount)
y_train <- read.table("data/UCI_HAR_Dataset/train/y_train.txt", nrows=rowCount) 
X_train <- read.table("data/UCI_HAR_Dataset/train/X_train.txt", nrows=rowCount)

subject_test <- read.table("data/UCI_HAR_Dataset/test/subject_test.txt", nrows=rowCount)
y_test <- read.table("data/UCI_HAR_Dataset/test/y_test.txt", nrows=rowCount) 
X_test <- read.table("data/UCI_HAR_Dataset/test/X_test.txt", nrows=rowCount)

# use rbind to merge training and test sets into one dataset
subject_all <- rbind(subject_train, subject_test)
y_all <- rbind(y_train, y_test)
X_all <- rbind(X_train, X_test)

############################################################################
# step 2, Extract only the mean and standard deviation for each measurement.

meanMeasures <- grep("mean()", features$V2)
stdMeasures <- grep("std()", features$V2)
# meanMeasures <- grep("tBodyAcc-mean()", features$V2)
# stdMeasures <- grep("tBodyAcc-std()", features$V2)

names(X_all) <- features$V2 # assign descriptive variable names (part of step 4)
mean_all <- X_all[,meanMeasures]
std_all <- X_all[,stdMeasures]

selected_all <- cbind(mean_all, std_all) # mean and std only for each measurement

############################################################################
# steps 3 an 4
# Use descriptive activity names to name the activities in the data set
# Appropriate labels for data set with descriptive variable names.

# setup activity code list with activity labels and name columns
activity_all <- merge(activity_labels, y_all)
names(activity_all) <- c("Activity.Code", "Activity.Name")

# name subject column and convert to factor
names(subject_all) <- "Subject"
subject_all$Subject <- as.factor(subject_all$Subject)

# assemble subject, activity, and selected measurements into one dataframe
selected_all <- cbind(Activity=activity_all$Activity.Name, subject_all, selected_all)

############################################################################
# step 5, Create tidy dataset from selected_all data set
# with the average of each variable for each activity and each subject.

# combine Acivity and Subject into one column Activity.Subject
# which will be the basis for calculating the average of each variable
selected_all <- selected_all[order(selected_all$Activity, selected_all$Subject),]
selected_all$Activity.Subject <- paste(selected_all$Activity, selected_all$Subject, sep=".")

# the last column with variable for mean calculation in selected_all
cmax <- length(selected_all) - 1

# loop throught the variable columns in selected_all
for (c in 3:cmax)
{ 
    # calculation the means for each activity and subject combination 
    temp <- tapply(selected_all[,c], selected_all[,"Activity.Subject"], FUN=mean)
    
    if (c==3) {
        # if first variable, then initialize tidyData
        tidyData <- temp
    }
    else
    {
        # bind row of each subsequent variable into tidyData
        tidyData <- rbind(tidyData, temp)
    }
}

tidyData <- t(tidyData) # transpose to put variables back into columns
tidyData <- as.data.frame(tidyData) # set tidyData as dataframe
names(tidyData) <- names(selected_all)[3:cmax] # get variables names

# to setup tidyData activity and subject label columns, start with
# tidyData rownames -- split into Activity and Subject dataframe
library(reshape2)
tidyRowNames <- colsplit(rownames(tidyData),"[.]", c("Activity","Subject"))

# bind activity and subject columns into tidydata,
# order by activity and then subject
tidyData <- cbind(tidyRowNames, tidyData)
tidyData <- tidyData[order(tidyData$Activity, tidyData$Subject),]

# tidyData now ready to be save in txt file
tidyData
fileName <- "./data/tidyData.txt"
write.table(tidyData, file=fileName, sep=",",row.names=FALSE)

