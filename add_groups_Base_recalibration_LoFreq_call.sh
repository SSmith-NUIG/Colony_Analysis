#!/bin/sh 
#SBATCH --job-name="brq"
#SBATCH -o /data/ssmith/logs/brq_%A_%a.out
#SBATCH -e /data/ssmith/logs/brq_%A_%a.err
#SBATCH --array=33-38,40-57%12
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -p highmem
#"$SLURM_ARRAY_TASK_ID"

echo PICARD ADD OR REPLACE GROUPS
picard AddOrReplaceReadGroups \
I=/data3/ssmith/ena/sorted_bams/A_"$SLURM_ARRAY_TASK_ID".sorted.dupM.bam \
O=/data3/ssmith/ena/sorted_bams/A_"$SLURM_ARRAY_TASK_ID".nobqsr.grpd.bam \
RGID=1 \
RGLB=lib1 \
RGPL=ILLUMINA \
RGPU=unit1 \
RGSM=A_"$SLURM_ARRAY_TASK_ID"

#rm /data3/ssmith/ena/sorted_bams/A_"$SLURM_ARRAY_TASK_ID".sorted.dupM.bam

echo BASE RECALIBRATOR
gatk BaseRecalibrator \
-I /data3/ssmith/ena/sorted_bams/A_"$SLURM_ARRAY_TASK_ID".nobqsr.grpd.bam  \
-R /data/ssmith/c_l_genome/apis_c_l_genome.fa \
--known-sites /data/ssmith/c_l_genome/known_snps_for_BQSR.vcf \
-O /data3/ssmith/ena/"$SLURM_ARRAY_TASK_ID"_recal_data.table \
--bqsr-baq-gap-open-penalty 30.0

echo BASE RECALIBRATOR APPLY BQSR
gatk ApplyBQSR \
-R /data/ssmith/c_l_genome/apis_c_l_genome.fa \
-I /data3/ssmith/ena/sorted_bams/A_"$SLURM_ARRAY_TASK_ID".nobqsr.grpd.bam \
--bqsr-recal-file /data3/ssmith/ena/"$SLURM_ARRAY_TASK_ID"_recal_data.table \
-O /data3/ssmith/ena/sorted_bams/brq/A_"$SLURM_ARRAY_TASK_ID".bam
#rm /data3/ssmith/ena/sorted_bams/A_"$SLURM_ARRAY_TASK_ID".nobqsr.grpd.bam
samtools index /data3/ssmith/ena/sorted_bams/brq/A_"$SLURM_ARRAY_TASK_ID".bam

lofreq call-parallel \
--pp-threads 8 \
-f /data/ssmith/c_l_genome/apis_c_l_genome.fa -o /data3/ssmith/ena/lofreq_vcf/"$SLURM_ARRAY_TASK_ID".vcf \
--call-indels \
/data3/ssmith/ena/sorted_bams/brq/A_"$SLURM_ARRAY_TASK_ID".bam
