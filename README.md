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

## Results

Benchmarked against GIAB HG002 (GRCh38) with hap.py, inside the high-confidence regions.

| Variant type | F1 |
|---|---|
| SNP | 0.9975 |
| INDEL | 0.9942 |

## Requirements

- Nextflow (DSL2)
- Docker or Conda
- GRCh38 reference and GIAB truth set

## Running it

```bash
nextflow run main.nf -profile docker \
  --samplesheet samplesheet.csv \
  --outdir results
```

Resume a previous run with `-resume`.
