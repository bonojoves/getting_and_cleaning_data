library(dplyr)
# library(plyr)
# library(reshape2)

# Get directories for train and test
train_directory <- paste(getwd(), "/UCI HAR Dataset/train", sep = "")
test_directory <- paste(getwd(), "/UCI HAR Dataset/test", sep = "")
misc_directory <- paste(getwd(), "/UCI HAR Dataset", sep = "")

# Read training tables
X_train <- read.table(file = paste(train_directory, "/X_train.txt", sep = ""))
y_train <- read.table(file = paste(train_directory, "/y_train.txt", sep = ""))
sub_train <- read.table(file = paste(train_directory, "/subject_train.txt", sep = ""))

# Read test tables
X_test <- read.table(file = paste(test_directory, "/X_test.txt", sep = ""))
y_test <- read.table(file = paste(test_directory, "/y_test.txt", sep = ""))
sub_test <- read.table(file = paste(test_directory, "/subject_test.txt", sep = ""))

# Read misc tables
features <-read.table(file = paste(misc_directory, "/features.txt", sep = ""))
act_labels <-read.table(file = paste(misc_directory, "/activity_labels.txt", sep = ""))

# Assign variable names
colnames(X_train) <- features[, 2]
colnames(y_train) <- "activityID"
colnames(sub_train) <- "subjectID"

colnames(X_test) <- features[, 2]
colnames(y_test) <- "activityID"
colnames(sub_test) <- "subjectID"

colnames(act_labels) <- c("activityID", "activityType")

# Merge data into one
all_train <- cbind(y_train, sub_train, X_train)
all_test <- cbind(y_test, sub_test, X_test)
finalset <- rbind(all_train, all_test)

# Get ID, mean and stdev columns
mean_and_std <- (grepl("activityID", colnames(finalset)) | 
                   grepl("subjectID", colnames(finalset)) | 
                   grepl("mean...", colnames(finalset)) | 
                   grepl("std...", colnames(finalset))
                 )

# Subset the final set using the mean_and_std table
setforMeanandStd <- finalset[, mean_and_std == TRUE]

# merge mean&std table with act_labels
mean_std_actlabels <- merge(setforMeanandStd, act_labels, by = "activityID")

# dplyr to create final set
finalset2 <- mean_std_actlabels %>% group_by(subjectID, activityID) %>%
  summarize_all(mean, na.rm = TRUE)

# write new file
write.table(finalset2, "tidy_week4data.txt", row.names = FALSE)