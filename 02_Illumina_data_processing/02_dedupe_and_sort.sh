#Date : 6/27//24 
#Author : Annika Laberge
#Purpose : Mark duplicates and sort BAM outputs from mapping to reference genome. Second step in GATK pipeline's data pre-processing


#Load dependencies 
module load gatk/4.2.0.0 

#Print stack trace
gatk --java-options "-DGATK_STACKTRACE_ON_USER_EXCEPTION=true"

#Set working directory
WORK=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir

#Get list of sample IDs 
cd $WORK
LIST=`cat sampleIDs.txt`

#Dedupe and sort using MarkDuplicatesSpark
for i in $LIST
do
    gatk MarkDuplicatesSpark -I $WORK/Mar.3.4.6.p1.$i.bam \
        -O $WORK/deduped/Mar.3.4.6.p1.$i_deduped.bam \
        -M $Work/deduped/Mar.3.4.6.p1.$i_Complexity_Metrics.txt \
        --conf 'spark.executor.cores=20' \
        --duplicate-tagging-policy All \
        --optical-duplicate-pixel-distance 50
done