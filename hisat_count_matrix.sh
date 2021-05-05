#!/bin/bash
# Jane A. Pascar
# 2019-01-22
# run on the command line: nohup bash ./hisat_count_matrix.sh [.txt with accession #s] [path to refseq directory] > output.txt &

# check to make sure that both arguments are provided
if [ -z $1 ]; then
	echo "ERROR: Missing .txt file containing NCBI SRA accession numbers"
	exit 1
fi
if [ -z $2 ]; then
	echo "ERROR: Missing path to reference genome directory"
	exit 1
fi

if [ "$#" == 4 ]; then
  ACC=$1
  REF=$2
  GEN=GCF_000005575.2_AgamP3_genomic

  hisat2_extract_exons.py ${REF}/${GEN}.gtf > ${REF}/exons.txt

  hisat2_extract_splice_sites.py ${REF}/${GEN}.gtf > ${REF}ss.txt

  hisat2-build --exon ${REF}/exons.txt --ss ${REF}/ss.txt ${REF}/${GEN}.fna ${REF}/genome_tran


  while read CUR_ACC; do
	   hisat2 -x ${REF}/genome_tran -1 ~/final_project/fastq-files/${CUR_ACC}_pass_1.fastq -2 ~/final_project/fastq-files/${CUR_ACC}_pass_2.fastq -S ~/final_project/sam-files/${CUR_ACC}.sam
	   samtools view -S -b ~/final_project/sam-files/${CUR_ACC}.sam -o ~/final_project/sam-files/${CUR_ACC}.bam
  done <${ACC}
  echo "samtools complete"

  featureCounts -p -B -o ~/final_project/data/counts.txt -a ~/final_project/data/refseq/GCF_000005575.2_AgamP3_genomic_fixed.gtf ~/final_project/sam-files/*.bam
  echo "featureCounts complete"

  cat ~/final_project/data/counts.txt | cut -f 1,7- | sed 1d > ~/final_project/data/final_counts.txt
  echo "Count matrix Complete"

  exit 0
fi
