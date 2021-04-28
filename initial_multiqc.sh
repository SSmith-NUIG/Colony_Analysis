#!/bin/sh 
#SBATCH --job-name="mqc"
#SBATCH -o /data/ssmith/logs/mqc_%A_%a.out
#SBATCH -e /data/ssmith/logs/mqc_%A_%a.err
#SBATCH -N 1
#SBATCH -n 2
#SBATCH -w compute26

multiqc -n col_multiqc \
/data3/ssmith/ena/sorted_bams/Metrics/* \
