#!/bin/bash
#SBATCH --job-name=hisat2_align
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --mem=50G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=first.last@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

echo `hostname`

module load hisat2/2.1.0

index_path="/isg/shared/databases/alignerIndex/plant/Arabidopsis/thaliana/Athaliana_HISAT2/thaliana"

hisat2 -p 16 --dta ${index_path} -q ../sickle/trimmed_SRR3498212.fastq -S athaliana_root_1.sam
hisat2 -p 16 --dta ${index_path} -q ../sickle/trimmed_SRR3498213.fastq -S athaliana_root_2.sam
hisat2 -p 16 --dta ${index_path} -q ../sickle/trimmed_SRR3498215.fastq -S athaliana_shoot_1.sam
hisat2 -p 16 --dta ${index_path} -q ../sickle/trimmed_SRR3498216.fastq -S athaliana_shoot_2.sam


