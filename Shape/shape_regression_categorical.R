library(qdapRegex)
setwd("/Users/neuro235/Documents/Liverpool/Data_analysis/Connectometry/Connectometry_literature/Redoing_different_ROIs")
library(readxl)
demog <- read.csv("Demographics.csv")

# Merge the tables based on the 'subject' column
merged_data <- merge(Tractography, demog, by.x = "subject", by.y = "Subject", all.x = TRUE)

#save the table for all tract info
write.csv(merged_data, "Demographics_old_and_new_plusdiffusion.csv", row.names = FALSE)


##If importing data from the folder:

merged_data <- read.csv("Demographics_old_and_new_plusdiffusion.csv")


#Change measure to measures and tract to tracts 

colnames(merged_data)[colnames(merged_data) == "tract"] = "tracts"

colnames(merged_data)[colnames(merged_data) == "measure"] = "measures"

library(dplyr)

# Create a table with only "leftLat" and "biLat" in the 'laterality' column
LeftBilat <- merged_data %>%
  filter(laterality %in% c("leftLat", "biLat"))

# Create a table with subjects that are "biLat" or "rightLat"
RightBilat <- merged_data %>%
  filter(laterality %in% c("biLat", "rightLat"))

LeftRight <- merged_data %>%
  filter(laterality %in% c("leftLat", "rightLat"))


# Making sure I only work on tracts of interest

# List of tracts you want to keep
selected_tracts <- c(
  "Arcuate_Fasciculus_L", "Arcuate_Fasciculus_R", "Corpus_Callosum_Body",
  "Corpus_Callosum_Forceps_Major", "Corpus_Callosum_Forceps_Minor",
  "Fornix_L", "Fornix_R", "Frontal_Aslant_Tract_L", "Frontal_Aslant_Tract_R",
  "Inferior_Fronto_Occipital_Fasciculus_L", "Inferior_Fronto_Occipital_Fasciculus_R",
  "Superior_Longitudinal_Fasciculus1_L",
  "Superior_Longitudinal_Fasciculus1_R", "Superior_Longitudinal_Fasciculus2_L",
  "Superior_Longitudinal_Fasciculus2_R", "Superior_Longitudinal_Fasciculus3_L",
  "Superior_Longitudinal_Fasciculus3_R", "Uncinate_Fasciculus_L", "Uncinate_Fasciculus_R"
)

# Create a new table that includes only the selected tracts
LeftBilat <- LeftBilat %>%
  filter(tracts %in% selected_tracts)

RightBilat <- RightBilat %>%
  filter(tracts %in% selected_tracts)


LeftRight <- LeftRight %>%
  filter(tracts %in% selected_tracts)

# Assuming you have the 'LeftBilat' table with the selected tracts

# Create a vector of measures you want to perform t-tests on
measures_to_test <- c(
 "mean length(mm)", "span(mm)", "curl", "elongation",
  "diameter(mm)", "volume(mm^3)", "trunk volume(mm^3)", "branch volume(mm^3)",
  "total surface area(mm^2)", "qa", "nqa", "dti_fa", "md")



# Create a new table that includes only the selected measures
LeftBilat <- LeftBilat %>%
  filter(measures %in% measures_to_test)

RightBilat <- RightBilat %>%
  filter(measures %in% measures_to_test)


LeftRight <- LeftRight %>%
  filter(measures %in% measures_to_test)


# Filter the data for leftLat and biLat individuals
leftLat_data <- LeftBilat %>%
  filter(laterality == "leftLat")
biLat_data <- LeftBilat %>%
  filter(laterality == "biLat")

# Get unique tract names and measures
unique_tracts <- unique(LeftBilat$tracts)
unique_measures <- unique(LeftBilat$measures)


##CODE for the leftbilat

# Load the dplyr package if not already loaded
library(dplyr)

# Filter the data for leftLat and biLat individuals
leftLat_data <- LeftBilat %>%
  filter(laterality == "leftLat")
biLat_data <- LeftBilat %>%
  filter(laterality == "biLat")

# Get unique tract names and measures
unique_tracts <- unique(LeftBilat$tracts)
unique_measures <- unique(LeftBilat$measures)

# Create an empty data frame to store the results
results_df <- data.frame()



##t-test for left vs bilateral individuals 
# Loop through each tract and measure
for (tract in unique_tracts) {
  for (measure in unique_measures) {
    # Filter data for the current tract and measure
    leftLat_values <- leftLat_data %>%
      filter(tracts == tract, measures == measure) %>%
      select(value, Age_in_Yrs, Handedness, Gender)
    
    biLat_values <- biLat_data %>%
      filter(tracts == tract, measures == measure) %>%
      select(value, Age_in_Yrs, Handedness, Gender)
    
    # Combine leftLat and biLat data for regression
    combined_data <- bind_rows(leftLat_values, biLat_values)
    
    # Fit a linear model to regress out covariates
    lm_model <- lm(value ~ Age_in_Yrs + Handedness + Gender, data = combined_data)
    
    # Extract the residuals from the linear model
    residuals <- residuals(lm_model)
    
    # Perform a t-test on the residuals
    t_test_result <- t.test(residuals[1:length(leftLat_values)], residuals[(length(leftLat_values) + 1):length(residuals)])
    
    # Determine the directionality of the results
    direction <- ifelse(t_test_result$p.value < 0.05, 
                        ifelse(t_test_result$statistic > 0, "leftLat > biLat", "biLat > leftLat"),
                        "Not significant")
    
    # Check if the result is significant and print it
    if (t_test_result$p.value < 0.05) {
      cat("Tract:", tract, "\n")
      cat("Measure:", measure, "\n")
      cat("t-value:", t_test_result$statistic, "\n")
      cat("p-value:", t_test_result$p.value, "\n")
      cat("Directionality:", direction, "\n")
      cat("\n")
    }
    
    # Create a data frame with the results
    result_row <- data.frame(
      Tract = tract,
      Measure = measure,
      t_value = t_test_result$statistic,
      p_value = t_test_result$p.value,
      Directionality = direction
    )
    
    # Append the result to the results_df data frame
    results_df <- rbind(results_df, result_row)
  }
}




categorical_leftbilateral <- results_df


# Create a table with measures "dti_fa," "md," "qa," and "nqa"
categorical_leftbilateral_microstructural <- subset(results_df, Measure %in% c("dti_fa", "md", "qa", "nqa"))

# Create a table with the remaining measures
categorical_leftbilateral_shape <- subset(results_df, !Measure %in% c("dti_fa", "md", "qa", "nqa"))


##FDR correction

categorical_leftbilateral_microstructural$FDR_Corrected_PValue <- p.adjust(categorical_leftbilateral_microstructural$p_value, method = "fdr")

categorical_leftbilateral_shape$FDR_Corrected_PValue <- p.adjust(categorical_leftbilateral_shape$p_value, method = "fdr")




# Add new column of significance 
# Set the significance threshold
threshold <- 0.05

# Add a new column to indicate significance
categorical_leftbilateral_shape$Significance <- ifelse(categorical_leftbilateral_shape$FDR_Corrected_PValue < threshold, "Significant", "Not Significant")

##Now same for the rightbilat

# Load the dplyr package if not already loaded
library(dplyr)



# Filter the data for rightLat and biLat individuals
rightLat_data <- RightBilat %>%
  filter(laterality == "rightLat")
biLat_data <- RightBilat %>%
  filter(laterality == "biLat")




# Get unique tract names and measures
unique_tracts <- unique(RightBilat$tracts)
unique_measures <- unique(RightBilat$measures)

# Create an empty data frame to store the results
results_df <- data.frame()



##t-test for left vs bilateral individuals 
# Loop through each tract and measure
for (tract in unique_tracts) {
  for (measure in unique_measures) {
    # Filter data for the current tract and measure
    rightLat_values <- rightLat_data %>%
      filter(tracts == tract, measures == measure) %>%
      select(value, Age_in_Yrs, Handedness, Gender)
    
    biLat_values <- biLat_data %>%
      filter(tracts == tract, measures == measure) %>%
      select(value, Age_in_Yrs, Handedness, Gender)
    
    # Combine leftLat and biLat data for regression
    combined_data <- bind_rows(rightLat_values, biLat_values)
    
    # Fit a linear model to regress out covariates
    lm_model <- lm(value ~ Age_in_Yrs + Handedness + Gender, data = combined_data)
    
    # Extract the residuals from the linear model
    residuals <- residuals(lm_model)
    
    # Perform a t-test on the residuals
    t_test_result <- t.test(residuals[1:length(rightLat_values)], residuals[(length(rightLat_values) + 1):length(residuals)])
    
    # Determine the directionality of the results
    direction <- ifelse(t_test_result$p.value < 0.05, 
                        ifelse(t_test_result$statistic > 0, "rightLat > biLat", "biLat > rightLat"),
                        "Not significant")
    
    # Check if the result is significant and print it
    if (t_test_result$p.value < 0.05) {
      cat("Tract:", tract, "\n")
      cat("Measure:", measure, "\n")
      cat("t-value:", t_test_result$statistic, "\n")
      cat("p-value:", t_test_result$p.value, "\n")
      cat("Directionality:", direction, "\n")
      cat("\n")
    }
    
    # Create a data frame with the results
    result_row <- data.frame(
      Tract = tract,
      Measure = measure,
      t_value = t_test_result$statistic,
      p_value = t_test_result$p.value,
      Directionality = direction
    )
    
    # Append the result to the results_df data frame
    results_df <- rbind(results_df, result_row)
  }
}

                                                                                                      

categorical__rightbilateral <- results_df

# Create a table with measures "dti_fa," "md," "qa," and "nqa"
categorical__rightbilateral_microstructural <- subset(results_df, Measure %in% c("dti_fa", "md", "qa", "nqa"))



# Create a table with the remaining measures
categorical__rightbilateral_shape <- subset(results_df, !Measure %in% c("dti_fa", "md", "qa", "nqa"))

##FDR correction

categorical__rightbilateral_microstructural$FDR_Corrected_PValue <- p.adjust(categorical__rightbilateral_microstructural$p_value, method = "fdr")

categorical__rightbilateral_shape$FDR_Corrected_PValue <- p.adjust(categorical__rightbilateral_shape$p_value, method = "fdr")



##LeftBilat regression 


# Get unique tract names and measures
unique_tracts <- unique(LeftBilat$tracts)
unique_measures <- unique(LeftBilat$measures)

# Create an empty data frame to store the regression results
results_df <- data.frame()



# Loop through each tract and measure
for (tract in unique_tracts) {
  for (measure in unique_measures) {
    # Filter data for the current tract and measure
    current_tract_and_measure <- LeftBilat %>%
      filter(tracts == tract, measures == measure) %>%
      select(value, LI.y, Age_in_Yrs, Handedness, Gender)
    
    # Fit a linear model to regress out covariates
    lm_model <- lm(value ~ LI.y + Age_in_Yrs + Handedness + Gender, data = current_tract_and_measure)
    
    # Get regression summary
    summary_lm <- summary(lm_model)
    
    # Extract p-value for LI.y from the regression summary
    p_value <- summary_lm$coefficients["LI.y", "Pr(>|t|)"]
    
    # Extract the sign of the correlation coefficient
    correlation_sign <- ifelse(lm_model$coefficients["LI.y"] > 0, "Positive", "Negative")
    
    
    # Extract relevant coefficients and R-squared from the regression summary
    r_squared <- summary_lm$r.squared
    
    # Create a data frame with the results, including directionality and R-squared
    result_row <- data.frame(
      Tract = tract,
      Measure = measure,
      P_Value = p_value,
      Correlation_Sign = correlation_sign,
      R_Squared = r_squared
    )
    
    # Append the result to the results_df data frame
    results_df <- rbind(results_df, result_row)
    
  }
}


results_df_regression_leftbilateral <- results_df

# Create a table with measures "dti_fa," "md," "qa," and "nqa"
regression_leftbilateral_microstructural <- subset(results_df, Measure %in% c("dti_fa", "md", "qa", "nqa"))



# Create a table with the remaining measures
regression_leftbilateral_shape <- subset(results_df, !Measure %in% c("dti_fa", "md", "qa", "nqa", "number of tracts"))


# Apply FDR correction to p-values
regression_leftbilateral_microstructural$FDR_Corrected_PValue <- p.adjust(regression_leftbilateral_microstructural$P_Value, method = "fdr")

regression_leftbilateral_shape$FDR_Corrected_PValue <- p.adjust(regression_leftbilateral_shape$P_Value, method = "fdr")

##RightBilat regression 

#Change measure to measures and tract to tracts 

colnames(merged_data)[colnames(merged_data) == "tract"] = "tracts"

colnames(merged_data)[colnames(merged_data) == "measure"] = "measures"


# Load the dplyr package if not already loaded
library(dplyr)


# Get unique tract names and measures
unique_tracts <- unique(LeftBilat$tracts)
unique_measures <- unique(LeftBilat$measures)

# Create an empty data frame to store the results
results_df <- data.frame()


# Loop through each tract and measure
for (tract in unique_tracts) {
  for (measure in unique_measures) {
    # Filter data for the current tract and measure
    current_tract_and_measure <- RightBilat %>%
      filter(tracts == tract, measures == measure) %>%
      select(value, LI.y, Age_in_Yrs, Handedness, Gender)
    
    # Fit a linear model to regress out covariates
    lm_model <- lm(value ~ LI.y + Age_in_Yrs + Handedness + Gender, data = current_tract_and_measure)
    
    # Get regression summary
    summary_lm <- summary(lm_model)
    
    # Extract p-value for LI.y from the regression summary
    p_value <- summary_lm$coefficients["LI.y", "Pr(>|t|)"]
    
    # Extract the sign of the correlation coefficient
    correlation_sign <- ifelse(lm_model$coefficients["LI.y"] > 0, "Positive", "Negative")
    
    
    # Extract relevant coefficients and R-squared from the regression summary
    r_squared <- summary_lm$r.squared
    
    # Create a data frame with the results, including directionality and R-squared
    result_row <- data.frame(
      Tract = tract,
      Measure = measure,
      P_Value = p_value,
      Correlation_Sign = correlation_sign,
      R_Squared = r_squared
    )
    
    # Append the result to the results_df data frame
    results_df <- rbind(results_df, result_row)
    
  }
}


results_df_regression_rightbilateral <- results_df

# Create a table with measures "dti_fa," "md," "qa," and "nqa"
regression_rightbilateral_microstructural <- subset(results_df, Measure %in% c("dti_fa", "md", "qa", "nqa"))



# Create a table with the remaining measures
regression_rightbilateral_shape <- subset(results_df, !Measure %in% c("dti_fa", "md", "qa", "nqa"))




# Apply FDR correction to p-values
regression_rightbilateral_microstructural$FDR_Corrected_PValue <- p.adjust(regression_rightbilateral_microstructural$P_Value, method = "fdr")


regression_rightbilateral_shape$FDR_Corrected_PValue <- p.adjust(regression_rightbilateral_shape$P_Value, method = "fdr")

##Write results in tables 

write.csv(categorical_leftbilateral_microstructural, "categorical_leftbilateral_microstructural.csv", row.names = FALSE)
write.csv(categorical_leftbilateral_shape, "categorical_leftbilateral_shape.csv", row.names = FALSE)
write.csv(categorical__rightbilateral_microstructural, "categorical_rightbilateral_microstructural.csv", row.names = FALSE)
write.csv(categorical__rightbilateral_shape, "categorical_rightbilateral_shape.csv", row.names = FALSE)
write.csv(regression_leftbilateral_microstructural, "regression_leftbilateral_microstructural.csv", row.names = FALSE)
write.csv(regression_leftbilateral_shape, "regression_leftbilateral_shape.csv", row.names = FALSE)
write.csv(regression_rightbilateral_microstructural, "regression_rightbilateral_microstructural.csv", row.names = FALSE)
write.csv(regression_rightbilateral_shape, "regression_rightbilateral_shape.csv", row.names = FALSE)





#Code for left/right


##CODE for the leftbilat
#Change measure to measures and tract to tracts 

colnames(LeftRight)[colnames(LeftRight) == "tract"] = "tracts"

colnames(LeftRight)[colnames(LeftRight) == "measure"] = "measures"

# Filter the data for leftLat and biLat individuals
leftLat_data <- LeftRight %>%
  filter(laterality == "leftLat")
rightLat_data <- LeftRight %>%
  filter(laterality == "rightLat")




# Get unique tract names and measures
unique_tracts <- unique(LeftRight$tracts)
unique_measures <- unique(LeftRight$measures)


# Create an empty data frame to store the results
results_df <- data.frame()



##t-test for left vs bilateral individuals 
# Loop through each tract and measure
for (tract in unique_tracts) {
  for (measure in unique_measures) {
    # Filter data for the current tract and measure
    leftLat_values <- leftLat_data %>%
      filter(tracts == tract, measures == measure) %>%
      select(value, Age_in_Yrs, Handedness, Gender)
    
    rightLat_values <- rightLat_data %>%
      filter(tracts == tract, measures == measure) %>%
      select(value, Age_in_Yrs, Handedness, Gender)
    
    # Combine leftLat and biLat data for regression
    combined_data <- bind_rows(leftLat_values, rightLat_values)
    
    # Fit a linear model to regress out covariates
    lm_model <- lm(value ~ Age_in_Yrs + Handedness + Gender, data = combined_data)
    
    # Extract the residuals from the linear model
    residuals <- residuals(lm_model)
    
    # Perform a t-test on the residuals
    t_test_result <- t.test(residuals[1:length(leftLat_values)], residuals[(length(leftLat_values) + 1):length(residuals)])
    
    # Determine the directionality of the results
    direction <- ifelse(t_test_result$p.value < 0.05, 
                        ifelse(t_test_result$statistic > 0, "leftLat > rightLat", "rightLat > leftLat"),
                        "Not significant")
    
    # Check if the result is significant and print it
    if (t_test_result$p.value < 0.05) {
      cat("Tract:", tract, "\n")
      cat("Measure:", measure, "\n")
      cat("t-value:", t_test_result$statistic, "\n")
      cat("p-value:", t_test_result$p.value, "\n")
      cat("Directionality:", direction, "\n")
      cat("\n")
    }
    
    # Create a data frame with the results
    result_row <- data.frame(
      Tract = tract,
      Measure = measure,
      t_value = t_test_result$statistic,
      p_value = t_test_result$p.value,
      Directionality = direction
    )
    
    # Append the result to the results_df data frame
    results_df <- rbind(results_df, result_row)
  }
}




categorical_leftright <- results_df


# Create a table with measures "dti_fa," "md," "qa," and "nqa"
categorical_leftright_microstructural <- subset(results_df, Measure %in% c("dti_fa", "md", "qa", "nqa"))

# Create a table with the remaining measures
categorical_leftright_shape <- subset(results_df, !Measure %in% c("dti_fa", "md", "qa", "nqa"))


##FDR correction

categorical_leftright_microstructural$FDR_Corrected_PValue <- p.adjust(categorical_leftright_microstructural$p_value, method = "fdr")

categorical_leftright_shape$FDR_Corrected_PValue <- p.adjust(categorical_leftright_shape$p_value, method = "fdr")

# FDR significance column
categorical_leftright_microstructural$significant_after_FDR <- ifelse(categorical_leftright_microstructural$FDR_Corrected_PValue < 0.05, "yes", "no")
categorical_leftright_shape$significant_after_FDR <- ifelse(categorical_leftright_shape$FDR_Corrected_PValue < 0.05, "yes", "no")

# Print the updated data frame
print(categorical_leftright_microstructural)





##RIghtLeft regression 

# check normality
hist(LeftRight$LI.y)

# Create a QQ plot
qqnorm(LeftRight$LI.y)
qqline(LeftRight$LI.y)
ks.test(LeftRight$LI.y, "pnorm", mean = mean(LeftRight$LI.y), sd = sd(LeftRight$LI.y))



results_df <- data.frame()


# Loop through each tract and measure
for (tract in unique_tracts) {
  for (measure in unique_measures) {
    # Filter data for the current tract and measure
    current_tract_and_measure <- LeftRight %>%
      filter(tracts == tract, measures == measure)
    
    # Fit a linear model to regress out covariates
    lm_model <- lm(value ~ LI.y + Age_in_Yrs + Handedness + Gender, data = current_tract_and_measure)
    
    # Get regression summary
    summary_lm <- summary(lm_model)
    
    # Extract p-value for LI.y from the regression summary
    p_value <- summary_lm$coefficients["LI.y", "Pr(>|t|)"]
    
    # Extract the sign of the correlation coefficient
    correlation_sign <- ifelse(lm_model$coefficients["LI.y"] > 0, "Positive", "Negative")
    
    
    # Extract relevant coefficients and R-squared from the regression summary
    r_squared <- summary_lm$r.squared
    
    # Create a data frame with the results, including directionality and R-squared
    result_row <- data.frame(
      Tract = tract,
      Measure = measure,
      P_Value = p_value,
      Correlation_Sign = correlation_sign,
      R_Squared = r_squared
    )
    
    # Append the result to the results_df data frame
    results_df <- rbind(results_df, result_row)
    
  }
}


results_df_regression_rightleft <- results_df

# Create a table with measures "dti_fa," "md," "qa," and "nqa"
regression_rightleft_microstructural <- subset(results_df, Measure %in% c("dti_fa", "md", "qa", "nqa", "number of tracts"))



# Create a table with the remaining measures
regression_rightleft_shape <- subset(results_df, !Measure %in% c("dti_fa", "md", "qa", "nqa"))




# Apply FDR correction to p-values
regression_rightleft_microstructural$FDR_Corrected_PValue <- p.adjust(regression_rightleft_microstructural$P_Value, method = "fdr")


regression_rightleft_shape$FDR_Corrected_PValue <- p.adjust(regression_rightleft_shape$P_Value, method = "fdr")


# FDR significance column
regression_leftright_microstructural$significant_after_FDR <- ifelse(regression_leftright_microstructural$FDR_Corrected_PValue < 0.05, "yes", "no")
categorical_leftright_shape$significant_after_FDR <- ifelse(categorical_leftright_shape$FDR_Corrected_PValue < 0.05, "yes", "no")






merged_data$LI_Category <- as.factor(merged_data$laterality)
# List of unique LI categories
unique_categories <- unique(merged_data$LI_Category)

# Create an empty data frame to store the results
anova_results <- data.frame(
  Tract = character(),
  Measure = character(),
  Category = character(),
  F_Value = numeric(),
  P_Value = numeric()
)

# Loop through each tract and measure
for (tract in unique_tracts) {
  for (measure in unique_measures) {
    # Filter data for the current tract and measure
    current_tract_and_measure <- merged_data %>%
      filter(tracts == tract, measures == measure)
    
    # Perform ANOVA for different LI categories
    anova_model <- aov(value ~ LI_Category + Age_in_Yrs + Handedness + Gender, data = current_tract_and_measure)
    
    # Get ANOVA summary
    summary_anova <- summary(anova_model)
    
    # Extract F-value and p-value for LI_Category from the ANOVA summary
    f_value <- summary_anova[[1]]$`F value`[1]
    p_value <- summary_anova[[1]]$`Pr(>F)`[1]
    
    # Create a data frame with the ANOVA results
    anova_result_row <- data.frame(
      Tract = tract,
      Measure = measure,
      Category = "LI_Category",
      F_Value = f_value,
      P_Value = p_value
    )
    
    # Append the result to the anova_results data frame
    anova_results <- rbind(anova_results, anova_result_row)
  }
}

# Print the ANOVA results
print(anova_results)



# Create a table with measures "dti_fa," "md," "qa," and "nqa"
anova_microstructural <- subset(anova_results, Measure %in% c("dti_fa", "md", "qa", "nqa"))



# Create a table with the remaining measures
anova_shape <- subset(anova_results, !Measure %in% c("dti_fa", "md", "qa", "nqa"))




# Apply FDR correction to p-values
anova_microstructural$FDR_Corrected_PValue <- p.adjust(anova_microstructural$P_Value, method = "fdr")


anova_shape$FDR_Corrected_PValue <- p.adjust(anova_shape$P_Value, method = "fdr")


# FDR significance column
anova_microstructural$significant_after_FDR <- ifelse(anova_microstructural$FDR_Corrected_PValue < 0.05, "yes", "no")
anova_shape$significant_after_FDR <- ifelse(anova_shape$FDR_Corrected_PValue < 0.05, "yes", "no")






# Assuming anova_results contains your ANOVA results
# Filter the results for the specific tract and measure
significant_tract <- "Inferior_Fronto_Occipital_Fasciculus_R"
significant_measure <- "trunk volume(mm^3)"
filtered_data <- merged_data[merged_data$tracts == significant_tract & merged_data$measures == significant_measure, ]

# Perform Tukey's HSD post hoc test
tukey_results <- TukeyHSD(aov(value ~ LI_Category, data = filtered_data))

# Print the Tukey's HSD results
print(tukey_results)


# Assuming you've already performed Tukey's HSD test
significant_results <- tukey_results$LI_Category[, "p adj"] < 0.05

# Print the significant post hoc findings
significant_pairs <- tukey_results$LI_Category[significant_results, ]
print(significant_pairs)

library(ggplot2)
library(ggsignif)

# Create a boxplot
boxplot_plot <- ggplot(filtered_data, aes(x = LI_Category, y = value, fill = LI_Category)) +
  geom_boxplot() +
  labs(title = paste("Boxplot of", significant_measure, "for", significant_tract),
       x = "LI Category", y = significant_measure) +
  scale_fill_discrete(name = "LI Category") +
  theme_minimal() +
  geom_signif(comparisons = list(c("leftLat", "biLat"), c("rightLat", "biLat")), map_signif_level = TRUE)


# Print the boxplot
print(boxplot_plot)



# Filter the data for the significant pairs
significant_pairs <- tukey_results$Category[significant_results, ]

# Filter the data for the specific tract and measure
filtered_data <- merged_data %>%
  filter(Tract == significant_tract, Measure == significant_measure)

# Create a boxplot with significance stars
boxplot_plot <- ggplot(filtered_data, aes(x = LI_Category, y = value, fill = LI_Category)) +
  geom_boxplot() +
  labs(title = paste("Boxplot of", significant_measure, "for", significant_tract),
       x = "LI Category", y = significant_measure) +
  scale_fill_discrete(name = "LI Category") +
  theme_minimal() +
  geom_signif(comparisons = significant_pairs, map_signif_level = TRUE)  # Add significance stars

# Print the boxplot with significance stars
print(boxplot_plot)



