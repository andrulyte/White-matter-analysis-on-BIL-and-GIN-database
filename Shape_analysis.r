library(qdapRegex)
setwd("/Users/neuro-240/Documents/BIL_and_GIN_Visit")
library(readxl)
shape_metrics <- read.csv("Shape_metrics.csv")
demog <- read_xlsx("HFLI.xlsx")

#Remove subjects without LI 
demog <- na.omit(demog)


#Change colname
colnames(shape_metrics)[1] <- "subject"
colnames(demog)[1] <- "subject"



# Perform inner join on the "subject" column
library(dplyr)
mutual_subjects <- inner_join(demog, shape_metrics, by = "subject")
colnames(mutual_subjects)[9] <- "LI_no_motor"

colnames(mutual_subjects)

#Make shape metric format wider


library(tidyr)

wide_data_shape <- shape_metrics %>%
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


#PCA


shape_pca <- prcomp(as.matrix(mutual_subjects_wide[, 12:ncol(mutual_subjects_wide)]), center = T, scale = F)

shape_explained <- summary(shape_pca)$importance[2, ] * 100

# in this case we need 2 PCs to capture at least 75% variance so we will select 2
# PCs to our next modelling approach:
shape_NewVars <- shape_pca$x[, 1:2]

loadpc1 <- sort(abs(result$pc$rotation[, 1]))

loadpc1_sorted <- sort(loadpc1)

top_10_index <- round(length(loadpc1_sorted) * 0.1)

top_10_percent_PC1 <- loadpc1_sorted[(length(loadpc1_sorted) - top_10_index + 1):length(loadpc1_sorted)]

top_10_percent_PC1


loadpc2 <- sort(abs(shape_pca$rotation[, 2]))

loadpc2_sorted <- sort(loadpc2)

top_10_index <- round(length(loadpc2_sorted) * 0.1)

top_10_percent <- loadpc2_sorted[(length(loadpc2_sorted) - top_20_index + 1):length(loadpc2_sorted)]

top_10_percent


shape_scores23 <- as.data.frame(shape_pca$x[, 2:3])

shape_explained23 <- shape_explained[2:3]


shape_loadings23 <- as.data.frame(shape_pca$rotation[, 2:3])

ggplot(shape_loadings23,aes(x=PC2,y=PC3))+ geom_text(aes(x=PC2,y=PC3),
    label=rownames(shape_loadings23))+ xlab("Loadings of PC2")+
  ylab("Loadings of PC3")+
  theme_bw(base_size = 16)



shape_euclidean <- mutual_subjects_wide[, 12:ncol(mutual_subjects_wide)]

# Note that all those steps could have been combined and are equivalent
# to:
shape_hc_samples <- hclust(dist(shape_euclidean, method = "euclidean"),
                               method = "ward.D2")
shape_hc_ <- hclust(dist(t(shape_euclidean), method = "euclidean"),
                              method = "ward.D2")
# 4.Now we can visualise the trees
# for samples, we can nicely see how the septic horses fall from a
# different branch that the ones without sepsis. With exception of 1 # septic horse that seem to behave a bit differently plot(SynFluid_hc_samples)


plot(shape_hc_)


HCclusters_Samples <- cutree(tree = shape_hc_samples, k = 2)
HCclusters_Samples <- cutree(tree = shape_hc_, k = 2)


result <- CBF_PCA(t(shape_euclidean), as.character(HCclusters_Samples), scale = F, legendName = "cluster", useLabels = T)
KmeansResult1 <- kmeans(x = t(shape_euclidean), centers = 4)

KmeansResult1$cluster

result <- CBF_PCA(t(shape_euclidean), as.character(KmeansResult1$cluster), scale = F, legendName = "cluster", useLabels = T)

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

# Remove specific values from unique Tract.Name
filtered_tract_names <- setdiff(unique(mutual_subjects$Tract.Name), c("cc_homotopic_insular", "optical_radiation_L", "optical_radiation_R", "accx"))

# Subset the dataframe to only include the filtered Tract.Name values
mutual_subjects <- mutual_subjects[mutual_subjects$Tract.Name %in% filtered_tract_names, ]

library(dplyr)

# Convert Tract.Name and Shape.Metric to factors
mutual_subjects$Tract.Name <- as.factor(mutual_subjects$Tract.Name)
mutual_subjects$Shape.Metric <- as.factor(mutual_subjects$Shape.Metric)

# List to store regression results
regression_results <- list()

# Loop through each combination
for (tract in filtered_tract_names) {
  unique_shapes <- unique(mutual_subjects$Shape.Metric)
  for (shape_metric in unique_shapes) {
    # Subset dataframe for the current combination
    subset_data <- mutual_subjects %>%
      filter(Tract.Name == tract, Shape.Metric == shape_metric)
    
    # Check if the subset has at least two levels for both factors
    if (nlevels(subset_data$Tract.Name) >= 2 && nlevels(subset_data$Shape.Metric) >= 2) {
      # Perform multiple regression
      regression_results[[paste(tract, shape_metric, sep = "_")]] <- lm(Value ~., data = subset_data)
    }
  }
}
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
