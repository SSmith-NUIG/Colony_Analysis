# Colony_Analysis
Honeybee colony analysis

First run initial_fastqc.sh then initial_mutliqc.sh to get a look at the data quality

Next, trimming.sh to trim the reads before alignment.

Now run alignment.sh to align the reads to the genome

Mark duplicates and collect some alignment metrics using mark_duplicates_and_metrics.sh

To run base recalibration and create VCF files using lofreq, run add_groups_Base_recalibration_Lofreq_call.sh
