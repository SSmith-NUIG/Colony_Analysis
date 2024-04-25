#!/usr/bin/env nextflow

params.reads = "${launchDir}/data2/ssmith/fastqs/*_{1,2}.fq.gz"

/**
 * Quality control fastq
 */

reads_ch = Channel
    .fromPath( params.reads )
    
process fastqc {

    input:
    path read  
    
    script:
    """
    fastqc ${read}
    """
}

workflow {
    fastqc(reads_ch)
}
