library(stringr)
library(dplyr)

#
# Update baseDir path to the local machine before running
# Function RunAll will read and process all data then write the output to baseDir/tidy.Rda
baseDir <- 'C:/Users/Bob/Dropbox/School/Coursera/Getting and Cleaning Data/Project/UCI HAR Dataset/'

dataDirs <- c('test', 'train')


# Merge training and test sets
GetFileNames <- function(prefix) {
    str_c(baseDir, dataDirs, '/', prefix, '_', dataDirs, '.txt')
}

ReadData <- function() { 
    features <- 
        read.table(file = str_c(baseDir, 'features.txt'),
                   stringsAsFactors = FALSE,
                   col.names = c('', 'FeatureName'))[,2] %>% 
        str_replace_all('[:punct:]{1,3}', '.')
    
    # Warnings will be generated because the function combines scalars and vectors
    # this is intended so they will be suppressed
    suppressWarnings({
        files.subject   = GetFileNames('subject')
        files.activity  = GetFileNames('y')
        files.data      = GetFileNames('X')
    })
    
    bind_rows(read.table(file = files.subject[1], col.names = 'subject'),
              read.table(file = files.subject[2], col.names = 'subject')
    ) %>% 
    bind_cols(
        bind_rows(read.table(file = files.activity[1], col.names = 'activityid'),
                  read.table(file = files.activity[2], col.names = 'activityid'))
    ) %>% 
    bind_cols(
        bind_rows(read.table(file = files.data[1], col.names = features, colClasses = 'numeric'),
                  read.table(file = files.data[2], col.names = features, colClasses = 'numeric'))
    )
}


# Extract mean and std. dev. of each measurement
ExtractMeanAndStd <- function(df) {
    cols <- str_detect(names(df), '\\.mean\\.|\\.std\\.')
    cols[1:2] <- TRUE
    df[,cols]
}


# Apply activities labels from activity_labels.txt
ApplyActivityLabels <- function(df) {
    df %>% 
        inner_join(
            read.table(
                file = str_c(baseDir, 'activity_labels.txt'),
                stringsAsFactors = FALSE,
                col.names = c('activityid', 'activityname')
            ), 
            by = 'activityid'
        )
}


# Descriptive variable names
ApplyDescriptiveVariableNames <- function(df) {
    # IAW the following post:
    #   https://class.coursera.org/getdata-033/forum/thread?thread_id=126
    # this function will lower case the names and remove the dots
    #
    # Personally I find this much less readable but...
    names(df) <- names(df) %>% str_to_lower() %>% str_replace_all('\\.', '')
    df
}


# Create second, independent tidy data set with the average
# of each variable for each activity and each subject
AverageActivityAndSubject <- function(df) {
    df = df %>%
        select(-activityname) %>%
        group_by(activityid, subject) %>%
        summarise_each(funs(mean)) %>%
        arrange(subject, activityid) %>%
        inner_join(
            read.table(
                file = str_c(baseDir, 'activity_labels.txt'),
                col.names = c('activityid', 'activityname')
            ), 
            by = 'activityid'
        )
    df[,c(69, 1:68)] 
}


# Do everthing and put table in baseDir/tidy.Rda
RunAll <- function() { 
    df <- ReadData()
    df <- ExtractMeanAndStd(df)
    df <- ApplyActivityLabels(df)
    df <- ApplyDescriptiveVariableNames(df)
    df.tidy <- AverageActivityAndSubject(df)
    write.table(df.tidy, 
                file = str_c(baseDir, 'tidy.txt'))
}
