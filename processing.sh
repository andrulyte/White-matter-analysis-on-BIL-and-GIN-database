#!/bin/bash
#SBATCH --job-name=connectivity
#SBATCH --output="$subj_folder".out
#SBATCH --error="$subj_folder".err


subj_folder="$1"


AICHA_atlas="/beegfs_data/scratch/iandrulyte-diffusion/AICHA_v3_1x1x1_conv.nii.gz"

# Extract subject name from folder path
subj=$(basename "$subj_folder")

# Decompose connectivity - parcellating file
scil_decompose_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/"$subj"__plausible_mni_space.trk "$AICHA_atlas" "$subj_folder"/final_outputs/"$subj"/mni_space/"$subj"_parcelation.h5

