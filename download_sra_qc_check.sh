#!/bin/bash
# Jane A. Pascar
# 2019-01-22
# run on the command line: nohup bash ./download_sra_qc_check.sh [.txt with accession #s] [path to fastq directory] [path to refseq directory] [path to qc directory] > output.txt &

# check to make sure that both arguments are provided
if [ -z $1 ]; then
	echo "ERROR: Missing .txt file containing NCBI SRA accession numbers"
	exit 1
fi
if [ -z $2 ]; then
	echo "ERROR: Missing path to output directory for sample fastq files"
	exit 1
fi
if [ -z $3 ]; then
	echo "ERROR: Missing path to output directory for reference genome and annotation files"
	exit 1
fi
if [ -z $4 ]; then
        echo "ERROR: Missing path to output directory for fastqc reports"
        exit 1
fi

# This runs if all arguments are supplied:
if [ "$#" == 4 ]; then
	ACC=$1
	DIR=$2
	REF=$3
	QCDIR=$4

	# download the SRA files associated with the accession you provide
	while read CUR_ACC; do
		echo "*** BEGINNING TO DOWNLOAD ${CUR_ACC} ***"
    fastq-dump --readids --outdir ${DIR} --skip-technical --readids --read-filter pass --dumpbase --split-3 --clip ${CUR_ACC}
    echo "*** ${CUR_ACC} DOWNLOAD COMPLETE ***"
	done <${ACC}

	echo "*** DOWNLOADING SRA FILES COMPLETE ***"

	# download the An. gambiae reference genome and annotation files
	cd ${REF}
	wget https://ftp.ncbi.nlm.nih.gov/genomes/refseq/invertebrate/Anopheles_gambiae/latest_assembly_versions/GCF_000005575.2_AgamP3/GCF_000005575.2_AgamP3_genomic.fna.gz
	wget https://ftp.ncbi.nlm.nih.gov/genomes/refseq/invertebrate/Anopheles_gambiae/latest_assembly_versions/GCF_000005575.2_AgamP3/GCF_000005575.2_AgamP3_genomic.gff.gz
	wget https://ftp.ncbi.nlm.nih.gov/genomes/refseq/invertebrate/Anopheles_gambiae/latest_assembly_versions/GCF_000005575.2_AgamP3/GCF_000005575.2_AgamP3_genomic.gtf.gz
	gunzip *

	echo "*** DOWNLOADING REFERENCE GENOME FILES COMPLETE ***"

	# Pre-trimming quality report
	while read CUR_ACC; do
  	fastqc -q ${DIR}/${CUR_ACC}_pass.fastq ${DIR}/${CUR_ACC}_pass_1.fastq ${DIR}/${CUR_ACC}_pass_2.fastq -o ${QCDIR}
	done <${ACC}
	echo -e "*** PRE-TRIMMING QC REPORTS COMPLETE ***"

	# combine reports using MultiQC
	multiqc -n PRJNA704422_multiqc-report -o ${QCDIR} ${QCDIR}
	echo "*** FASTQC FILES COMBINED ***"

	exit 0
fi
