#!/bin/sh

#Date : 7/2/24 
#Author : Annika Laberge
#Purpose : Call SNP's and Indels using HaplotypeCaller. Data must be mapped to ref genome, indexed, and duplicates marked before this step. 
#Note: Specifically, this is the GATK pipeline for calling variants on cohorts of samples using HaplotypeCaller in GVCF mode. 
    #This pipeline allows populations genotyping to be re-run easily as the available cohort grows.

#Load dependencies 
module load gatk/4.2.0.0 

#Set directory containg analysis-ready BAMs (input for step 1)
DEDUPED=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir/deduped

#Set output directory for variant called GVCF (output for step 1 and input for step 2)
VARIANTS=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir/variants

SAMPLE_MAPS=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir/sample_Maps

DB_IMPORT=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir/DBImport

#Get list of sample IDs 
cd "$WORK" || exit
LIST=$(cat sampleIDs.txt)

## STEP 1: Initial variant calling with HaplotypeCaller. 
for i in $LIST
do
    gatk HaplotypeCaller  \
        -R /fs02/Metzger/Analysis_Active/Mar_longDNA/refs/Mar.3.4.6.p1_Q30Q30A.fasta \
        -I $DEDUPED/Mar.3.4.6.p1."$i"_deduped.bam \
        -O $VARIANTS/Mar.3.4.6.p1."$i"_variants.g.vcf \
        -ERC GVCF \
        -pcr_indel_model NONE \
        --emitRefConfidence GVCF 
done

##STEP 2: Generate sample map file for step 3. 
for i in $LIST
do
    n=$(bcftools query -l $VARIANTS/Mar.3.4.6.p1."$i"_variants.g.vcf)
    echo "${n}""$(printf'\t')"$VARIANTS/Mar.3.4.6.p1."$i"_variants.g.vcf > SAMPLE_MAPS/"$i"_sample.map
done

cd $SAMPLE_MAPS || exit
cat ./*.map > cohortSample.map

## STEP 3: Data aggregation using GenomicsDBImport. Combines each samples GVCF into a single GVCFs for the whole cohort. Neccesary for next step.
    gatk GenomicsDBImport \
       --genomicsdb-workspace-path $DB_IMPORT \
       --batch-size 50 \
       --sample-name-map cohortSample.map \
       --tmp-dir fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir/tmp \
       --reader-threads 5

## STEP 4: Joint genotyping using GenotypeGVCFs to create the raw SNP and indel VCFs that are usually emitted by the callers.
 gatk GenotypeGVCFs \
   -R /fs02/Metzger/Analysis_Active/Mar_longDNA/refs/Mar.3.4.6.p1_Q30Q30A.fasta \
   -V gendb:$DB_IMPORT \
   -O /fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir/genotypedGVCFs.vcf.gz \
   --tmp-dir=fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir/tmp