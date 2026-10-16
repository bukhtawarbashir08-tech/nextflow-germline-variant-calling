process BASE_RECALIBRATOR {

    tag "${sample_id}"

    publishDir "${params.outdir}/bqsr", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id),
          path(bam),
          path(bai),
          path("${sample_id}.recal.table"),
          emit: recal_table

    script:
    """
    gatk BaseRecalibrator \
      -R ${params.reference} \
      -I ${bam} \
      --known-sites ${params.dbsnp} \
      --known-sites ${params.known_indels} \
      --known-sites ${params.mills} \
      -L ${params.interval} \
      -O ${sample_id}.recal.table
    """
}


process APPLY_BQSR {

    tag "${sample_id}"

    publishDir "${params.outdir}/bqsr", mode: 'copy'

    input:
    tuple val(sample_id),
          path(bam),
          path(bai),
          path(recal_table)

    output:
    tuple val(sample_id),
          path("${sample_id}.recal.bam"),
          path("${sample_id}.recal.bam.bai"),
          emit: bam

    script:
    """
    gatk ApplyBQSR \
      -R ${params.reference} \
      -I ${bam} \
      --bqsr-recal-file ${recal_table} \
      -L ${params.interval} \
      -O ${sample_id}.recal.bam

    samtools index \
      -@ ${task.cpus} \
      ${sample_id}.recal.bam
    """
}

