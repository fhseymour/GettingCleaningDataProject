## Introduction

This is the code book for the course project from the Coursera course "Getting and Cleanning Data", from John's Hopkins Bloomberg School of Public Health.  It describes the data, the variables, and any transformations or work that were performed to clean up the data.

## The Data

The data for this project represent data collected from the accelerometers from the Samsung Galaxy S smartphone and were obtained from:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

A full description of the data is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The data consists of experiments carried out on a group of 30 volunteers, labelled 1 through 30.  Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) while wearing a Samsung Galaxy SII smartphone on the waist.  Using the device's embedded accelerometer and gyroscope, 3-axial linear acceleration and 3-axial angular velocity data were captured with a total of 561 variables.

The zip file has a directory UCI_HAR_Dataset containing a directories and files for a training and a test dataset (intended for supervised machine learning).  The used  filenames and brief description follow:

* <b>activity_labels.txt</b> (6 activity names and corresponding numeric code)
* <b>features.txt</b> (561 variable name designations and corresponding numeric code)
* <b>test/y_test.txt</b> (test dataset, 2947 observations and activity code)
* <b>test/subject_test.txt</b> (test dataset, 2947 observations and subject code)
* <b>test/X_test.txt</b> (test dataset, 2947 observations with 561 measurements)
* <b>train/y_train.txt</b> (train dataset, 7352 observations and activity code)
* <b>train/subject_train.txt</b> (train dataset, 7352 observations and subject code)
* <b>train/X_train.txt</b> (train dataset, 7352 observations with 561 measurements)

## The Variables

The independent variables are the six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) with numeric codes 1 through 6 and the thirty subject with numeric codes 1 through 30.  

The dependent variables consist of the 561 measurements based on the waist level Samsum Galaxy SII smartphone accelerometer and gyroscope.  The variable names from the feature list encode specific meaning of each measurement.  Only the mean() and std() values are incorporated into the tidy dataset of which there are 79 variables.  The dictionary explaining these tidy dataset variable encodings is:

* <b>f:</b> frequency domain
* <b>t:</b> time domain

* <b>Body:</b> measurement relative to subject body
* <b>Gravity:</b> measurement relative to gravity force

* <b>Acc:</b> acceleration
* <b>Gyro:</b> angular velocity

* <b>Jerk:</b> rate of change
* <b>Mag:</b> magnitude

* <b>mean:</b> mean values of measurements
* <b>std:</b> standard deviation of measurements

* <b>X:</b> x-direction of 3-axial coordinate system
* <b>Y:</b> y-direction of 3-axial coordinate system
* <b>Z:</b> z-direction of 3-axial coordinate system

## Data Transformations

The R script run_analysis.R performs the following transformations:

1) Creates local data directory, downloads and unzips the .zip file.  Loads the txt files into R dataframes:

* <b>activity_labels.txt</b> into data.frame activity_labels 
* <b>features.txt</b> into data.frame features
* <b>train/y_train.txt</b> into data.frame y_train
* <b>train/subject_train.txt</b> into data.frame subject_train
* <b>train/X_train.txt</b> into data.frame X_train
* <b>test/y_test.txt</b> into data.frame y_test 
* <b>test/subject_test.txt</b> into data.frame subject_test
* <b>test/X_test.txt</b> into data.frame X_test

2) Using rbind() combines the 7352 training observations and the 2947 test observations into "all" dataframes of 10299 observations:

* y_train and y_test combined into data.frame y_all
* subject_train and subject_test combined into data.frame subject_all
* X_train and X_test combined into data.frame X_all

3) the X_all column names are loaded with the text feature names.  This facilitates extracting the mean and std variables only using the feature labels.  The variables are first extracted into data.frames mean_all and std_all.  These two data.frames in turn are combined into data.frame selected_all.

4) The independent descriptive name activity variables (not the numeric code) and the subject numeric code are added to the left side of the selected_all data.frame.   

5) To develop the tidy dataset comprised of the average of each selected variable for each activity and each subject, the activity and subject independent variables are combined into a single Activity.Subject column on the right side of data.frame selected_all. 

6) Loop through the 79 dependent variables in selected_all one column at a time, calculating the average value for each Activity.Subject combination with tapply and accumulates the results row by row in data.frame tidyData.

7) Transposes tidyData so that the 79 variables are again columns and the rows correspond to the unique Activity.Subject values.  Assign the variable feature names to the column names.  Take the Activity.Subject row names and split them into separate Activity and Subject variables which are inserted to the left of the tidyData data.frame.

8) Save the tidyData data.frame as a txt file with comman delimiter and no row names.  The column variables are:

* <b>Activity</b> Independent activity variable
* <b>Subject</b> Independent subject variable
* <b>Averages</b> 79 dependent variables with average value for Activity.Subject combination