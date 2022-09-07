
ROOT_DIR=${ROOT_DIR:-$(find-up "kmer-gwas")}

# source helpers if main entry-point
if [ $0 == "sample-kmers.sh" ]; then 
	ROOT_DIR=$(dirname $(dirname $(realpath $0)))
	source $ROOT_DIR/scripts/helpers.sh
fi



# Init globals
KMC_BIN=${KMC_BIN:-"$ROOT_DIR/external_programs/kmc_v3"}

pheno_file=${pheno_file:-$1}
reads_dir=${reads_dir:-$2}
out_dir=${out_dir:-$3}

if [[ ! -f $pheno_file == '' ]]
    echo "Required param \$1 'pheno_file' does not exist"
    exit 1
else if [[ ! -d $reads_dir ]]; then
    echo "Required param \$2 'reads_dir' does not exist"
    exit 1
else if [[ ! -d $out_dir == '' ]]
    echo "Required param \$3 'out_dir' does not exist"
    exit 1
fi

kmers_dir=${kmers_dir:-"$out_dir/kmers"}
pheno_id=${pheno_id:-''}
omit_ids=${omit_ids:-''}

k=${k:-31}
nCanon=${nCanon:-2}
nThreads=${nThreads:-20}

params-as-vars ${@:4}


mkdir -p $kmers_dir
mdkir -p $kmers_dir/samples
mkdir -p $kmers_dir/logs



if [[ $pheno_id == '' ]]; then
	id_lst=$(cut -f 1 < $pheno_file)
else
	id_lst=$(bash $ROOT_DIR/scripts/cut-tsv.sh $pheno_file $pheno_id)
fi

echo "$id_lst" | cut -d ' ' -f 1 > $kmers_dir/logs/omitted.tsv
id_lst=$(echo "$id_lst" | cut -d ' ' -f 2-)


# STEP 1. Sample kmers
## Create collection of true kmers per sample including their form (canon/non-canon/both) 
sample_index=1
for sample_id in $id_lst; do

		sample_reads_lst=$(find -L $reads_dir -name "$sample_id*.fastq*") 

		if [[ $(isin-lst $sample_id "$omit_ids") -eq 0 ]] || [[ "$sample_reads_lst" == '' ]]; then
			echo "Omitting sample #$sample_index : $sample_id"
			echo $sample_id >> $kmers_dir/logs/omitted.tsv
		else
		
			echo "Working on sample #$sample_index : $sample_id "

			sample_kmerdir="$kmers_dir/samples/$sample_id"
			sample_logdir="$kmers_dir/logs/$sample_id"
			mkdir -p $sample_kmerdir
			mkdir -p $sample_logdir

			fastq_lst_file="$sample_logdir/fastq_files.txt"
			if [[ ! -f $fastq_lst_file ]]; then
				echo "$sample_reads_lst" | awk '{print \$NF}' > $fastq_lst_file
			fi


			has_cns=$(find $sample_kmerdir -name kmers_cns*)
			has_ncns=$(find $sample_kmerdir -name kmers_ncns*)
			has_stranded=$(find $sample_kmerdir -name kmers_stranded)

			if [[ "$has_stranded" == '' ]]; then

				if [[ "$has_cns" == '' ]]; then
					echo-cmd tee-out $sample_logdir/kmers_cns.log \
						"$KMC_BIN \
							-t$nThreads \
							-k$k \
							-ci$nCanon \
							@$fastq_lst_file \
							$sample_kmerdir/kmers_cns \
							$sample_kmerdir"
				fi

				if [[ "$has_ncns" == '' ]]; then
					echo-cmd tee-out $sample_logdir/kmers_ncns.log \
						"$KMC_BIN \
							-t$nThreads \
							-k$k \
							-ci0 \
							-b \
							@$fastq_lst_file \
							$sample_kmerdir/kmers_ncns \
							$sample_kmerdir"
				fi

        		echo-cmd tee-out $sample_logdir/kmers_stranded.log \
					"$ROOT_DIR/bin/kmers_add_strand_information \
						-c $sample_kmerdir/kmers_cns \
						-n $sample_kmerdir/kmers_ncns \
						-k $k \
						-o $sample_kmerdir/kmers_stranded"

			fi


			if [[ ! "$has_stranded" == '' ]]; then
				if [[ ! "$has_cns" ==  '' ]]; then echo-cmd rm -rf $sample_kmerdir/kmers_cns*; fi
				if [[ ! "$has_ncns" == '' ]]; then echo-cmd rm -rf $sample_kmerdir/kmers_ncns*; fi
			fi

		fi

	((sample_index++))
done
