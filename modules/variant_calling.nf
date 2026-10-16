process HAPLOTYPE_CALLER {

    tag "${sample_id}"

    publishDir "${params.outdir}/variants/gvcf", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id),
          path("${sample_id}.g.vcf.gz"),
          path("${sample_id}.g.vcf.gz.tbi"),
          emit: gvcf

    script:
    """
    gatk HaplotypeCaller \
      -R ${params.reference} \
      -I ${bam} \
      -L ${params.interval} \
      -ERC GVCF \
      --native-pair-hmm-threads ${task.cpus} \
      --create-output-variant-index false \
      -O ${sample_id}.g.vcf.gz

    bcftools index -t ${sample_id}.g.vcf.gz
    """
}


process GENOTYPE_GVCF {

    tag "${sample_id}"

    publishDir "${params.outdir}/variants/vcf", mode: 'copy'

    input:
    tuple val(sample_id), path(gvcf), path(gvcf_index)

    output:
    tuple val(sample_id),
          path("${sample_id}.vcf.gz"),
          path("${sample_id}.vcf.gz.tbi"),
          emit: vcf

    script:
    """
    gatk GenotypeGVCFs \
      -R ${params.reference} \
      -V ${gvcf} \
      -L ${params.interval} \
      --create-output-variant-index false \
      -O ${sample_id}.vcf.gz

    bcftools index -t ${sample_id}.vcf.gz
    """
}
