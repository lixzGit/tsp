upd=0
while getopts d:p: opt; do
  case "$opt" in
    d) { dt=$OPTARG; upd=1; };;
    p) path=$OPTARG;;
  esac
done
cd "$path" || exit 1
(( $# != 1 )) && { echo 'No file specified.' >&2; exit 1; }
fileName="$1.txt"

while read line; do
  lns+=line
done

if [[ -s "$fileName" ]]; then
  flns=$(< "$fileName")
  lns=$(awk -v flns="$flns" -v upd=$upd '
  BEGIN{nLn=split(flns,lna,"\n");prevDate=99999999}
  {for(i=1;i<=nLn;i++) {
    dt=substr(lna[i],1,8)
    if($1==dt && upd==1) {print;break}
    else if($1<prevDate && $1>dt) {print $0,"\n",lna[i];break}
   }
   prevDate=$1
  }' <<< "$lns")
  printf "%s" "$lns" > "$fileName"
else
  echo "$lns" > "$fileName"
fi