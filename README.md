# Model_Plant_RNA_Seq

# RNA-Seq: Model Plant (Arabidopsis thaliana)

This repository is a usable, publicly available tutorial for analyzing differential expression data and creating topological gene networks. All steps have been provided for the UConn CBC Xanadu cluster here with appropriate headers for the Slurm scheduler that can be modified simply to run.  Commands should never be executed on the submit nodes of any HPC machine.  If working on the Xanadu cluster, you should use sbatch scriptname after modifying the script for each stage.  Basic editing of all scripts can be performed on the server with tools such as nano, vim, or emacs.  If you are new to Linux, please use [this](https://bioinformatics.uconn.edu/unix-basics) handy guide for the operating system commands.  In this guide, you will be working with common bio Informatic file formats, such as [FASTA](https://en.wikipedia.org/wiki/FASTA_format), [FASTQ](https://en.wikipedia.org/wiki/FASTQ_format), [SAM/BAM](https://en.wikipedia.org/wiki/SAM_(file_format)), and [GFF3/GTF](https://en.wikipedia.org/wiki/General_feature_format). You can learn even more about each file format [here](https://bioinformatics.uconn.edu/resources-and-events/tutorials/file-formats-tutorial/). If you do not have a Xanadu account and are an affiliate of UConn/UCHC, please apply for one **[here](https://bioinformatics.uconn.edu/contact-us/)**.


Contents  
1.  [Introduction](#1-introduction)  
2.  [Accessing Raw Data using SRA-Toolkit](#2-accessing-the-Raw-Data-using-SRA-Toolkit)
3.  Quality Control using Sickle
4.  [Aligning Reads to a Genome using HISAT2](#4-Aligning-Reads-to-a-Genome-using-HISAT2)  
5.  Transcript Assembly and Quantification with StringTie  
6.  Differential Expression using Ballgown
7.  Topological networking using Cytoscape
8.  Conclusion   


## 1. Introdcution  

In this tutorial, we will be analyzing thale cress (Arabidopsis thaliana) RNA-Seq data from various parts of the plant (roots, stems). Perhaps one of the most common organisms for genetic study, the aggregrate wealth of genetic  Information of the thale cress makes it ideal for new-comers to learn. Organisms such as this we call "model organisms". You may think of model organisms as a subset of living things which, under the normal conventions of analysis, behave nicely. The data we will be analyzing comes from an experiment in which various cellular RNA was collected from the roots and shoots of a single thale cress. The RNA profiles are archived in the SRA, and meta Information on each may be viewed through the SRA ID: [SRR3498212](https://www.ncbi.nlm.nih.gov/sra?term=SRX1756762), [SRR3498213](https://www.ncbi.nlm.nih.gov/sra/?term=SRR3498213), [SRR3498215](https://www.ncbi.nlm.nih.gov/sra?term=SRX1756765), [SRR3498216](https://www.ncbi.nlm.nih.gov/sra?term=SRX1756766).  


The Single Read Archive, or SRA, is a publicly available database containing read sequences from a variety of experiments. Scientists who would like their read sequences present on the SRA submit a report containing the read sequences, experimental details, and any other accessory meta-data. 

Our data, SRR3498212, SRR3498213, SRR3498215, SRR3498216 come from root 1, root 2, shoot 1, and shoot 2 of a single thale cress, respectively. Our objective in this analysis is to determine which genes are expressed in all samples, quantify the expression of each common gene in each sample, identify genes which are lowly expressed in roots 1 and 2 but highly expressed in shoots 1 and 2, or vice versa, quantify the relative expression of such genes, and lastly to create a visual topological network of genes with similar expression profiles.

The workflow may be cloned into the appropriate directory using your terminal window.  
```bash
git clone < name of the git repository >
```

This will clone the directory structure as shown below, and you may be albe to follow the rest of the steps in appropiate folders.  
```
└── Model_Plant_RNA_Seq
    ├── LICENSE
    └── README.md  
```  
 

In this tutorial we will be using SLURM schedular to submit jobs to Xanadu cluster. In each script we will be using it will contain a header section which will allocate the resources for the SLURM schedular. The header section will contain:  

```bash
#!/bin/bash
#SBATCH --job-name=JOBNAME
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=first.last@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

```  

Before beginning, we need to understand a few aspects of the Xanadu server. When first logging into Xanadu from your local terminal, you will be connected to the submit node. The submit node is the interface with which users on Xanadu may submit their processes to the desired compute nodes, which will run the process. Never, under any circumstance, run processes directly in the submit node. Your process will be killed and all of your work lost! This tutorial will not teach you shell script configuration to submit your tasks on Xanadu. Therefore, before moving on, read and master the topics covered in the [Xanadu tutorial](https://bioinformatics.uconn.edu/resources-and-events/tutorials-2/xanadu/).  


## 2. Accessing the Raw Data using SRA Toolkit  

We know that the SRA contain the read sequences and accessory meta Information from experiments. Rather than downloading experimental data through a browser, we may use the [sratoolkit's](https://www.ncbi.nlm.nih.gov/books/NBK158900/) "fastq-dump" function to directly dump raw read data into the current terminal directory. Let's have a look at this function (it is expected that you have read the Xanadu tutorial, and are familiar with loading modules):  

For our needs, we will simply be using the accession numbers to dump our experimental data into our directory. We know our accession numbers, so let's write a shell script to retrieve our raw reads. There are a variety of text editors available on Xanadu. Use your prefered text editor to write the script as follows:  

```bash
module load sratoolkit/2.8.2

fastq-dump SRR3498212
fastq-dump SRR3498213
fastq-dump SRR3498215
fastq-dump SRR3498216
```  

The full script for slurm shedular can be found in the **raw_data** folder by the name [sra_download.sh](/raw_data/sra_download.sh).  

Now lets look at the first 4 lines in the downloaded *SRR3498212.fastq* file.  
```bash
head -n 4 SRR3498212.fastq 
```

which will give us the information on the first read in the file:
```
@SRR3498212.1 SN638:767:HC555BCXX:1:1108:2396:1996 length=50
NTCAATCGGTCAGAGCACCGCCCTGTCAAGGCGGAAGCAGATCGGAAGAG
+SRR3498212.1 SN638:767:HC555BCXX:1:1108:2396:1996 length=50
#<DDDIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
``` 
 
In here we see that first line corrosponds to the sample information followed by the length of the read, and in the second line corrosponds to the nucleotide reads, followed by the "+" sign where if repeats the information in the first line. Then the fourth line corrosponds to the quality score for each nucleotide in the first line.  


## 2. Quality Control using Sickle  

Sickle performs quality control on illumina paired-end and single-end short read data using a sliding window. As the window slides along the fastq file, the average score of all the reads contained in the window is calculated. Should the average window score fall beneath a set threshold, [sickle](https://github.com/najoshi/sickle/blob/master/README.md) determines the reads responsible and removes them from the run. After visiting the SRA pages for our data, we see that our data are single end reads. Let's find out what sickle can do with these:  
```bash 
module load sickle/1.33

sickle se -f ../raw_data/SRR3498212.fastq -t sanger -o trimmed_SRR3498212.fastq -q 35 -l 45
sickle se -f ../raw_data/SRR3498213.fastq -t sanger -o trimmed_SRR3498213.fastq -q 35 -l 45
sickle se -f ../raw_data/SRR3498215.fastq -t sanger -o trimmed_SRR3498215.fastq -q 35 -l 45
sickle se -f ../raw_data/SRR3498216.fastq -t sanger -o trimmed_SRR3498216.fastq -q 35 -l 45
```   

 
To see the options in the sickle just type `sickle` after loading the module which will give:  
```bash
Usage: sickle <command> [options]

Command:
pe	paired-end sequence trimming
se	single-end sequence trimming
```  

Since we have single-end reads, lets look the options:
```bash
Usage: sickle se [options] -f <fastq sequence file> -t <quality type> -o <trimmed fastq file>

Options:
-f, --fastq-file, Input fastq file (required)
-t, --qual-type, Type of quality values: (required)
	solexa (CASAVA < 1.3)
	illumina (CASAVA 1.3 to 1.7)
	sanger (which is CASAVA >= 1.8)
-o, --output-file, Output trimmed fastq file (required)
-q, --qual-threshold, Threshold for trimming based on average quality in a window. Default 20. 
-l, --length-threshold, Threshold to keep a read based on length after trimming. Default 20 
```  

The quality may be any score from 0 to 40. The default of 20 is much too low for a robust analysis. We want to select only reads with a quality of 35 or better. Additionally, the desired length of each read is 50bp. Again, we see that a default of 20 is much too low for analysis confidence. We want to select only reads whose lengths exceed 45bp. Lastly, we must know the scoring type. While the quality type is not listed on the SRA pages, most SRA reads use the "sanger" quality type. Unless explicitly stated, try running sickle using the sanger qualities. If an error is returned, try illumina. If another error is returned, lastly try solexa. 

The full script for slurm shedular can be found in the **sickle** folder by the name [sickle_trim.sh](/sickle/sickle_trim.sh).  


## 4. Aligning Reads to a Genome using HISAT2  

HISAT2 is a fast and sensitive aligner for mapping next generation sequencing reads against a reference genome. HISAT2 requires two arguments: the reads file being mapped and the indexed genome to which those reads are mapped. Typically, the hisat2-build command is used to make a HISAT index file for the genome. It will create a set of files with the suffix .ht2, these files together build the index. What is an index and why is it helpful? Genome indexing is the same as indexing a tome, like an encyclopedia. It is much easier to locate Information in the vastness of an encyclopedia when you consult the index, which is ordered in an easily navigatable way with pointers to the location of the Information you seek within the encylopedia. Genome indexing is thus the structuring of a genome such that it is ordered in an easily navigatable way with pointers to where we can find whichever gene is being aligned. Let's have a look at how the hisat2-build command works:  

To build the HISAT2 index, simply use:
```bash
module load hisat2/2.1.0
hisat2-build -p 4 ${FASTA_File} ${BASE_NAME}
```  

So the HISAT2 program options are:
```
Usage: hisat2-build [options]* <reference_in> <ht2_index_base>

    reference_in            comma-separated list of files with ref sequences
    hisat2_index_base       write ht2 data to files with this dir/basename

Options:
    -p                      number of threads
```  

As you can see, we simply enter our reference genome files and the desired prefix for our .ht2 files. Now, fortunately for us, Xanadu has many indexed genomes which we may use. To see if there is a hisat2 Arabidopsis thaliana indexed genome we need to look at the Xanadu databases page. We see that our desired indexed genome is in the location `/isg/shared/databases/alignerIndex/plant/Arabidopsis/thaliana/Athaliana_HISAT2/`. Now we are ready to align our reads using hisat2 (for hisat2, the script is going to be written first with an explanation of the options after).  


```bash
module load hisat2/2.1.0

index_path="/isg/shared/databases/alignerIndex/plant/Arabidopsis/thaliana/Athaliana_HISAT2/thaliana"

hisat2 -p 16 --dta ${index_path} -q ../sickle/trimmed_SRR3498212.fastq -S athaliana_root_1.sam
hisat2 -p 16 --dta ${index_path} -q ../sickle/trimmed_SRR3498213.fastq -S athaliana_root_2.sam
hisat2 -p 16 --dta ${index_path} -q ../sickle/trimmed_SRR3498215.fastq -S athaliana_shoot_1.sam
hisat2 -p 16 --dta ${index_path} -q ../sickle/trimmed_SRR3498216.fastq -S athaliana_shoot_2.sam
```  

The full script for slurm shedular can be found in the **hisat2_align** folder called [hisat2_align.sh](/hisat2_align/hisat2_align.sh).  

The command options used:
```
Usage: hisat2 [options] <ht2-idx> <unpaired-reads> [-S <sam>] 

Options:
 Input:
  -q                 query input files are FASTQ .fq/.fastq (default)

 Spliced Alignment:
  --dta              reports alignments tailored for transcript assemblers

 Output:
  -S                 SAM out file (default: stdout)

 Performance:
  -p/--threads <int> number of alignment threads to launch  

```  

Once the mapping is completed, the file structure is as follows:
```
hisat2_align/
├── athaliana_root_1.sam
├── athaliana_root_2.sam
├── athaliana_shoot_1.sam
├── athaliana_shoot_2.sam
└── hisat2_align.sh
```  

When HISAT2 completes its run, it will summarize each of it’s alignments, and it is written to the standard error file, which can be found in the same folder once the run is completed. Also if you want, you can direct each summary to a new file using `--summary-file` option.  

So the alignment summary:  
| No of Reads |  Unpaired  |  Unalign  |  Align(1)  | Align(>1) |  alignment rate  |   
| ----------- | ---------- | --------- | ---------- | --------- | ---------------- |  
|  34475799   |  34475799  | 33017550  | 1065637    | 392612    |   4.23%          |  




dfdf

| Command |  Description |  
| --- | --- |  
| git status  | List all new or monified files |  
| git diff  | Show file differences that havent been staged  |  

Alignment summary:  
| No of Reads | Unalign | Align(=1) | Align(>1) | Alignment Rate |  
| --- | ---| ---| ---| --- |  
| 34475799 | 33017550 | 1065637  | 392612  | 4.23%  |   


