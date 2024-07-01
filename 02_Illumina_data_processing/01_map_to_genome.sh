#Date : 6/27//24 
#Author : Annika Laberge
#Purpose : Map raw sequencing data to the reference genome. First data pre-processing step of GATK's germline SNP/Indel discovery pipeline.
#Note: BAM output from this ~must~ have read group in the header for MarkDuplicatesSpark (next step) to work. 

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

#Get RG ID's to add into header during bwa mem call
for i in $LIST
do
	header=$(zcat $ILLUMINA/$i"_R1_001.fastq.gz" | head -n 1)
	id=$(echo $header | head -n 1 | cut -f 1-4 -d":" | sed 's/@//' | sed 's/:/_/g')
	echo "Read Group @RG\tID:$id\tSM:$id"_"$i\tLB:$id"_"$i\tPL:ILLUMINA"
done

#Navigate to the correct directory
cd $WORK/RG_Added

#Loop through data and map/sort
for i in $LIST
do
	header=$(zcat $ILLUMINA/$i"_R1_001.fastq.gz" | head -n 1)
	id=$(echo $header | head -n 1 | cut -f 3-4 -d":" | sed 's/@//' | sed 's/:/_/g')
	bwa mem -t 50 -R "@RG\tID:$id\tSM:$i\tLB:$i"_"1\tPL:ILLUMINA" $GENOME $ILLUMINA/$i"_R1_001.fastq.gz" $ILLUMINA/$i"_R2_001.fastq.gz" | samtools view -b -h -@ 10 | samtools sort -O bam -@ 10 > Mar.3.4.6.p1.$i.bam
done

#Index data 
for i in $LIST
do
	samtools index -b -@ 20 Mar.3.4.6.p1.$i.bam
done





