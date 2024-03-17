library(qdapRegex)
setwd("/Users/neuro-240/Documents/BIL_and_GIN_Visit")
library(readxl)
Cognitive_tests <- read.csv("data_cog2_.csv")


#Change colname
colnames(Cognitive_tests)[3] <- "subject"

library(dplyr)

# Perform inner join on the "subject" column
all_subj <- inner_join(Cognitive_tests, subject_means, by = "subject")



#Only pick the subj that I will be doing tests on 
# Create a vector of column names you want to keep

cols_to_keep <- c(
  "subject", 
  "Sexe", 
  "Edinburg.Score", 
  "Educational.level..nb.of.school.years.", 
  "RSTS...reading..score", 
  "LSTS", 
  "voc...vocabulary.or.verbal.IQ", 
  "gen...generation..generate.associated.words.to.the.noun", 
  "rey..18.words...semantic.memory", 
  "reydiff..15.minutes.after.delayed....long.term.memory", 
  "PSM...phonological.memory..pseudowords", 
  "PSMdiff",
  "rimtot...phonological.memory.rhyme", 
  "phono...phonological.but.need.to.check.with.Gael", 
  "vlecturec...speed.of.reading", 
  "ecoute...speed.word.task..how.well.words.are.understood.when.they.are..flashed.on.the.screen.for.different.time.", 
  "Mental.rotation.test..number.correct.out.of.20.", 
  "Corsi.test.number.of.correct.response", 
  "Labyrinthe.Score", 
  "Advanced.Progressive.Matrices.IQ", 
  "Arithmetic.Facts..out.of.36.", 
  "Arithmetic.Fact.response.time.on.correct", 
  "Complex.calculation..out.of.8.", 
  "Complex.calculation.Correct.resp.time", 
  "Arithmetical.problem..out.of.12.", 
  "Arithmetical.problem.correct.reponse.time"
)

Cognitive_tests_filtered <- Cognitive_tests[, cols_to_keep]



Cognitive_tests_filtered <- na.omit(Cognitive_tests_filtered)

#Change new colnames 
colnames(Cognitive_tests_filtered) <- c(
  "subject",
  "Sexe",
  "Edinburg.Score",
  "Educational.level..nb.of.school.years.",
  "Reading_test_working_memory_score",
  "Listening_test_working_memory_score",
  "Vocab_extent",
  "Verbal_fluency_nouns_per_item",
  "Auditory_verbal_learning_recalled_words",
  "Auditory_verbal_learning_recalled_words_long_term",
  "Auditory_phonological_learning_recalled_pseudowords",
  "Auditory_phonological_learning_recalled_pseudowords_long_term",
  "Rhyme_judgement",
  "Phonological_awareness_structure_of_language",
  "Reading_speed",
  "Compressed_speech_comprehension_speed",
  "Mental_rotation",
  "Corsi_Block_test_visuospatial_span",
  "Topographic_orientation_labyrinth_score",
  "Non_verbal_reasoning_Ravens_matrices",
  "Arithmetical_facts_score",
  "Arithmetical_facts_score_response_time",
  "Complex_mental_calculation_score",
  "Complex_mental_calculation_score_response_time",
  "Linguistic_arithmetical_problem_score",
  "Linguistic_arithmetical_problem_response_time"
)



#Test the normality

# Select columns 3 to 12
cols_to_test <- 4:26

# Subset the dataframe
subset_df <- Cognitive_tests_filtered[, cols_to_test]



scaled_data <- scale(subset_df)

# Convert scaled matrix to data frame
scaled_df <- as.data.frame(scaled_data)

# Assign column names from original data frame
colnames(scaled_df) <- colnames(subset_df)

# Print class of scaled data frame
print(class(scaled_df))

# Perform Shapiro-Wilk test for normality on each column
shapiro_results <- lapply(scaled_df, shapiro.test)

# Print the results
print(shapiro_results)

# Set the significance level
alpha <- 0.05

# Initialize a vector to store column names with non-normal distributions
non_normal_cols <- c()

# Iterate over the Shapiro-Wilk test results
for (col_name in names(shapiro_results)) {
  # Check if the p-value is below the significance level
  if (shapiro_results[[col_name]]$p.value < alpha) {
    non_normal_cols <- c(non_normal_cols, col_name)
  }
}

# Print the columns with non-normal distributions
print(non_normal_cols)

# Assuming 'non_normal_cols' contains the names of columns that are not normally distributed
# Assuming 'scaled_df' is your scaled data frame

# Function to perform transformation (e.g., square root)
transform_column <- function(column) {
  return(log(column))  # Example: square root transformation
}

# Apply transformation to non-normal columns
transformed_cols <- lapply(scaled_df[non_normal_cols], transform_column)

# Replace original non-normal columns with transformed columns
scaled_df[non_normal_cols] <- transformed_cols

# Print the transformed data frame
print(scaled_df)



# Apply transformations to not normally distributed columns
transformed_df <- subset_df
for (col in not_normal_cols) {
  transformed_df[[col]] <- log(subset_df[[col]])  # Example: Applying logarithmic transformation
}

# Verify transformations
print(transformed_df)


# Check distribution of transformed data
par(mfrow=c(1, 1))  # Set up the layout for plots
for (i in 1:ncol(scaled_data)) {
  hist(scaled_data[, i], main=colnames(scaled_data)[i], xlab="Value")
}


# Perform Shapiro-Wilk test for each column
shapiro_results <- sapply(transformed_df, test_normality_shapiro)

cat("\nColumns not normally distributed (Shapiro-Wilk test):\n")

print(names(shapiro_results[shapiro_results < 0.05]))


# Add subject column to transformed_df
transformed_df$subject <- Cognitive_tests_filtered$subject


##Check for any nonmuerical stuff

# Assuming 'transformed_df' is your DataFrame
non_numeric_cols <- sapply(transformed_df, function(col) !is.numeric(col))

# Print column names that are non-numeric
print(names(transformed_df)[non_numeric_cols])


#PCA
library(ggplot2)
library(samr)

results_cognitive_fancy_PCA <- CBF_PCA(scaled_df, groups = FALSE, pcs=c(4,5), useLabels=TRUE,  type='loadings', )
summary(results_cognitive_fancy_PCA$pc)$importance[2,]*100

loadings <- results_cognitive_fancy_PCA$pc$rotation

loadpc2 <- sort(loadings[,2])

loadpc2_sorted <- sort(loadpc2)

top_20_index <- round(length(loadpc2_sorted) * 0.2)

top_20_percent <- loadpc2_sorted[(length(loadpc2_sorted) - top_10_index + 1):length(loadpc2_sorted)]

top_20_percent


library(samr)


CBF_PCA(transformed_df[, 2:11], paste(Cognitive_tests[, 1], Cognitive_tests[, 2], sep = "_"), legendName = "")



Cognitive_ <- transformed_df[, 2:11]


#K-means
KmeansResult <- kmeans(x = transformed_df[,1:10], centers = 4)

KmeansResult$cluster


result_k_means_pca <- CBF_PCA(transformed_df[,1:10], as.character(KmeansResult$cluster))

# Calculate the mean values of each variable within each cluster
cluster_means <- aggregate(t(Cognitive_), by = list(KmeansResult$cluster), FUN = mean)

# Print the mean values for each cluster
print(cluster_means)



#K-means from course

Cognitive_kmeans <- kmeans(x = transformed_df, centers = 4)
transposed_Cognitive <- t(Cognitive_)
Cognitive_$clusters <- Cognitive_kmeans$cluster


plot()