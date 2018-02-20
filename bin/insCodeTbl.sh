while read line; do
  lines+="$line "
done
codes=($lines)

for code in ${codes[@]}; do
  inCodes+="$code"$'\n'
done

cd ~/tsp || exit 1
if [[ -s codeTbl.txt ]]; then
  inCodes+=$(< codeTbl.txt)
fi
sort <<< "$inCodes" | uniq > codeTbl.txt
