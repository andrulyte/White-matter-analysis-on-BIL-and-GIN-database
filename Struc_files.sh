#!/bin/bash

# Path to the folder containing subject folders
subjects_folder="/beegfs_data/scratch/iandrulyte-diffusion"
output_dir="/beegfs_data/scratch/iandrulyte-diffusion/streamline_count_matrices/"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Iterate over subject folders starting with "t0"
for subj_folder in "$subjects_folder"/t0*
do
    # Extract subject name from folder path
    subj=$(basename "$subj_folder")

    # Check if the npy file exists
    npy_file="$subj_folder/final_outputs/$subj/mni_space/connectivity_streamline_count.npy"
    if [ -f "$npy_file" ]; then
        # Copy npy file and prefix with subject ID
        echo "Copying $npy_file..."
        cp "$npy_file" "$output_dir/${subj}_connectivity_streamline_count.npy"
    else
        echo "Error: $npy_file not found."
    fi
done


#Zip directory 

zip -r streamline_count_matrices.zip streamline_count_matrices
