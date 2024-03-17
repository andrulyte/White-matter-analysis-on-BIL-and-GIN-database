#!/bin/bash

# Path to the folder containing subject folders
subjects_folder="/beegfs_data/scratch/iandrulyte-diffusion"

# Submit one job per subject
for subj_folder in "$subjects_folder"/t0*
do
    sbatch processing.sh "$subj_folder"
done
