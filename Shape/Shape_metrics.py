import os
import json
import csv

# Define the directory containing the JSON files for all subjects
base_directory = "/beegfs_data/scratch/iandrulyte-diffusion/"

# List to store filenames of JSON files with shape metrics for all subjects
json_files = []

# Iterate through each subject directory
for subject_dir in os.listdir(base_directory):
    subject_directory = os.path.join(base_directory, subject_dir, "final_outputs", subject_dir, "mni_space", "bundles")
    if os.path.isdir(subject_directory):
        # Iterate through each file in the subject directory
        for filename in os.listdir(subject_directory):
            if filename.endswith("mni_space_shape_measures.json"):
                json_files.append(os.path.join(subject_directory, filename))

# Define the output file path
output_file = "/beegfs_data/scratch/iandrulyte-diffusion/shape_metrics.csv"

# Open the output file in write mode
with open(output_file, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    
    # Write the header row
    writer.writerow(["Subject", "Tract Name", "Shape Metric", "Value"])
    
    # Iterate through each JSON file
    for filename in json_files:
        # Extract the subject ID and tract name from the filename
        subject_id = filename.split("/")[-4]
        tract_name = filename.split("/")[-1].split("CC_shape_measures.json")[0]
        
        # Remove "__" and everything before that in tract name
        tract_name = tract_name.split("__")[-1]
        
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

print("Shape metrics have been successfully written to shape_metrics.csv.")


#Just CC

import os
import json
import csv

# Define the directory containing the JSON files for all subjects
base_directory = "/beegfs_data/scratch/iandrulyte-diffusion/"

# List to store filenames of JSON files with shape metrics for all subjects
json_files = []

# Iterate through each subject directory
for subject_dir in os.listdir(base_directory):
    subject_directory = os.path.join(base_directory, subject_dir, "final_outputs", subject_dir, "mni_space", "bundles")
    if os.path.isdir(subject_directory):
        # Iterate through each file in the subject directory
        for filename in os.listdir(subject_directory):
            if filename.endswith("CC.json"):
                json_files.append(os.path.join(subject_directory, filename))

# Define the output file path
output_file = "/beegfs_data/scratch/iandrulyte-diffusion/shape_metrics_CC.csv"

# Open the output file in write mode
with open(output_file, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    
    # Write the header row
    writer.writerow(["Subject", "Tract Name", "Shape Metric", "Value"])
    
    # Iterate through each JSON file
    for filename in json_files:
        # Extract the subject ID and tract name from the filename
        subject_id = filename.split("/")[-4]
        tract_name = filename.split("t0003_t0003_cc_homotopic_")[-1].split("_shape_measures")[0]
        

        
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

print("Shape metrics have been successfully written to shape_metrics_CC.csv.")

