
ROOT_DIR=${ROOT_DIR:-$(find-up "kmer-gwas")}

# source helpers if main entry-point
if [ $0 == "prep-kmers.sh" ]; then 
	ROOT_DIR=$(dirname $(dirname $(realpath $0)))
	source $ROOT_DIR/scripts/helpers.sh
fi



# init globals

pheno_file=${pheno_file:-$1}
kmers_dir=${kmers_dir:-$2}
out_dir=${out_dir:-$3}

else if [[ ! -f $pheno_file ]]; then
    echo "Required param \$1 'pheno_file' does not exist"
    exit 1
else if [[ ! -d $kmers_dir ]]; then
    echo "Required param \$2 'kmers_dir' does not exist"
    exit 1
else if [[ ! -d $out_dir ]]; then
    echo "Required param \$3 'out_dir' does not exist"
    exit 1
fi

heap_dir=${heap_dir:-"$out_dir/heap"}
pheno_id=${pheno_id:-''}

k=${k:-31}
mac=${mac:-5}
p=${p:-0.2}
maf=${maf:-0.05}

params-as-vars ${@:4}


kmer_heap="$heap_dir/kmer_heap"
kmer_table="$heap_dir/kmer_table"
kmer_kinship="$heap_dir/kmer_kinship"
kmer_lst_file="$heap_dir/logs/kmer_files.txt"

mkdir -p $heap_dir
mkdir -p $heap_dir/logs



if [[ $pheno_id == '' ]]; then
	id_lst=$(cut -f 1 | tail -n +2 < $pheno_file)
else
	id_lst=$(bash $ROOT_DIR/scripts/cut-tsv.sh $pheno_file $pheno_id | tail -n +2)
fi

echo "$id_lst" | cut -d ' ' -f 1 > $heap_dir/logs/omitted.tsv
id_lst=$(echo "$id_lst" | cut -d ' ' -f 2-)


# STEP 2. Prepare kmers 
# collect and filter kmers from different samples to one heap and from it create kmer table and kinship matrix
sample_index=1
for sample_id in $id_lst; do
	sample_kmers_file="$kmers_dir/samples/$sample_id/kmers_stranded"
	if [[ ! -f $sample_kmers_file ]]; then 
		echo "Omitting sample #$sample_index : $sample_id"
		echo $sample_id >> $heap_dir/logs/omitted.tsv
	else
		echo "$sample_kmers_file $sample_id" | tr ' ' '\t' >> $kmer_lst_file
	fi
	((sample_index++))
done

echo-cmd \
	"$ROOT_DIR/bin/list_kmers_found_in_multiple_samples \
		-l $kmer_lst_file \
		-k $k \
		--mac $mac \
		-p $p \
		-o $kmer_heap"

echo-cmd \
	"$ROOT_DIR/bin/build_kmers_table \
		-l $kmer_lst_file \
		-k $k \
		-a $kmer_heap
		-o $kmer_table"

echo-cmd \
	"$ROOT_DIR/bin/emma_kinship_kmers \
		-t $kmer_table 
		-k $k 
		--maf $maf \
	> $kmer_kinship"