cd ~/tsp/dat/Sample || exit 1

while read rspLine; do
  newRow=${rspLine:20}
  if [[ -z "$newRow" || ${rspLine:20:3} == '"";' ]]; then
    echo "nothing: $rspLine" >&2
    continue
  fi
  newRow=$(awk -F ',' \
           '{if($2!=0 && $3!=0){
              gsub("-","",$31);
              printf "%s %s %s %s %s %s %s\n",
              $31,$2*1000,$5*1000,$6*1000,$4*1000,$9,$10}
            }' <<< "$newRow")
  if [[ $newRow ]]; then
    fileName="${rspLine:13:6}.txt"
    if (( ${#fileName} != 10 )); then
      echo "file name error: $rspLine" >&2
      exit 1
    fi
    if [[ -s "$fileName" ]]; then
      rows=$(< "$fileName")
      awk -v inRow="$newRow" \
      'BEGIN{prevDate="99999999";inDate=substr(inRow,1,8)}
       {if(inDate==$1) print inRow
        else {if(inDate<prevDate && inDate>$1) print inRow
              print $0}
        prevDate=$1
       }
      ' <<< "$rows" > "$fileName"
    else
      echo "$newRow" > "$fileName"
    fi
  fi
done
