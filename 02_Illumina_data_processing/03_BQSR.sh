#Date : 6/28//24 
#Author : Annika Laberge
#Purpose : Detect errors made by the sequencing machine when calling base quality scores. Last step in GATK's data pre-processing.

#Load dependencies 
module load gatk/4.2.0.0 

#Set working directory
WORK=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir

#Set ref genome and directory
GENOME=/fs02/Metzger/Analysis_Active/Mar_longDNA/refs/Mar.3.4.6.p1_Q30Q30A.fasta
GENOMEDIR=/fs02/Metzger/Analysis_Active/Mar_longDNA/refs

 gatk BaseRecalibrator \
   -I my_reads.bam \
   -R reference.fasta \
   --known-sites sites_of_variation.vcf \
   --known-sites another/optional/setOfSitesToMask.vcf \
   -O recal_data.table