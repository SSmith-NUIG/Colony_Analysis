#!/bin/sh

#SBATCH --job-name="adapt_col"
#SBATCH --output=/data/ssmith/logs/adapt_col_%A_%a.log
#SBATCH --array=33-38,40-57%12
#SBATCH -N 1
#SBATCH -n 2
#"$SLURM_ARRAY_TASK_ID"

trimmomatic \
PE \
/data3/ssmith/ena/A_"$SLURM_ARRAY_TASK_ID"_1.fq.gz \
/data3/ssmith/ena/A_"$SLURM_ARRAY_TASK_ID"_2.fq.gz \
/data3/ssmith/ena/trimmed/A_"$SLURM_ARRAY_TASK_ID"_1.fq.gz /data3/ssmith/ena/discarded/A_"$SLURM_ARRAY_TASK_ID"_1.fq.gz \
/data3/ssmith/ena/trimmed/A_"$SLURM_ARRAY_TASK_ID"_2.fq.gz /data3/ssmith/ena/discarded/A_"$SLURM_ARRAY_TASK_ID"_2.fq.gz \
ILLUMINACLIP:adapters.fa:2:30:10 \
MINLEN:50
