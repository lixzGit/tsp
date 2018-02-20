while getopts c: opt; do
  case "$opt" in
    c) capMax=$OPTARG;;
    ?) exit 1;;
  esac
done

[[ -z "$capMax" ]] && capMax=50
capMax=$((capMax*10000))

while read line; do
  lines+="$line "
done
codes=($lines)

cd ~/tsp/dat || exit 1
dt=$(date "+%Y%m%d")
for code in ${codes[@]}; do
  smpFile="Sample/$code.txt"
  wgtFile="Weight/$code.txt"
  capFile="Capital/$code.txt"
  [[ -s "$smpFile" ]] || { echo "none sample: $code" >&2; continue; }
  [[ -e "$wgtFile" ]] || { echo "none weight: $code" >&2; continue; }
  [[ -e "$capFile" ]] || { echo "none capital: $code" >&2; continue; }
  smpRow=$(head -n 1 "$smpFile")
  if [[ "$smpRow" ]]; then
    wgtArr=($(util/calcWeight - "$wgtFile" <<< "$smpRow")) \
           || { echo "calc weight fail: $code" >&2; continue; }
    capFile=$(head -n 1 "$capFile")
    capCmp=$(awk -v c=${wgtArr[3]} -v capVal=$capMax \
             '{if(c/1000*$3<=capVal) print "1"}' <<< "$capFile") \
             || { echo "read capital fail" >&2; exit 1; }
    [[ $capCmp ]] || continue
    (( $dt - ${smpRow:0:8} > 199 )) && echo "$code"
  else
    continue
  fi
done
