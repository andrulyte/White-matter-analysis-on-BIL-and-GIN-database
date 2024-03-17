#!/bin/bash

# Output directory
output_dir="/beegfs_data/scratch/iandrulyte-diffusion/"

# Directory paths
dir_work="/beegfs_data/scratch/iandrulyte-diffusion/tmp/extract_CC"

# Initialize variables for tracking progress
total_files=0
processed_files=0

# Count total number of .trk files across all subjects
total_files=$(find /beegfs_data/scratch/iandrulyte-diffusion/*/final_outputs/*/mni_space/bundles/ -type f -name "*.trk" | wc -l)

# Iterate over subject directories
for subject_dir in /beegfs_data/scratch/iandrulyte-diffusion/*/; do
    subject=$(basename "$subject_dir")
    echo "Processing subject: $subject"

    # Directory paths specific to each subject
    dir_orig="${subject_dir}final_outputs/${subject}/mni_space/bundles"

    # Preprocessing steps for the specific subject
    # Concatenate CC_homotopic trk files
    scil_tractogram_math.py concatenate "$dir_orig"/${subject}__cc_homotopic_*tal*.trk "$dir_orig"/${subject}__cc_homotopic_all.trk -f

    # Filter out the concatenated trk using filtering lists
    scil_filter_tractogram.py "$dir_orig"/${subject}__cc_homotopic_all.trk "$dir_orig"/${subject}__cc_homotopic_GCC.trk --filtering_list "$dir_work"/filtering_list_GCC.txt -f
    scil_filter_tractogram.py "$dir_orig"/${subject}__cc_homotopic_all.trk "$dir_orig"/${subject}__cc_homotopic_BCC.trk --filtering_list "$dir_work"/filtering_list_BCC.txt -f
    scil_filter_tractogram.py "$dir_orig"/${subject}__cc_homotopic_all.trk "$dir_orig"/${subject}__cc_homotopic_SCC.trk --filtering_list "$dir_work"/filtering_list_SCC.txt -f

    # Change directory to the bundles directory for the subject
    cd "$dir_orig" || continue

    # Loop through each .trk file in the bundles directory
    for file in *CC.trk; do
        # Extract filename without extension
        filename=$(basename "$file" .trk)

        # Define output filename without .trk extension
        output="${output_dir}${subject}_${filename%.trk}_shape_measures.json"

        # Execute the command
        echo "Processing file: $file"
        scil_evaluate_bundles_individual_measures.py "$file" "$output"

        # Increment processed files count for the overall progress
        ((processed_files++))

        # Calculate overall progress percentage
        overall_percentage=$((processed_files * 100 / total_files))

        # Print overall progress percentage
        echo "Overall Progress: $overall_percentage% ($processed_files out of $total_files files)"
    done
done
