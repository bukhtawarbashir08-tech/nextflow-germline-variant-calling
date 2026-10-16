process FASTP {

    tag "${sample_id}"

    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id),
          path("${sample_id}_R1.trimmed.fastq.gz"),
          path("${sample_id}_R2.trimmed.fastq.gz"),
          emit: trimmed_reads

    path "${sample_id}_fastp.html", emit: html
    path "${sample_id}_fastp.json", emit: json

    script:
    """
    fastp \
      -i ${reads[0]} \
      -I ${reads[1]} \
      -o ${sample_id}_R1.trimmed.fastq.gz \
      -O ${sample_id}_R2.trimmed.fastq.gz \
      --html ${sample_id}_fastp.html \
      --json ${sample_id}_fastp.json \
      --thread ${task.cpus}
    """
}
