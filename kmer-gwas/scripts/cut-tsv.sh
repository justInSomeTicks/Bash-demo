
if [ $0 == 'cut-tsv.sh' ]; then source helpers.sh; fi

tsv_file=$1
include_columns=${@:2}

columns_underscored=$(head -n 1 < $tsv_file | tr ' ' '_')

include_fields=
for col in $include_columns; do
    col_underscored=$(echo $col | tr ' ' '_')
    field_index=$(($(index-lst $col_underscored $columns_underscored)+1))
    include_fields="$include_fields,$field_index"
done
include_fields=${include_fields#,}

cut -f $include_fields < $tsv_file