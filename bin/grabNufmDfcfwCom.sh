MAX_CODES_PER_REQUEST=200
idx=0
iCodes=0

cd ~/tsp/bin || exit 1
while read line; do
  if (( idx++ < MAX_CODES_PER_REQUEST )); then
    codes[iCodes]+="$line "
  else 
    codes[++iCodes]+="$line "
    idx=0;
  fi
done

i=0
for (( idx = 0; idx <= iCodes; idx++ )); do
  (( ++i ))
  url=$(./jsc edtNufmDfcfwComCurl.js <<< "${codes[idx]}")
  html=$(eval curl -g '$url')
  if (( $? == 0 )); then
    iconv -f UTF8 -t C99 <<< "$html" | ./jsc edtNufmDfcfwCom.js
  else
    errCodes+="${codes[idx]} "
  fi
  (( $i <= $iCodes )) && {
    slpSec=$((RANDOM/8191+1))
    echo 'wait for' $slpSec 'second(s)...' >&2
    sleep $slpSec
  }
done
[[ -n "$errCodes" ]] && printf "%s\n%s\n" "error:" "$errCodes" >&2