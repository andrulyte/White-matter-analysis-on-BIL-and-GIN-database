
#Just CC

import os
import json
import csv

# Define the directory containing the JSON files for all subjects
base_directory = "/beegfs_data/scratch/iandrulyte-diffusion/CC_shape_stuff"

# List to store filenames of JSON files with shape metrics for all subjects
json_files = []

# Iterate through each file in the subject directory
for filename in os.listdir(base_directory):
    if filename.endswith(".json"):
        json_files.append(os.path.join(base_directory, filename))

# Define the output file path
output_file = "/beegfs_data/scratch/iandrulyte-diffusion/shape_metrics_CC_final.csv"

# Open the output file in write mode
with open(output_file, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    
    # Write the header row
    writer.writerow(["Subject", "Tract Name", "Shape Metric", "Value"])
    
    # Iterate through each JSON file
    for filename in json_files:
        # Extract the subject ID and tract name from the filename
        subject_id = filename.split("/")[-1].split("_")[0]
        tract_name = filename.split("/")[-1].split("_")[-3]

        
        # Open and read the JSON file
        try:
            with open(filename, 'r') as file:
                data = json.load(file)
                # Iterate through each shape metric in the JSON data
                for metric, value_list in data.items():
                    # Write the subject ID, tract name, shape metric, and value to the CSV file
                    writer.writerow([subject_id, tract_name, metric, value_list[0]])
        except FileNotFoundError:
            pass

print("Shape metrics have been successfully written to shape_metrics_CC_final.csv.")

