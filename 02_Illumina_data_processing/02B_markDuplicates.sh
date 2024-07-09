#!/bin/bash

#Date : 7/8/24 
#Author : Annika Laberge
#Purpose : Mark duplicates and sort BAM outputs from mapping to reference genome. Second step in GATK pipeline's data pre-processing.
        # An alternative option to using MarkDuplicatesSpark.


#Load dependencies 
module load gatk/4.2.0.0
module load samtools/1.9  

#Set working directory
WORK=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir

#Get list of sample IDs 
cd $WORK || exit
LIST=$(cat sampleIDs.txt)

#Dedupe and sort using MarkDuplicatesSpark
#The "&" makes the loop run in parallel and the "wait" makes all processes complete before it moves on
for i in $LIST
do
gatk --java-options "-Xmx10g -XX:ConcGCThreads=1" MarkDuplicates \
      -I $WORK/RG_Added/Mar.3.4.6.p1."$i".bam \
      -O /ssd3/workingDir/deduped/Mar.3.4.6.p1."$i"_deduped.bam \
      -M /ssd3/workingDir/deduped/Mar.3.4.6.p1."$i"_Complexity_Metrics.txt \
      --TAGGING_POLICY OpticalOnly \
      --OPTICAL_DUPLICATE_PIXEL_DISTANCE 50 \
      &
done
wait


#Sort output BAMs
for i in $LIST
do
samtools sort \
     INPUT=/ssd3/workingDir/deduped/Mar.3.4.6.p1."$i"_deduped.bam \
     OUTPUT=/ssd3/workingDir/deduped/Mar.3.4.6.p1."$i"_sorted.bam \
     SORT_ORDER=coordinate \
     &
done
wait
