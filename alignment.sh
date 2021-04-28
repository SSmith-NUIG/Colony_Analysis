#!/bin/sh

#SBATCH --job-name="align_col"
#SBATCH --output=/data/ssmith/logs/align_col_%A_%a.log
#SBATCH --array=33-38,40-57
#SBATCH -N 1
#SBATCH -n 4
#"$SLURM_ARRAY_TASK_ID"

bwa-mem2 mem -t 4 /data/ssmith/c_l_genome/apis_c_l_genome.fa  \
/data3/ssmith/ena/trimmed/A_"$SLURM_ARRAY_TASK_ID"_1.fq.gz \
/data3/ssmith/ena/trimmed/A_"$SLURM_ARRAY_TASK_ID"_2.fq.gz \
| samtools sort -@ 4 -o /data3/ssmith/ena/sorted_bams/A_"$SLURM_ARRAY_TASK_ID".sorted.bam
