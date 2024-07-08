#!/bin/bash

#Date : 7/8/24 
#Author : Annika Laberge
#Purpose : Mark duplicates and sort BAM outputs from mapping to reference genome. Second step in GATK pipeline's data pre-processing.
        # An alternative option to using MarkDuplicatesSpark.


#Load dependencies 
module load gatk/4.2.0.0 

#Set working directory
WORK=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir

#Get list of sample IDs 
cd $WORK || exit
LIST=$(cat sampleIDs.txt)

#Dedupe and sort using MarkDuplicatesSpark
for i in $LIST
do
gatk MarkDuplicates \
      -I $WORK/RG_Added/Mar.3.4.6.p1."$i".bam \
      -O $WORK/deduped/Mar.3.4.6.p1."$i"_deduped.bam \
      -M $WORK/deduped/Mar.3.4.6.p1."$i"_Complexity_Metrics.txt \
      --duplicate-tagging-policy OpticalOnly \
      --optical-duplicate-pixel-distance 50
done

#Sort output BAMs
for i in $LIST
do
     gatk SortSam \
     INPUT=$WORK/deduped/Mar.3.4.6.p1."$i"_deduped.bam \
     OUTPUT=$WORK/deduped/sorted/Mar.3.4.6.p1."$i"_sorted.bam \
     SORT_ORDER=coordinate
done