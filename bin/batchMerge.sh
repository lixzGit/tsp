cd ~/tsp
mkdir -p bak/new || exit 1
while read code; do
  agg=$(bak/edtAIgg.sh <<< "$code")
  awk -v fl=dat/Sample/$code.txt -f bin/merge.awk <<< "$agg" | sort -n -r -k 1 > bak/new/$code.txt
  echo $code
  diff dat/Sample/$code.txt bak/new/$code.txt
done
