# Sub-sample fastq files with seqtk

This Nextflow pipeline will sub-sample fastq files to a given number of reads. It can work with paired data or single end.

Current parameters are:

- `params.reads`: path to reads, something like this: `*fastq.gz`
- `params.outdir`: your output path
- `params.sample_size`: number of reads

The pipeline was built in 30min with the help of [Seqera AI](https://seqera.io).