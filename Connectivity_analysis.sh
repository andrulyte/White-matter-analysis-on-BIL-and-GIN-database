

#This command is useful to filtering the connections that are 90% zero 

scripts/scil_connectivity_filter.py






#!/bin/bash

# Path to the folder containing subject folders
subjects_folder="/beegfs_data/scratch/iandrulyte-diffusion"

# Path to the AICHA_v3_1x1x1_conv.nii.gz file
AICHA_atlas="/beegfs_data/scratch/iandrulyte-diffusion/AICHA_v3_1x1x1_conv.nii.gz"

# Count total number of subject folders starting with "t0"
total_subjects=$(find "$subjects_folder" -maxdepth 1 -type d -name "t0*" | wc -l)

# Initialize counter for completed subjects
processing_subject=0

# Iterate over subject folders starting with "t0"
for subj_folder in "$subjects_folder"/t0*
do
    # Increment completed subjects counter
    ((processing_subject++))
    # Calculate percentage completion
    percentage=$((processing_subject * 100 / total_subjects))
    
    # Print progress
    echo "Progress: $percentage%"

    # Extract subject name from folder path
    subj=$(basename "$subj_folder")

    # Decompose connectivity - parcellating file
    scil_decompose_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/"$subj"__plausible_mni_space.trk "$AICHA_atlas" "$subj_folder"/final_outputs/"$subj"/mni_space/parcelation.h5

    # Compute connectivity matrix - streamline count
    scil_compute_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/parcelation.h5 "$AICHA_atlas"  --streamline_count "$subj_folder"/final_outputs/"$subj"/mni_space/connectivity_streamline_count.npy 
    

    # Compute connectivity matrix - length 

    scil_compute_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/parcelation.h5 "$AICHA_atlas" --length "$subj_folder"/final_outputs/"$subj"/mni_space/connectivity_length.npy

    # Compute FA
    #scil_compute_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/parcelation.h5 "$AICHA_atlas"  --metrics /beegfs_data/scratch/iandrulyte-diffusion/FA_maps/"$subj"/*__fa_in_JHU_MNI.nii.gz /beegfs_data/scratch/iandrulyte-diffusion/FA_maps/"$subj"/connectivity_FA.npy

done


#FA - compute connectivity matrices

# Path to the folder containing subject folders
subjects_folder="/beegfs_data/scratch/iandrulyte-diffusion"

# Path to the AICHA_v3_1x1x1_conv.nii.gz file
AICHA_atlas="/beegfs_data/scratch/iandrulyte-diffusion/AICHA_v3_1x1x1_conv.nii.gz"

# Count total number of subject folders starting with "t0"
total_subjects=$(find "$subjects_folder" -maxdepth 1 -type d -name "t0*" | wc -l)

# Initialize counter for completed subjects
processing_subject=0

# Iterate over subject folders starting with "t0"
for subj_folder in "$subjects_folder"/t0*
do
    # Increment completed subjects counter
    ((processing_subject++))
    # Calculate percentage completion
    percentage=$((processing_subject * 100 / total_subjects))
    
    # Print progress
    echo "Progress: $percentage%"

    # Extract subject name from folder path
    subj=$(basename "$subj_folder")


    # Compute FA
    scil_compute_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/parcelation.h5 "$AICHA_atlas"  --metrics /beegfs_data/scratch/iandrulyte-diffusion/FA_maps/for_Ieva_FA_maps/"$subj"/*__fa_in_JHU_MNI.nii.gz /beegfs_data/scratch/iandrulyte-diffusion/FA_maps/"$subj"/connectivity_FA.npy

    
    
done


#Compute FA connectivity matrices on my mac:

#!/bin/bash

# Define the path to the AICHA atlas
AICHA_atlas="/Users/neuro-240/Documents/BIL_and_GIN_Visit/AICHA_v3_1x1x1_conv.nii.gz"

# Define the directory containing the files with subject IDs
fa_maps_dir="/Users/neuro-240/Documents/BIL_and_GIN_Visit/all_subjects_fa_maps/"

# Iterate over files in the directory
for file in "$fa_maps_dir"*.nii.gz; do
    # Extract the subject ID from the filename
    subj=$(basename "$file" | sed 's/__fa_in_JHU_MNI.nii.gz//')

    # Run the command for the current subject ID
    scil_compute_connectivity.py /Users/neuro-240/Documents/BIL_and_GIN_Visit/parcelation_files/ "${subj}_parcelation.h5" "$AICHA_atlas" --metrics "$file" "/Users/neuro-240/Documents/BIL_and_GIN_Visit/FA_connectivity/${subj}_connectivity_FA.npy"
done


