while getopts c:d:n: opt; do
  case "$opt" in
    c) capMax=$OPTARG;;
    d) dateMax=$OPTARG;;
    n) nRow=$OPTARG;;
    ?) exit 1;;
  esac
done

cd ~/tsp/dat
[[ -z "$nRow" || $nRow < 1 ]] && nRow=5
[[ -z "$capMax" ]] && capMax=50
capMax=$((capMax*10000))
[[ -z "$dateMax" ]] && {
  dateMax=$(awk '{print $1;exit}' "Sample/sh000001.txt") \
          || { echo "read index fail" >&2; exit 1; }
}
idxRows=$(awk -v inDate=$dateMax -v inRow=$nRow \
          'BEGIN{iRow=inRow}
           {if($1<=inDate){rows[--iRow]=$0;if(iRow==0) exit}}
           END{if(iRow==0) while(iRow<inRow) print rows[iRow++]}
          ' "Sample/sh000001.txt") || { echo "read index fail" >&2; exit 1; }
[[ "$idxRows" ]] || { echo "too few index lines" >&2; exit 1; }

dateMin=$(awk '{print $1;exit}' <<< "$idxRows") \
        || { echo "read index fail" >&2; exit 1; }
idxScrs=$(awk '{print ($3/$4-1)*100,$9}' <<< "$idxRows") \
        || { echo "get index scores fail" >&2; exit 1; }

while read line; do
  lines+="$line "
done
codes=($lines)

for code in ${codes[@]}; do
  smpFile="Sample/${code}.txt"
  wgtFile="Weight/${code}.txt"
  capFile="Capital/${code}.txt"
  [[ -s "$smpFile" ]] || { echo "none sample: $code" >&2; continue; }
  [[ -e "$wgtFile" ]] || { echo "none weight: $code" >&2; continue; }
  [[ -e "$capFile" ]] || { echo "none capital: $code" >&2; continue; }
  smpRows=$(< "$smpFile")
  smpRows=$(awk -v inDate=$dateMax -v inRow=$nRow \
         'BEGIN{iRow=++inRow}
          {if($1<=inDate){rows[--iRow]=$0;if(iRow==0) exit}}
          END{if(iRow<2){if(iRow==1) rows[0]=$0;iRow=inRow;while(iRow>-1) print rows[--iRow]}}
         ' <<< "$smpRows") || { echo "read sample fail" >&2; exit 1; }
  if [[ "$smpRows" ]]; then
    smpDate=$(awk '{print $1;exit}' <<< "$smpRows") || { echo "read sample fail" >&2; exit 1; }
    (( $smpDate < $dateMin )) && { echo "out of date: $code" >&2; continue; }
    wgtArr=($(../bin/calcWeight - "$wgtFile" <<< "$smpRows")) \
           || { echo "calc weight fail: $code" >&2; continue; }
    capCmp=$(awk -v inDate=$dateMax -v c=${wgtArr[3]} -v capVal=$capMax \
             '{if(inDate>=$1) exit}END{if(c/1000*$3<=capVal) print "1"}' "$capFile") \
             || { echo "read capital fail" >&2; exit 1; }
    [[ $capCmp ]] || continue
  else
    continue
  fi
  printf "%s" "$code"
  awk -v smpVals="$(tr -d '\n' <<< ${smpRows[*]})" '
  BEGIN{n=split(smpVals,smpArr)-14}{printf " %s",($1>1?smpArr[n-6]/$1:smpArr[n-6]*$1);n-=14}
  ' <<< "$idxScrs"
  echo ''
done
