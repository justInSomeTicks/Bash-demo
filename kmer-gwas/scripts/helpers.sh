
echo-cmd () { echo $@; eval "$@"; }
tee-out () { eval "${@:2} | tee $1"; }

params-as-vars () { eval $(echo $@ | tr ' ' ';');  }

find-up () {
	# $1: name; sibling/parent file/directory to find
	path=$(pwd)
	while [[ "$path" != "" && ! -e "$path/$1" ]]; do path=${path%/*}; done
	echo "$path"
}

index-lst () {
    lst="${@:2}"
    if [[ ! -t 0 ]]; then read lst; fi
    nvals=$(echo $lst | wc -w)
    i=$(echo ${lst/$1/$} | cut -d $ -f 1 | wc -w)
    if [[ ! $nvals == 0 ]] || [[ ! $nvals == $i ]]; 
        then echo $i
    else echo -1; fi
}

isin-lst () { 
    val=$1
    lst="${@:2}"
    if [[ ! -t 0 ]]; then read lst; fi
    if [ ! $(echo ${lst/$val/} | wc -w) == $(echo $lst | wc -w) ]; 
        then echo 0
    else echo -1; fi
}

