
src="home/justin/src"
cwd="/net/virus/linuxhome/justin/LK/Lserr"

nThreads=$(bash $src/nthreads.sh 0.0)

phenos="Flowering_time \
       Leaf_division \
       Juv_Anthocyanin_intensity \
       Seed_color \
       Juv_Blistering"
# Side_shoot_formation_tendency: not enough pheno values in Lserr accs (TKI 140-340)
# loose_petals: not enough pheno variation in LSerr accs (TKI 140-340)


bash $src/kmer-gwas/run-kwas.sh \
    "1 2 3" \
    $cwd/pheno/TKI-lines_phenotypes_sraid.tsv \
    $cwd \
    pheno_id="SRAID" \
    omit_ids= \
    "pheno_traits=$phenos" \
    reads_dir=$cwd/reads \
    kmers_dir=$cwd/kmers \
    heap_dir=$cwd/heaps/default \
    gwas_dir=$cwd/gwas \
    k=31 \
    nCanon=2 \
    mac=5 \
    p=0.2 \
    maf=0.05 \
    nBest=10001 \
    nThreads=$nThreads