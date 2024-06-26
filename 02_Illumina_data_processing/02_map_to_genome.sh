######## Mapping trim20 reads to genome ################

#Load dependencies 
module load bwa/0.7.17  
module load samtools/1.9 

#set working directory
WORK=/fs02/Metzger/Analysis_Active/Mar_longDNA/workingDir

#ref genome
GENOME=/fs02/Metzger/Analysis_Active/Mar_longDNA/refs/Mar.3.4.6.p1_Q30Q30A.fasta
GENOMEDIR=/fs02/Metzger/Analysis_Active/Mar_longDNA/refs

#Get list of sample IDs - need to 
cd $WORK
LIST=`cat sampleIDs.txt`


ILLUMINA=/fs02/Metzger/Analysis_Active/Mar_longDNA/Illumina_data/Mar_longDNA_2024


#single line bwa index 
cd $GENOMEDIR
bwa index -a bwtsw $GENOME 

cd $WORK

for i in $LIST
do
	bwa mem -t 50 $GENOME $ILLUMINA/$i"_R1_001.fastq.gz" $ILLUMINA/$i"_R2_001.fastq.gz" | samtools view -b -h -@ 10 | samtools sort -O bam -@ 10 > Mar.3.4.6.p1.$i.bam
done

for i in $LIST
do
	samtools index -b -@ 20 Mar.3.4.6.p1.$i.bam
done





