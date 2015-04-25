

# Your path to the Data Directory
# No trailing /
dataDirPath <- 'C:/Users/bob/Documents/Dropbox/School/Coursera/Getting and Cleaning Data/Project/UCI HAR Dataset'

FullFileName <- function(filename) {
    dataDir = dataDirPath
    paste (dataDirPath, filename, sep='/')
}


######################################################
# run_analysis.R
#
#   This file contains all the functions needed to 
#   load, merge, extract, label, and calculate all
#   the data in the "UCI HAR Dataset."
#
#   These functions assume that this code will be run
#   from the UCI HAR Dataset root level directory and
#   that all the datafiles are available as they are
#   in the original dataset.
#
#   Please see the ReadMe for detailed information 
#   about this code.
#
######################################################


######################################################
# ReadTestAndTraining
#
#   Reads data from test and training directories and 
#   merges them into a single data frame.
#
#   Arguments:
#       none
#
#   Return:
#       one data frame containing all test and train data
#
######################################################
ReadTestAndTraining <- function() {
    
    df.test = ReadData('test')
    df.train = ReadData('train')
    
    rbind(df.test, df.train)
}


######################################################
# Helper function: ReadData(testSet)
#
#   Reads data from a directory
#
#   Arguments:
#       testSet := test | train
#           determine which directory's data to read
#
#   Return: 
#       data frame containing all the files' data
#   
######################################################
ReadData <- function (testSet) {
    
    # input validation
    if (testSet != "test" & 
            testSet != "train") {
        stop("testSet must be 'test' or 'train'")
    }
    
    features <- read.table(FullFileName('features.txt'),
                           colClasses = c('numeric', 'character'),
                           col.names = c('Id', 'Feature'))
    
    # Read data in root directory
    subject <- ReadFiles(testSet, 'subject')
    X <- ReadFiles(testSet, 'X', features$Feature)
    y <- ReadFiles(testSet, 'y')
    
    cbind(subject, X, y)
}


######################################################
# Helper Function: ReadFiles (testSet, prefix, cols)
#
#   Read a single file into a data frame
#
#   Arguments:
#       testSet:    test or train
#                   determines directory and 
#                   and part of the file name
#       prefix:     determines remaining portion of file name
#       cols:       optional variable that specifies the
#                   column names to be used
#   Return:
#       data frame containing data from the single file
#
######################################################
ReadFiles <- function (testSet, prefix, cols = NULL) {
    
    if (is.null(cols)) cols = prefix
    fileName <- paste(testSet, '/', prefix, '_', testSet, '.txt', sep = '')
    
    read.table(FullFileName(fileName),
               col.names = cols,
               colClasses = 'numeric')
}

######################################################
# ExtractMeanAndSD (data)
#
#   Extracts fields containing '.mean.' or '.std.' 
#
#   Arguments:
#       data frame representing test and train data
#
#   Return:
#       data frame with only mean or std fields
#
######################################################
ExtractMeanAndSD <- function(data) {
    m.sd <- c('subject', 'y',
              names(data[grep('\\.mean\\.', names(data))]),
              names(data[grep('\\.std\\.', names(data))]))
    
    data[,m.sd]
}

######################################################
# AddActivityNames (data)
#
#   Adds descriptive activity names 
#
#   Arguments:
#       data frame representing mean and std field
#
#   Return:
#       data frame with human-readable ActivityName field
#
######################################################
AddActivityNames <- function(data) {
    
    activities <- read.table(FullFileName('activity_labels.txt'), 
                             colClasses = c('numeric', 'character'),
                             col.names = c('Id', 'Name'),
                             stringsAsFactors = FALSE)
    ActivityName <- activities$Name[data$y]
    cbind(ActivityName, data)
}

######################################################
# UpdateVariableNames (data)
#
#   Nothing 
#   per #https://class.coursera.org/getdata-013/forum/thread?thread_id=30
#   it was explained that this function was to replace
#   the generic V1, V2... field names with descriptive 
#   names from the data. Because I retained those names
#   in the ReadFiles method, this requirement is already
#   satisfied
#
#   Arguments:
#       data frame
#
#   Return:
#       original data frame 
#
######################################################
UpdateVariableNames <- function(data) { data }


######################################################
# CreateAverageDataset (data)
#
#   Creates an independent, tidy data set with the 
#   average of each variable for each activity and 
#   each subject
#
#   Arguments:
#       data frame representing mean and std values
#       with descriptive ActivityName field
#
#   Return:
#       independent data frame with averages of all
#       mean and std values ordered by subject and 
#       ActivityName
#
######################################################
CreateAverageDataset <- function(data) {

    CurrColNames <- names(data[,4:length(data)])
    FinalColNames <- c('ActivityName', 'subject')
    
    # Creates new data frame to hold tidy data
    df <- unique(data[, c('ActivityName', 'subject')])
    df <- df[order(df$subject, df$ActivityName),]

    for (name in CurrColNames) {
        
        # Returns matrix of means for given column, 'name'
        meanVals <- tapply(data[[name]], 
                          INDEX = list(data$ActivityName, as.factor(data$subject)),
                          mean)  
            
        # Converts matrix to data frame but loses column names
        meanVals.df <- as.data.frame(as.table(meanVals)) 

        # Combines new data frame with tidy data frame
        df <- merge(df, 
                   meanVals.df, 
                   by.x = c('ActivityName', 'subject'), 
                   by.y = c('Var1', 'Var2'), 
                   all = T)
        
        # Restore column names 
        FinalColNames <- c(FinalColNames, name)
        names(df) <- FinalColNames
    }
    
    # Reorder by suject and ActivityName
    df <- df[order(df$subject, df$ActivityName),]
}


######################################################
# SaveTidyData (data, name)
# LoadTidyData (name)
#
#   Saves tidy data to a file for later retrieval
#   LoadTidyData retrieves it from the file
#   (makes no sense to have one without the other)
#
#   Arguments:
#       data:   data frame with mean and std values
#               with descriptive ActivityName field
#       name:   file name
#
#   Return:
#       independent data frame with averages of all
#       mean and std values ordered by subject and 
#       ActivityName
#
######################################################
SaveTidyData <- function (data, name='./tidy.Rda') { 
    save(data, file=FullFileName(name)) 
}

LoadTidyData <- function (name='./tidy.Rda') { 
    load(file = FullFileName(name));
    data 
}


