# Getting And Cleaning Data Course Project
Bob Weiner  
October 22, 2015  

## Introduction
The run_analysis.R file contains all the functions needed to open and clean all the data from the UCI HAR Dataset.  A RunAll() function will call each function in turn and write the output to the root directory as tidy.txt.

### 1. Merging the Training and Test Sets
The ReadData function reads features.txt from the root directory and retains the second column for data labels.  Consecutive punctuation marks are replaced with a single dot for readability (*though this is undone in step 4*). 

GetFileNames is a helper function that is used to retrieve the fully qualified names for the subject_, X_, and y_ data files in the test and train directory.  This function concatenates scalars and vectors to produce two filenames for each input and therefore generates a warning message.  This is suppressed when called from ReadData.

Using the dplyr packages, each pair of files is read and bound by rows.  The resulting three data frames are then column bound to each other and returned from the function.

### 2. Extracting the Mean and Standard Deviation of each Measurement
Fields containing mean and standard deviation data are identified by containing the patterns, _.mean._ and _.std._ in their names.  This result (a logical vector) is then adjusted to retain the first two columns (subject and activityid) because str_detect will return FALSE for these.  The data frame containing only these columns is returned.

### 3. Applying Activities Labels
Activity labels are joined to the data frame using dplyr's inner_join function.  The labels are read from the file, activity_labels.txt, then joined using the id columns from both sources.  The result is returned from the function.

### 4. Creating Descriptive Variable Names
The column names are then adjusted using the advice given in the forum post, https://class.coursera.org/getdata-033/forum/thread?thread_id=126.  In this function, the names are lower-cased and the dots removed using the stringr functions str_to_lower and str_replace_all respectively. 

**Note:** I personally find the new names very unreadable and must disagree with this advice though I acknowledge that disagreement over variable naming has been around as long as programming itself.  For what it is worth, my 2&#0162; on the subject is   
 1.  Variable meanings should be understood intuitively at first glance.  
 2.  You should never have to change variable names because you should never admit bad ones in the first place.   

Note my variables are named as they are read from the file (*thought I would have prefered ActivityId*). 

### 5. Creating a Tidy Data Set of Variable Averages
To create the final, tidy dataset, I pipe the provided data frame through a series of dplyr functions.  The purpose of these are:  
 1.  select - remove the non-numeric column prior to applying the mean function  
 2.  group_by - segment the data by activity and subject so that dplyr could aggregate each 
 3.  summarise_each - apply the mean function to each column of the data set and aggregate the rows as specified above  
 4.  arrange - sort the rows in logical order so that they are more human readable since they will be stored in a text file  
 5.  inner_join - re-add the activity name column since it was removed above (note, not removing it is not really an option since it would have been convered to NA during aggregation)  

Finally, the data frame is returned with the last column moved to the first - again, to make the text file more human readable.

### Files
The finally tidy data set is tidy.txt.  
And here is a link to the [Codebook](http://htmlpreview.github.io/?https://github.com/BobWeinerJr/GettingAndCleaning-Project/blob/master/CodeBook.html "Codebook")

