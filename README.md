# Bash-demo
The following scripts demonstrate some work I have done in Bash during a bioinformatics-based internship. I made this on my own terms, with the intention of having a real defined analysis pipeline with a single main interface to run the whole analysis consecutively, instead of individually running the tools/programs and doing manual data-processing in between (as was expected from me).


## Structure
The main interface of this analytical pipeline is contained in `./kmer-gwas/run-kwas.sh`, and is used by the `./LSerr-run-kwas-full.sh` to run my own analysis on genetic and phenotypical data of a population of 'Lactuca Serriola'. In turn, the `run-kwas.sh` divides and runs the pipeline in three different parts using scripts in `./kmer-gwas/scripts`; sampling the kmers (segments of DNA), preparing the kmers, and associating the kmers. The rest of the scripts in the `scripts` folder were used for auxilliary purposes.

## Biological background
For those interested in the biological backgrond of this internship; we performed a kmer-based genome wide association study (GWAS) on different populations of crops, which was a relatively novel technique at that time. In this, I used and sampled genome data of about 200 different plants of 'prickly lettuce' into substrings of DNA with a defined length (k-mers) and correlated these with corresponding data of about 50 different phenotypical traits (such as leaf-color/-shape or time-to-flowering). Doing this, we were able to further validate the efficacy of the technique, and also appoint candidates of yet unknown genetic factors that influenced real-life traits of the plant.
