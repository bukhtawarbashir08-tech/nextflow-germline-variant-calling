process BWA_MEM2 {

    tag "${sample_id}"

    publishDir "${params.outdir}/alignment", mode: 'copy'

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    tuple val(sample_id),
          path("${sample_id}.sorted.bam"),
          path("${sample_id}.sorted.bam.bai"),
          emit: bam

    script:
    """
    bwa-mem2 mem \
      -t ${task.cpus} \
      -R '@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:ILLUMINA' \
      ${params.bwa_prefix} \
      ${read1} \
      ${read2} \
    | samtools sort \
      -@ ${task.cpus} \
      -o ${sample_id}.sorted.bam -

    samtools index \
      -@ ${task.cpus} \
      ${sample_id}.sorted.bam
    """
}


