
ROOT_DIR=${ROOT_DIR:-$(find-up "kmer-gwas")}

# source helpers if main entry-point
if [ $0 == "assoc-kmers.sh" ]; then
	ROOT_DIR=$(dirname $(dirname $(realpath $0)))
	source $ROOT_DIR/scripts/helpers.sh
fi



# init globals
GEMMA_BIN=${GEMMA_BIN:-"$ROOT_DIR/external_programs/gemma_0_98_1"}

pheno_file=${pheno_file:-$1}
heap_dir=${heap_dir:-$2}
out_dir=${out_dir:-$3}
pheno_traits=${pheno_traits:-$4}

if [[ ! -f $pheno_file ]]; then
    echo "Required param \$1 'pheno_file' does not exist"
    exit 1
else if [[ ! -d $heap_dir ]]; then
    echo "Required param \$2 'heap_dir' does not exist"
    exit 1
else if [[ ! -d $out_dir == '' ]]; then
    echo "Required param \$3 'out_dir' does not exist"
    exit 1
else if [[ $pheno_traits == '' ]]; then
    echo "Required param \$4 'pheno_traits' not supplied"
    exit 1
fi

gwas_dir=${gwas_dir:-"$out_dir/gwas"}
pheno_id=${pheno_id:-''}

k=${k:-31}
nBest=${nBest:-10001}
nThreads=${nThreads:-20}

params-as-vars ${@:5}


mkdir -p $gwas_dir


# STEP 3.
## run kmer (based) GWAS
for pheno_trait in $pheno_traits; do

	trait_dir="$gwas_dir/$pheno_trait"
	trait_pheno_file="$trait_dir/phenotypes.tsv"

	mkdir -p $trait_dir
	mkdir -p $trait_dir/results
	mkdir -p $trait_dir/logs

	if [[ $pheno_id == '' ]]; then pheno_id=$(head -n 1 | cut -f 1 < $pheno_file); fi
	bash $ROOT_DIR/scripts/cut-tsv.sh $pheno_file $pheno_id $pheno_trait | tail -n +2 > $trait_pheno_file
	

	echo-cmd tee-out $trait_dir/logs/gwas.log \
		"python2.7 $ROOT_DIR/kmers_gwas.py \
			--pheno $trait_pheno_file \
			--kmers_table $heap_dir/kmer_table \
			--gemma_path $GEMMA_BIN \
			-l $k \
			-p $nThreads \
			-k $nBest \
			--outdir $trait_dir/results"

done