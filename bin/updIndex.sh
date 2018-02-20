(( $# > 0 )) || { echo 'Code must be specified.' >&2; exit 1; }

cd ~/tsp || exit 1

#for rspLine in $(bin/grabHqSinajsCn.sh $@ | tr ' ' '_'); do
bin/grabHqSinajsCn.sh $@ | \
{ while read rspLine; do
    fileName="dat/Sample/${rspLine:11:8}.txt"
    newRow=$(printf "%s" "${rspLine:21}" | awk -F ',' '
      {gsub("-","",$31);
       printf "%s %s %s %s %s %s %s %.4f %.4f\n",
         $31,$2,$5,$6,$4,$9,$10,($4/$2-1)*100,($4/$3-1)*100
      }')
    if [[ -s "$fileName" ]]; then
      newRow+=$'\n'$(< "$fileName")
    fi
    echo "$newRow" > "$fileName"
  done
}
