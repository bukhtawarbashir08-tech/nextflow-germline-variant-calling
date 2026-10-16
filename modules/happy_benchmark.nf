process HAPPY_BENCHMARK {

    tag "${sample_id}"

    conda "${projectDir}/envs/happy.yml"

    publishDir "${params.outdir}/benchmark", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), path(vcf_index)

    output:
    path "${sample_id}.summary.csv", emit: summary
    path "${sample_id}.extended.csv", emit: extended

    script:
    """
    hap.py \
      ${params.truth_vcf} \
      ${vcf} \
      -f ${params.confident_bed} \
      -r ${params.reference} \
      -o ${sample_id} \
      --engine=vcfeval \
      --engine-vcfeval-template ${params.reference_sdf} \
      --threads=${task.cpus}
    """
}
