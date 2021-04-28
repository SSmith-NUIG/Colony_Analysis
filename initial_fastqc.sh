#!/bin/sh

#SBATCH --job-name="fastqc_col"
#SBATCH --output=/data/ssmith/logs/fastqc_col_%A_%a.log
#SBATCH --array=33-38,40-57%12
#SBATCH -N 1
#SBATCH -n 2
#"$SLURM_ARRAY_TASK_ID"

source activate wgs_env

dirPath=/data3/ssmith/ena

echo BEGINNING FASTQC SCRIPT

fastqc "$dirPath"/A_"$SLURM_ARRAY_TASK_ID"*.fq.gz --noextract -t 6 -a /data3/ssmith/raw_data/adaptors_colony.txt --outdir=/Metrics
