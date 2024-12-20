process SEQTK_SAMPLE {
    tag "$meta.id"
    label 'process_single'

    // conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/35/35c9d3a088cab839e44382e573b78a80e8087e7f71773e4c938e365e837d35b7/data' :
        'community.wave.seqera.io/library/seqkit:825acf14813a21d5' }"

    input:
    tuple val(meta), path(reads), val(sample_size)

    output:
    tuple val(meta), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (!(args ==~ /.*-s[0-9]+.*/)) {
        args += " -s 100"
    }
    if ( !sample_size ) {
        error "SEQTK/SAMPLE must have a sample_size value included"
    }
    """
    zcat $reads | seqkit shuffle $args -o test.fastq
    seqkit head -n $sample_size test.fastq -o ${prefix}_sub.fastq.gz 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqkit: 2.9
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo "" | gzip > ${prefix}.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqkit: 2.9
    END_VERSIONS
    """

}
