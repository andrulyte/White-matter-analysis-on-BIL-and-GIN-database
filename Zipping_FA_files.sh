#!/bin/bash

# Path to the directory containing subject folders
subject_dir="/beegfs_data/scratch/iandrulyte-diffusion/FA_maps/for_Ieva_FA_maps/"

# Destination directory for zipped files
destination_dir="/beegfs_data/scratch/iandrulyte-diffusion/FA_maps/"

# Name for the zip file
zip_filename="all_subjects_fa_maps.zip"

# Create the destination directory if it doesn't exist
mkdir -p "${destination_dir}"

# Loop through all subject folders
find "${subject_dir}" -type f -name '*.nii.gz' -exec zip -j "${destination_dir}${zip_filename}" {} +

echo "All .nii.gz files zipped into ${destination_dir}${zip_filename}"





#Zipping 