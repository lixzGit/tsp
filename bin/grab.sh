while read line; do
  lines+="$line "
done
codes=($lines)

i=0
cd ~/tsp || exit 1
for code in ${codes[@]}; do
  echo "$code"
  if ((${code: 0:1} == 6)); then
    htmlPage=$(curl "http://f9.eastmoney.com/sh${code}.html" \
               || emCodes+="$code ")
    iconv -c -f gb2312 -t utf8 > "tmp/em/${code}.html" <<< "$htmlPage"
  else
    htmlPage=$(curl "http://f9.eastmoney.com/sz${code}.html" \
               || emCodes+="$code ")
    iconv -c -f gb2312 -t utf8 > "tmp/em/${code}.html" <<< "$htmlPage"
  fi
  htmlPage=$(curl "http://q.stock.sohu.com/cn/${code}/gbjg.shtml" \
             || sohuCodes+="$code ")
  iconv -c -f gb2312 -t utf8 > "tmp/sohu/${code}.shtml" <<< "$htmlPage"
  (( ++i < ${#codes[@]} )) && {
    slpSec=$((RANDOM/8191+1))
    echo "wait for ${slpSec} second(s)..."
    sleep $slpSec
  }
done
[[ -n "$emCodes" ]] && echo "$emCodes"
[[ -n "$sohuCodes" ]] && echo "$sohuCodes"
