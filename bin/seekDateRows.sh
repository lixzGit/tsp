dt=$(date "+%Y%m%d")

while getopts d: opt; do
  case "$opt" in
    d) { dt=$OPTARG; shift 2; };;
    ?) exit 1;;
  esac
done

awk -v inDate="$dt" '{if(inDate<$1) next;print}' $@