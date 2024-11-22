#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import the nf-core module
include { SEQTK_SAMPLE } from './modules/nf-core/seqtk/sample/main'

// Define the main workflow
workflow {
    // Create a channel for input files
    Channel
        .fromPath(params.reads, checkIfExists: true)
        .map { it -> 
            def meta = [id: it.baseName.replaceAll(/\.fastq|\.fq/, "")]
            def sample_size = params.sample_size
            [meta, it, sample_size]
        }
        .set { read_pairs_ch }

    // Run SEQTK_SAMPLE on each read pair
    SEQTK_SAMPLE(read_pairs_ch)

    // Publish the results
    SEQTK_SAMPLE.out.reads
        .map { meta, reads -> reads }
        .flatten()
        .set { output_ch }

    output_ch
        .map { it -> [ it, params.outdir ] }
        .collectFile(storeDir: params.outdir)
}