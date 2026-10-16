process SELECT_SNPS {

    tag "${sample_id}"

    publishDir "${params.outdir}/variants/filtering", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), path(vcf_index)

    output:
    tuple val(sample_id),
          path("${sample_id}.snps.vcf.gz"),
          path("${sample_id}.snps.vcf.gz.tbi"),
          emit: snps

    script:
    """
    gatk SelectVariants \
      -R ${params.reference} \
      -V ${vcf} \
      --select-type-to-include SNP \
      --create-output-variant-index false \
      -O ${sample_id}.snps.vcf.gz

    bcftools index -t ${sample_id}.snps.vcf.gz
    """
}


process FILTER_SNPS {

    tag "${sample_id}"

    publishDir "${params.outdir}/variants/filtering", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), path(vcf_index)

    output:
    tuple val(sample_id),
          path("${sample_id}.snps.filtered.vcf.gz"),
          path("${sample_id}.snps.filtered.vcf.gz.tbi"),
          emit: filtered_snps

    script:
    """
    gatk VariantFiltration \
      -R ${params.reference} \
      -V ${vcf} \
      --filter-name "QD2" \
      --filter-expression "QD < 2.0" \
      --filter-name "FS60" \
      --filter-expression "FS > 60.0" \
      --filter-name "SOR3" \
      --filter-expression "SOR > 3.0" \
      --filter-name "MQ40" \
      --filter-expression "MQ < 40.0" \
      --filter-name "MQRankSum-12.5" \
      --filter-expression "MQRankSum < -12.5" \
      --filter-name "ReadPosRankSum-8" \
      --filter-expression "ReadPosRankSum < -8.0" \
      --create-output-variant-index false \
      -O ${sample_id}.snps.filtered.vcf.gz

    bcftools index -t ${sample_id}.snps.filtered.vcf.gz
    """
}


process SELECT_INDELS {

    tag "${sample_id}"

    publishDir "${params.outdir}/variants/filtering", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), path(vcf_index)

    output:
    tuple val(sample_id),
          path("${sample_id}.indels.vcf.gz"),
          path("${sample_id}.indels.vcf.gz.tbi"),
          emit: indels

    script:
    """
    gatk SelectVariants \
      -R ${params.reference} \
      -V ${vcf} \
      --select-type-to-include INDEL \
      --create-output-variant-index false \
      -O ${sample_id}.indels.vcf.gz

    bcftools index -t ${sample_id}.indels.vcf.gz
    """
}


process FILTER_INDELS {

    tag "${sample_id}"

    publishDir "${params.outdir}/variants/filtering", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), path(vcf_index)

    output:
    tuple val(sample_id),
          path("${sample_id}.indels.filtered.vcf.gz"),
          path("${sample_id}.indels.filtered.vcf.gz.tbi"),
          emit: filtered_indels

    script:
    """
    gatk VariantFiltration \
      -R ${params.reference} \
      -V ${vcf} \
      --filter-name "QD2" \
      --filter-expression "QD < 2.0" \
      --filter-name "FS200" \
      --filter-expression "FS > 200.0" \
      --filter-name "SOR10" \
      --filter-expression "SOR > 10.0" \
      --filter-name "ReadPosRankSum-20" \
      --filter-expression "ReadPosRankSum < -20.0" \
      --create-output-variant-index false \
      -O ${sample_id}.indels.filtered.vcf.gz

    bcftools index -t ${sample_id}.indels.filtered.vcf.gz
    """
}


process MERGE_FILTERED_VARIANTS {

    tag "${sample_id}"

    publishDir "${params.outdir}/variants/filtered", mode: 'copy'

    input:
    tuple val(sample_id),
          path(snp_vcf),
          path(snp_index),
          path(indel_vcf),
          path(indel_index)

    output:
    tuple val(sample_id),
          path("${sample_id}.filtered.vcf.gz"),
          path("${sample_id}.filtered.vcf.gz.tbi"),
          emit: filtered_vcf

    script:
    """
    gatk MergeVcfs \
      -I ${snp_vcf} \
      -I ${indel_vcf} \
      -O ${sample_id}.filtered.vcf.gz \
      --CREATE_INDEX false

    bcftools index -t ${sample_id}.filtered.vcf.gz
    """
}


process PASS_VARIANTS {

    tag "${sample_id}"

    publishDir "${params.outdir}/variants/pass", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), path(vcf_index)

    output:
    tuple val(sample_id),
          path("${sample_id}.PASS.vcf.gz"),
          path("${sample_id}.PASS.vcf.gz.tbi"),
          emit: pass_vcf

    script:
    """
    bcftools view \
      -f PASS \
      -Oz \
      -o ${sample_id}.PASS.vcf.gz \
      ${vcf}

    bcftools index -t ${sample_id}.PASS.vcf.gz
    """
}
