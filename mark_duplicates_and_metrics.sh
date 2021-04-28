#!/bin/sh

#SBATCH --job-name="picard_col"
#SBATCH --output=/data/ssmith/logs/picard_col_%A_%a.log
#SBATCH --array=33-38,40-57%12
#SBATCH -N 1
#SBATCH -n 2
#"$SLURM_ARRAY_TASK_ID"

sortedPath=/data3/ssmith/ena/sorted_bams

echo PICARD MARK DUPLICATES 
picard MarkDuplicates \
I="$sortedPath"/A_"$SLURM_ARRAY_TASK_ID".sorted.bam \
M="$sortedPath"/After_QC_Metrics/A_"$SLURM_ARRAY_TASK_ID"_dup_metrics.txt \
O="$sortedPath"/A_"$SLURM_ARRAY_TASK_ID".sorted.dupM.bam

rm "$sortedPath"/A_"$SLURM_ARRAY_TASK_ID".sorted.bam

picard CollectWgsMetrics \
I="$sortedPath"/A_"$SLURM_ARRAY_TASK_ID".sorted.dupM.bam \
O="$sortedPath"/After_QC_Metrics/A_"$SLURM_ARRAY_TASK_ID"_collect_wgs_metrics.txt \
R=/data/ssmith/c_l_genome/apis_c_l_genome.fa

echo SAMTOOLS FLAGSTAT
samtools flagstat "$sortedPath"/A_"$SLURM_ARRAY_TASK_ID".sorted.dupM.bam \
> "$sortedPath"/After_QC_Metrics/A_"$SLURM_ARRAY_TASK_ID"_flagstat.txt
