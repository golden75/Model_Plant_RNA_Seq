# Model_Plant_RNA_Seq

# RNA-Seq: Model Plant (Arabidopsis thaliana)

This repository is a usable, publicly available tutorial for analyzing differential expression data and creating topological gene networks. All steps have been provided for the UConn CBC Xanadu cluster here with appropriate headers for the Slurm scheduler that can be modified simply to run.  Commands should never be executed on the submit nodes of any HPC machine.  If working on the Xanadu cluster, you should use sbatch scriptname after modifying the script for each stage.  Basic editing of all scripts can be performed on the server with tools such as nano, vim, or emacs.  If you are new to Linux, please use [this](https://bioinformatics.uconn.edu/unix-basics) handy guide for the operating system commands.  In this guide, you will be working with common bio Informatic file formats, such as [FASTA](https://en.wikipedia.org/wiki/FASTA_format), [FASTQ](https://en.wikipedia.org/wiki/FASTQ_format), [SAM/BAM](https://en.wikipedia.org/wiki/SAM_(file_format)), and [GFF3/GTF](https://en.wikipedia.org/wiki/General_feature_format). You can learn even more about each file format [here](https://bioinformatics.uconn.edu/resources-and-events/tutorials/file-formats-tutorial/). If you do not have a Xanadu account and are an affiliate of UConn/UCHC, please apply for one **[here](https://bioinformatics.uconn.edu/contact-us/)**.


Contents  
1.  [Introduction](#1-introduction)  
2.  Accessing Raw Data using SRA-Toolkit
3.  Quality Control using Sickle
4.  Aligning Reads to a Genome using HISAT2  
5.  Transcript Assembly and Quantification with StrigTie  
6.  Differential Expression using Ballgown
7.  Topological networking using Cytoscape
8.  Conclusion   


## 1. Introdcution  

In this tutorial, we will be analyzing thale cress (Arabidopsis thaliana) RNA-Seq data from various parts of the plant (roots, stems). Perhaps one of the most common organisms for genetic study, the aggregrate wealth of genetic  Information of the thale cress makes it ideal for new-comers to learn. Organisms such as this we call "model organisms". You may think of model organisms as a subset of living things which, under the normal conventions of analysis, behave nicely. The data we will be analyzing comes from an experiment in which various cellular RNA was collected from the roots and shoots of a single thale cress. The RNA profiles are archived in the SRA, and meta Information on each may be viewed through the SRA ID: [SRR3498212](https://www.ncbi.nlm.nih.gov/sra?term=SRX1756762), [SRR3498213](https://www.ncbi.nlm.nih.gov/sra/?term=SRR3498213), [SRR3498215](https://www.ncbi.nlm.nih.gov/sra?term=SRX1756765), [SRR3498216](https://www.ncbi.nlm.nih.gov/sra?term=SRX1756766).  


 
