# Nextflow Germline Variant Calling Pipeline

A reproducible Nextflow DSL2 workflow for germline small-variant calling from paired-end Illumina FASTQ files through alignment, preprocessing, variant calling, hard filtering, QC, and GIAB benchmarking.

## Workflow

```text
Paired-end FASTQ
        ↓
      FastQC
        ↓
      fastp
        ↓
    BWA-MEM2
        ↓
samtools sort/index
        ↓
 GATK MarkDuplicates
        ↓
       BQSR
        ↓
 GATK HaplotypeCaller
        ↓
   GenotypeGVCFs
        ↓
 SNP / INDEL filtering
        ↓
     PASS VCF
        ↓
 GIAB hap.py benchmark
        ↓
      MultiQC
[Workflow diagram](assets/workflow_diagram.png)
