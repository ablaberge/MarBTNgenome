#Date : 6/27//24 
#Author : Annika Laberge
#Purpose : Map raw sequencing data to the reference genome. First data pre-processing step of GATK's germline SNP/Indel discovery pipeline.

#bla bla blah

#Load dependencies 
module load bwa/0.7.17  
module load samtools/1.9 

#set working directory
WORK=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir

#Set ref genome and directory
GENOME=/fs02/Metzger/Analysis_Active/Mar_longDNA/refs/Mar.3.4.6.p1_Q30Q30A.fasta
GENOMEDIR=/fs02/Metzger/Analysis_Active/Mar_longDNA/refs

#Get list of sample IDs - need to cat so they're readable by bwa
cd $WORK
LIST=`cat sampleIDs.txt`

#Set directory with raw Illumina data 
ILLUMINA=/fs02/Metzger/Analysis_Active/Mar_longDNA/Illumina_data/Mar_longDNA_2024


#Single line bwa index 
cd $GENOMEDIR
bwa index -a bwtsw $GENOME 

#Navigate to the correct directory
cd $WORK

#Loop through data and map/sort
for i in $LIST
do
	bwa mem -t 50 $GENOME $ILLUMINA/$i"_R1_001.fastq.gz" $ILLUMINA/$i"_R2_001.fastq.gz" | samtools view -b -h -@ 10 | samtools sort -O bam -@ 10 > Mar.3.4.6.p1.$i.bam
done

#Index data 
for i in $LIST
do
	samtools index -b -@ 20 Mar.3.4.6.p1.$i.bam
done





