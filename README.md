# Model_Plant_RNA_Seq

# RNA-Seq: Model Plant (Arabidopsis thaliana)

This repository is a usable, publicly available tutorial for analyzing differential expression data and creating topological gene networks. All steps have been provided for the UConn CBC Xanadu cluster here with appropriate headers for the Slurm scheduler that can be modified simply to run.  Commands should never be executed on the submit nodes of any HPC machine.  If working on the Xanadu cluster, you should use sbatch scriptname after modifying the script for each stage.  Basic editing of all scripts can be performed on the server with tools such as nano, vim, or emacs.  If you are new to Linux, please use [this](https://bioinformatics.uconn.edu/unix-basics) handy guide for the operating system commands.  In this guide, you will be working with common bio Informatic file formats, such as [FASTA](https://en.wikipedia.org/wiki/FASTA_format), [FASTQ](https://en.wikipedia.org/wiki/FASTQ_format), [SAM/BAM](https://en.wikipedia.org/wiki/SAM_(file_format)), and [GFF3/GTF](https://en.wikipedia.org/wiki/General_feature_format). You can learn even more about each file format [here](https://bioinformatics.uconn.edu/resources-and-events/tutorials/file-formats-tutorial/). If you do not have a Xanadu account and are an affiliate of UConn/UCHC, please apply for one **[here](https://bioinformatics.uconn.edu/contact-us/)**.


Contents  
1.  [Introduction](#1-introduction)  
2.  [Accessing Raw Data using SRA-Toolkit](#2-accessing-the-Raw-Data-using-SRA-Toolkit)
3.  Quality Control using Sickle
4.  Aligning Reads to a Genome using HISAT2  
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


