#!/bin/bash
#SBATCH --job-name=sickle_trim
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=10G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=first.last@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

echo `hostname`

module load sickle/1.33

sickle se -f ../raw_data/SRR3498212.fastq -t sanger -o trimmed_SRR3498212.fastq -q 35 -l 45
sickle se -f ../raw_data/SRR3498213.fastq -t sanger -o trimmed_SRR3498213.fastq -q 35 -l 45
sickle se -f ../raw_data/SRR3498215.fastq -t sanger -o trimmed_SRR3498215.fastq -q 35 -l 45
sickle se -f ../raw_data/SRR3498216.fastq -t sanger -o trimmed_SRR3498216.fastq -q 35 -l 45


