#!/usr/bin/env nextflow

params.reads = "${launchDir}/data2/ssmith/fastqs/*_{1,2}.fq.gz"
params.outdir = "${launchDir}/data2/ssmith/fastqc/results"

log.info """\
      LIST OF PARAMETERS
================================
Reads            : ${params.reads}
Output-folder    : ${params.outdir}/
"""

// create read channel
read_pairs_ch = Channel
      .fromFilePairs(params.reads, checkIfExists:true)
      
// Define fastqc process
process fastqc {
  publishDir "${params.outdir}/quality-control-${sample}/", mode: 'copy', overwrite: true
  
  input:
  tuple val(sample), path(reads)  // from is omitted

  output:
  path("*_fastqc.{zip,html}") 

  script:
  """
  fastqc ${reads}
  """
}

// run the workflow
workflow {
	read_pairs_ch.view()
	fastqc(read_pairs_ch) 
}
