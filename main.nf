nextflow.enable.dsl=2

include { FASTQC } from './modules/fastqc'
include { FASTP } from './modules/fastp'
include { BWA_MEM2 } from './modules/bwa_mem2'
include { MARK_DUPLICATES } from './modules/mark_duplicates'
include { BASE_RECALIBRATOR; APPLY_BQSR } from './modules/bqsr'
include { HAPLOTYPE_CALLER; GENOTYPE_GVCF } from './modules/variant_calling'
include { MULTIQC } from './modules/multiqc'

include {
    SELECT_SNPS
    FILTER_SNPS
    SELECT_INDELS
    FILTER_INDELS
    MERGE_FILTERED_VARIANTS
    PASS_VARIANTS
} from './modules/variant_filtering'

include { HAPPY_BENCHMARK } from './modules/happy_benchmark'

workflow {

    samples_ch = Channel
        .fromPath(params.samplesheet, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            def r1 = file("${projectDir}/${row.fastq_1}", checkIfExists: true)
            def r2 = file("${projectDir}/${row.fastq_2}", checkIfExists: true)

            tuple(row.sample, [r1, r2])
        }

    FASTQC(samples_ch)

    FASTP(samples_ch)

    BWA_MEM2(FASTP.out.trimmed_reads)

    MARK_DUPLICATES(BWA_MEM2.out.bam)

    BASE_RECALIBRATOR(MARK_DUPLICATES.out.bam)

    APPLY_BQSR(BASE_RECALIBRATOR.out.recal_table)

    HAPLOTYPE_CALLER(APPLY_BQSR.out.bam)

    GENOTYPE_GVCF(HAPLOTYPE_CALLER.out.gvcf)

    SELECT_SNPS(GENOTYPE_GVCF.out.vcf)

    FILTER_SNPS(SELECT_SNPS.out.snps)

    SELECT_INDELS(GENOTYPE_GVCF.out.vcf)

    FILTER_INDELS(SELECT_INDELS.out.indels)

    filtered_for_merge =
        FILTER_SNPS.out.filtered_snps
        .join(FILTER_INDELS.out.filtered_indels)
        .map {
            sample_id,
            snp_vcf,
            snp_index,
            indel_vcf,
            indel_index ->

            tuple(
                sample_id,
                snp_vcf,
                snp_index,
                indel_vcf,
                indel_index
            )
        }

    MERGE_FILTERED_VARIANTS(filtered_for_merge)

    PASS_VARIANTS(MERGE_FILTERED_VARIANTS.out.filtered_vcf)

    HAPPY_BENCHMARK(PASS_VARIANTS.out.pass_vcf)

    qc_files = FASTQC.out.html
        .mix(FASTQC.out.zip)
        .mix(FASTP.out.html)
        .mix(FASTP.out.json)
        .mix(MARK_DUPLICATES.out.metrics)
        .collect()

    MULTIQC(qc_files)
}
