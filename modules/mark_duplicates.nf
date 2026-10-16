process MARK_DUPLICATES {

    tag "${sample_id}"

    publishDir "${params.outdir}/markduplicates", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id),
          path("${sample_id}.markdup.bam"),
          path("${sample_id}.markdup.bam.bai"),
          emit: bam

    path "${sample_id}.markdup.metrics.txt", emit: metrics

    script:
    """
    gatk MarkDuplicates \
      -I ${bam} \
      -O ${sample_id}.markdup.bam \
      -M ${sample_id}.markdup.metrics.txt \
      --CREATE_INDEX false

    samtools index \
      -@ ${task.cpus} \
      ${sample_id}.markdup.bam
    """
}
