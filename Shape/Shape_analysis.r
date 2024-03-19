library(qdapRegex)
setwd("/Users/neuro-240/Documents/BIL_and_GIN_Visit")
library(readxl)
shape_metrics <- read.csv("Shape_metrics_all.csv")
demog <- read_xlsx("HFLI.xlsx")
Cognitive_tests <- read.csv("data_cog2_.csv")
shape_metrics_CC <- read.csv("shape_metrics_CC_final.csv")

colnames(shape_metrics)[1] <- "subject"
colnames(shape_metrics_CC)[1] <- "subject"
colnames(demog)[1] <- "subject"
colnames(Cognitive_tests)[3] <- "subject"

library(dplyr)

#Remove subjects without LI 
demographics_needed <- Cognitive_tests[, c("subject", "sexe", "Edinburg.Score")]

demographics_needed <- inner_join(demog, demographics_needed, by = "subject")

demographics_needed <- na.omit(demographics_needed)


# Perform inner join on the "subject" column
library(dplyr)
mutual_subjects_all <- inner_join(demographics_needed, shape_metrics, by = "subject")
mutual_subjects_CC <- inner_join(demographics_needed, shape_metrics_CC, by= "subject")
colnames(mutual_subjects_all)[9] <- "LI_no_motor"
colnames(mutual_subjects_CC)[9] <- "LI_no_motor"

colnames(mutual_subjects_CC)

mutual_subjects <- rbind(mutual_subjects_all, mutual_subjects_CC)


# Remove specific values from unique Tract.Name
filtered_tract_names <- setdiff(unique(mutual_subjects$Tract.Name), c("cc_homotopic_insular", "optical_radiation_L", "optical_radiation_R", "accx", 
                                                                      "cc_homotopic_occipital", "brainstem", "cc_homotopic_frontal", "cc_homotopic_cingulum",
                                                                      "cc_homotopic_parietal", "cc_homotopic_temporal"))

# Subset the dataframe to only include the filtered Tract.Name values
mutual_subjects <- mutual_subjects[mutual_subjects$Tract.Name %in% filtered_tract_names, ]
#Make shape metric format wider


library(tidyr)

wide_data_shape <- mutual_subjects %>%
  pivot_wider(names_from = Shape.Metric, values_from = Value)

mutual_subjects_wide <- inner_join(demog, wide_data_shape, by = "subject")

colnames(mutual_subjects_wide)[9] <- "LI_no_motor"

colnames(mutual_subjects_wide)

#pca
library(ggplot2)

#Find cols that have NAs
cols_with_na <- colSums(is.na(mutual_subjects_wide)) > 0

# Select columns with NAs
cols_with_na <- names(cols_with_na[cols_with_na])

cols_with_na




#Check normality


# Select columns 12 to 32
columns_to_check <- mutual_subjects_wide[, 23:43]


par(mfrow=c(5, 5))  # 5 rows, 4 columns for 20 plots

# Plot Q-Q plots for each column
for (column_name in names(columns_to_check)) {
  qqnorm(columns_to_check[[column_name]], main = paste("Q-Q Plot of", column_name))
  qqline(columns_to_check[[column_name]])
}



#Data not normal, so transforming it :

# Define the transformation function
transform_function <- function(x) {
  # Apply your transformation here, for example, you can take the square root of each value
  sqrt(x)
}

# Select columns 12 to 32 and apply the transformation
transformed_columns <- lapply(mutual_subjects_wide[, 23:43], transform_function)

# Combine transformed columns with columns 1 to 12 into a new DataFrame
transformed_df <- cbind(mutual_subjects_wide[, 1:22], as.data.frame(transformed_columns))

# Print the first few rows of the transformed DataFrame
head(transformed_df)

# Set up the layout for the plots
par(mfrow=c(5, 5))  # 5 rows 5 cols

# Plot Q-Q plots for each column
for (column_name in names(transformed_df[,23:43])) {
  qqnorm(transformed_df[,23:43][[column_name]], main = paste("Q-Q Plot of", column_name))
  qqline(transformed_df[,23:43][[column_name]])
}


#PCA


shape_pca <- CBF_PCA(transformed_df[,23:43], groups = FALSE, pcs=c(1,2), useLabels=TRUE,  type='loadings')
summary(shape_pca$pc)$importance[2,]*100
                     
loadings <- shape_pca$pc$rotation
  

#Plot LI histogram
# Aggregate the data by "subject" and calculate the mean LI for each subject
subject_means <- mutual_subjects %>%
  group_by(subject) %>%
  summarize(mean_LI = mean(LI_no_motor))


# Create a histogram of the mean LI values
ggplot(subject_means, aes(x = mean_LI)) +
  geom_histogram(binwidth = 8, fill = "skyblue", color = "black") +
  labs(title = "Histogram of LI Values",
       x = "LI",
       y = "Frequency")



# Regression
library(dplyr)


# Convert Tract.Name and Shape.Metric to character type to avoid type mismatch
transformed_df$Tract.Name <- as.character(transformed_df$Tract.Name)
transformed_df[,23:43] <- as.character(transformed_df[,23:43])

# Get unique combinations of Tract.Name and Shape.Metric
tract_names <- unique(transformed_df[, c("Tract.Name")])



# Initialize an empty list to store regression results
regression_results <- list()
# Initialize an empty vector to store combinations not available
missing_combinations <- c()
library("stats")

columns_to_include <- 5:25
# Iterate through each combination of Tract.Name and Shape.Metric
for (i in 1:nrow(tract_names)) {
  tract <- tract_names[i]
  # Subset data for the current combination
  subset_data <- transformed_df %>%
    select(1,4, 20:43) %>%
    filter(Tract.Name == tract)
  
  # Check if the subset is empty
  if (nrow(subset_data) == 0) {
    missing_combinations <- c(missing_combinations, paste(tract, shape_metric, sep = "_"))
    next  # Skip to the next iteration
  }
  
  for (col_index in columns_to_include) {
    #Extract column name
    col_name <- names(subset_data)[col_index]
    
    #Perform linear regression
    formula <- as.formula(paste(col_name, "~ age_IRM_Anat.x + Edinburg.Score + sexe.y"))
    regression_model <- lm(formula, data = subset_data)
    
    regression_results[[col_name]] <- summary(regression_model)
  }
}
  



# Print missing combinations
if (length(missing_combinations) > 0) {
  cat("The following combinations are not available in the data frame:\n")
  cat(paste(missing_combinations, collapse = ", "), "\n")
} else {
  cat("All combinations are available in the data frame.\n")
}

# Now you can access regression results for each combination using regression_results list
# For example, to access results for the first combination:
# print(regression_results[[1]])


# Now you can access regression results for each combination using regression_results list
# For example, to access results for the first combination:
# print(regression_results[[1]])

# Access the regression results using names like TractName_ShapeMetric
# For example, to access the regression results for a specific combination:
# regression_results[["TractName_ShapeMetric"]]


# List to store regression results
regression_results <



#Calculating LI for the Broca's area (summing two inferior regions)

mutual_subjects$LI <- (mutual_subjects$AICHA_029_S_Inf_Frontal.1 + mutual_subjects$AICHA_031_S_Inf_Frontal.2 + mutual_subjects$AICHA_033_G_Frontal_Inf_Tri.1)/3

#Deleting regional cols for LIs
mutual_subjects <- select(mutual_subjects, -2, -3)




# Subset the data frame to select rows where LI is NA
subjects_with_na_li <- mutual_subjects$subject[is.na(mutual_subjects$LI)]
subjects_with_na_li <- unique(subjects_with_na_li)
# Print the subjects with NA as LI
print(subjects_with_na_li)



# Filter out rows where LI is not NA
mutual_subjects <- filter(mutual_subjects, !is.na(LI))

# Display the updated mutual_subjects data frame
print(mutual_subjects)





library(ggplot2)

# Aggregate the data by "subject" and calculate the mean LI for each subject
subject_means <- mutual_subjects %>%
  group_by(subject) %>%
  summarize(mean_LI = mean(LI_no_motor))


# Create a histogram of the mean LI values
ggplot(subject_means, aes(x = mean_LI)) +
  geom_histogram(binwidth = 8, fill = "skyblue", color = "black") +
  labs(title = "Histogram of LI Values",
       x = "LI",
       y = "Frequency")




library(dplyr)

# Assuming mutual_subjects is your data frame containing the "LI" column
mutual_subjects <- mutual_subjects %>%
  mutate(laterality = ifelse(LI > 0.1, "leftLat", ifelse(LI < -0.1, "rightLat", "biLat")))

subject_means <- subject_means %>%
  mutate(laterality = ifelse(mean_LI > 0.1, "leftLat", ifelse(mean_LI < -0.1, "rightLat", "biLat")))

# Display the resulting data frame
print(mutual_subjects)
