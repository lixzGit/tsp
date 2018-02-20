(( $# != 1 )) && {
	echo 'date must be specified.' >&2
	exit 1
}
while read line; do
  lines+="$line "
done
codes=($lines)

cd ~/tsp || exit 1
outPath="dat/TimeSharing/$1"
[[ -d "$outPath" ]] || mkdir -p "$outPath"
i=0
for code in ${codes[@]}; do
  (( ++i ))
  nextCode=0
  pageNo=1
  echo "$code"

  rsp=$(eval curl $(bin/jsc bin/edtHqdigi2EMCurl.js <<< "$code $pageNo"))
  (( $? == 0 )) || {
  	errCodes+="$code "
  	nextCode=1
  }
  (( $i < ${#codes[@]} )) && {
    slpSec=$((RANDOM/8191+1))
    echo "wait for" $slpSec "second(s)..."
    sleep $slpSec
  }
  (( nextCode == 1 )) && continue
  data=$(bin/jsc bin/edtHqdigi2EMTimeSharingData.js <<< "$rsp")
  totalPage=$(sed -n '1p' <<< "$data")
  sed -n '2,$p' <<< "$data" > "$outPath/$code.txt"

  for (( ++pageNo; $pageNo <= $totalPage; ++pageNo )); do 
  	rsp=$(eval curl $(bin/jsc bin/edtHqdigi2EMCurl.js <<< "$code $pageNo"))
  	[[ $? == 0 ]] || {
  	  errCodes+="$code "
  	  continue 2
    }
    bin/jsc bin/edtHqdigi2EMTimeSharingData.js <<< "$rsp" | sed -n '2,$p' >> "$outPath/$code.txt"
  done
done
[[ -n "$errCodes" ]] && printf "%s\n%s\n" "error:" "$errCodes"