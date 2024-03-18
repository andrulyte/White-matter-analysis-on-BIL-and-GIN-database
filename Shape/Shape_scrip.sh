#one subject

# Count total number of .trk files
total_files=$(ls -1 *_mni_space.trk 2>/dev/null | wc -l)
processed_files=0

# Loop through each .trk file in the directory
for file in *.trk; do
    # Extract filename without extension
    filename=$(basename "$file" .trk)
    
    # Define output filename without .trk extension
    output="${filename%.trk}_shape_measures.json"
    
    # Execute the command
    scil_evaluate_bundles_individual_measures.py "$file" "$output"
    
    # Increment processed files count
    ((processed_files++))
    
    # Calculate percentage done
    percentage=$((processed_files * 100 / total_files))
    
    # Print percentage done
    echo "Progress: $percentage%"
done




#All subjects 

#!/bin/bash

# Output directory
output_dir="/beegfs_data/scratch/iandrulyte-diffusion/"

# Initialize variables for tracking progress
total_files=0
processed_files=0

# Count total number of .trk files across all subjects
total_files=$(find /beegfs_data/scratch/iandrulyte-diffusion/*/final_outputs/*/mni_space/bundles/ -type f -name "*.trk" | wc -l)

# Iterate over subject directories
for subject_dir in /beegfs_data/scratch/iandrulyte-diffusion/*/; do
    subject=$(basename "$subject_dir")
    echo "Processing subject: $subject"

    # Change directory to the bundles directory for the subject
    cd "${subject_dir}final_outputs/${subject}/mni_space/bundles/" || continue

    # Loop through each .trk file in the bundles directory
    for file in *.trk; do
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


