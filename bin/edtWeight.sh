(( $# > 0 )) || { echo 'Date must be specified.' >&2; exit 1; }

cd ~/tsp || exit 1
xdDateDst="$1"
(( ${#xdDateDst} != 8 )) && { echo 'Date format error.' >&2; exit 1; }

xdRows=($(awk -v inDate=$xdDateDst '{gsub("--","0");print $2,$10*100,$9*1000,0,0}'))
# xdRows=($(sed -n '/<tbody[^>]*>/,/<\/tbody>/p' | sed -n '1d;$d;p' | awk -f util/grabTbodyValue.awk | \
# tr -ds '\t' '[:blank:]' | sed -n 's/<a[^>]*>\([^<\/a>]*\)<\/a>/\1/gp' | \
# awk '{gsub("-","",$14);gsub("--","0");print $2,$14,$10,$11}' | \
# awk -v inDate=$xdDateDst '{if($2==inDate) printf "%s %d %d 0 0\n",$1,$4*100,$3*1000}'))

nElem=${#xdRows[@]}
for (( i=0; i<nElem; i+=5 )); do
  xdFilePath="dat/Weight/${xdRows[i]}.txt"
  if [[ -s "${xdFilePath}" ]]; then
    xdFileOrig=$(< "${xdFilePath}")
    printf "%s" "${xdFileOrig}" | \
    awk -v inDate="${xdDateDst}" -v cap="${xdRows[i+1]} ${xdRows[i+2]} ${xdRows[i+3]} ${xdRows[i+4]}" '
      BEGIN{prevDate=99991232}
      {if(inDate==$1) rows=rows $1 " " cap "\n"; else {
        if(inDate<prevDate && inDate>$1) rows=rows inDate " " cap "\n"
        rows=rows $0 "\n"
       }
       prevDate=$1}
      END{printf "%s",rows}'\
    > "${xdFilePath}"
  else
    xdFileOrig=""
    echo $xdDateDst ${xdRows[i+1]} ${xdRows[i+2]} ${xdRows[i+3]} ${xdRows[i+4]} > "${xdFilePath}"
  fi
  echo "${xdRows[i]}"
  if [[ "${xdFileOrig}" ]]; then
    diff - "${xdFilePath}" <<< "${xdFileOrig}" | sed 's/^/ /'
  else
    sed 's/^/ /' "${xdFilePath}"
  fi
done
