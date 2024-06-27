#Date : 6/27//24 
#Author : Annika Laberge
#Purpose : Dedupe and sort BAM outputs from mapping to reference genome. Second step in GATK pipeline's data pre-processing


#Load dependencies 
module load gatk/4.2.0.0 

#Set working directory
WORK=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir

#Get list of sample IDs 
cd $WORK
LIST=`cat sampleIDs.txt`

#Dedupe and sort using MarkDuplicatesSpark
for i in $LIST
do
    gatk MarkDuplicatesSpark -I $WORK/Mar.3.4.6.p1.$i.bam \ 
        -O $WORK/dedupe/Mar.3.4.6.p1.$i"_deduped".bam  \ 
        -M $Work/dedupe/Mar.3.4.6.p1.$i"_Complexity_Metrics".txt \
        --conf 'spark.executor.cores=50' \ 
        --duplicate-tagging-policy OpticalOnly 

        
done