#!/bin/bash
#SBATCH --job-name=Shape_CC



subject_dir="$1"


# Extract subject name from folder path
subject=$(basename "$subject_dir")

# Shape analysis

cd "${subject_dir}/final_outputs/${subject}/mni_space/bundles/" || continue

# Loop through each .trk file in the bundles directory
for file in *CC.trk; do
	filename=$(basename "$file" .trk)
	output="${filename%.trk}_shape_measures.json"

	scil_evaluate_bundles_individual_measures.py "$file" "$output"


