while read line; do
  lines+="$line "
done
codes=($lines)

cd ~/tsp/bin || exit 1
i=0
for code in ${codes[@]}; do
  (( ++i ))
  eval curl $(./jsc edtHqdigi2EMCurl.js <<< "$code $2")
  (( $? == 0 )) || errCodes+="$code "
  (( $i < ${#codes[@]} )) && {
    slpSec=$((RANDOM/8191+1))
    echo 'wait for' $slpSec 'second(s)...' >&2
    sleep $slpSec
  }
done
[[ -n "$errCodes" ]] && printf "%s\n%s\n" "error:" "$errCodes"
