dt=$(date "+%Y%m%d")
upd=0
while getopts d:p: opt; do
  case "$opt" in
    d) { dt=$OPTARG; upd=1; };;
    p) path=$OPTARG;;
  esac
done
cd "$path" || exit 1
(( upd == 0 )) && echo "No date specified. $dt is used." >&2
awk \
'{ if($17=="-") next;
  gsub("%","",$5);
  gsub("%","",$12);
  gsub("%","",$19);
  print $2,$17*1000,$15*1000,$16*1000,$4*1000,$7,$13,$19,$20,$5,$24,$25,$26,$12}' - | \
{
while read line; do
  fileName="${line:0:6}.txt"
  if [[ -s "$fileName" ]]; then
    rows=$(< "$fileName")
    awk -v inRow="${line:7}" -v inDate="$dt" -v upd=$upd \
    'BEGIN{prevDate=99999999}
     {if(inDate==$1 && upd==1) print inDate,inRow
      else {if(inDate<prevDate && inDate>$1) print inDate,inRow
            print $0}
      prevDate=$1
     }
    ' <<< "$rows" > "$fileName"
  else
    echo $dt ${line:6} > "$fileName"
  fi
done
}