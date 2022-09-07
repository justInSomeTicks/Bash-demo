

if [ ! $0 == 'run-kwas.sh' ]; then
    echo "Error: program may not be sourced"
    exit 1
else
    ROOT_DIR=$(dirname $(realpath $0))
    source $ROOT_DIR/scripts/helpers.sh; 
fi


# Init constants
KMC_BIN="$ROOT_DIR/external_programs/kmc_v3"
GEMMA_BIN="$ROOT_DIR/external_programs/gemma_0_98_1"


# Init vars
steps=$1
pheno_file=$2
out_dir=$3


pheno_id="SRAID"
pheno_traits="Flowering_time \
              Leaf_division \
              Juv_Anthocyanin_intensity \
              Seed_color \
              Juv_Blistering"

reads_dir="$out_dir/reads"
kmers_dir="$out_dir/kmers"
heap_dir="$out_dir/heap"
gwas_dir="$out_dir/gwas"

k=31
nCanon=2
nThreads=20
mac=5
p=0.2
maf=0.05
nBest=10001
omit_ids=

params-as-vars ${@:5}   # set argv params as variables by format '<var>=<val>'


# Init dirs
mkdir -p $out_dir
mkdir -p $kmers_dir
mkdir -p $heap_dir
mkdir -p $gwas_dir


## STEP 1: generate (canonised/non-canonised) kmers from sample reads
if [ ! $(isin-lst 1 $steps) == -1 ]; then
    source $ROOT_DIR/scripts/sample-kmers.sh
fi

## STEP 2: collect and filter best kmers from individual samples, and from it create a heap, table and kinship matrix
if [ ! $(isin-lst 2 $steps) == -1 ]; then
    source $ROOT_DIR/scripts/prep-kmers.sh
fi

## STEP 3: perform kmer-based GWAS (GRAMMAR gamma score; mod. chi-squared test of relation between genotype to (co-variated) phenotype)
if [ ! $(isin-lst 3 $steps) == -1 ]; then
    source $ROOT_DIR/scripts/assoc-kmers.sh
fi











