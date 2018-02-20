function showData () {
  grep "$1" <<< "${companyInfo}"
  diff - "${capFileDir}/$1.txt" <<< "$2" | sed 's/^/ /'
}

cd ~/tsp || exit 1
capFileDir="dat/Capital"
companyInfo=$(< companyName.txt) || exit 1

htmlPage=$(curl http://www.sse.com.cn/market/stockdata/structure/change/) || exit 1
if (( $# > 0 )); then
  codes=$(printf "%s" "${htmlPage}" \
  | sed -n 's/''.*<a.*companyCode=\(.*\)&changeDate=\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)">.*/\1 \2\3\4/p' \
  | awk '$2>='$1' {print $1}')
else
  codes=$(printf "%s" "${htmlPage}" | sed -n 's/''.*<a.*companyCode=\(.*\)&changeDate=.*">.*/\1/p')
fi

htmlPage=$(curl http://www.szse.cn/main/disclosure/) || exit 1
htmlPage=$(printf "%s" "${htmlPage}" | iconv -c -f gb2312 -t utf8)
for nameStr in $(awk '/REPORT_ID.*REPORT_ID_xxpl_jrts.*REPORTID_tab1/ {gsub("<\/span>","\n");print}' <<< "${htmlPage}" \
| sed -n "s/^<span>\(.*\)/\1/p;s/.*<span style=.*>\(.*：\)/\1/p" \
| awk '{gsub("(&nbsp;| )","");if($1 ~ /.*：/) evtName=$1;else if(evtName ~ /证券发行|证券上市|除权除息/) print}' \
| sort | uniq); do
  nameStr=$(printf '%s' "${nameStr}" | tr 'Ａ' 'A')
  foundCodeStr=$(printf '%s' "${companyInfo}" | awk '$2=="'"${nameStr}"'" {print $1}')
  if [[ -z "${foundCodeStr}" ]]; then
    items+="${nameStr} "
  else
    codes+=" ${foundCodeStr}"
  fi
done

emDir="tmp/em"
sohuDir="tmp/sohu"
for codeStr in $codes; do
  echo "${codeStr}"
  if (( ${codeStr: 0:1} == 6 )); then
    curl "http://f9.eastmoney.com/sh${codeStr}.html" \
    | iconv -c -f gb2312 -t utf8 > "${emDir}/${codeStr}.html"
  else
    curl "http://f9.eastmoney.com/sz${codeStr}.html" \
    | iconv -c -f gb2312 -t utf8 > "${emDir}/${codeStr}.html"
  fi
  curl "http://q.stock.sohu.com/cn/${codeStr}/gbjg.shtml" \
  | iconv -c -f gb2312 -t utf8 > "${sohuDir}/${codeStr}.shtml"
  slpSec=$((RANDOM/8191+1))
  echo "wait for ${slpSec} second(s)..."
  sleep $slpSec
done
printf "Unknown names for\n%s\n" "$items"

items=""
for codeStr in $codes; do
  dateStr=$(sed -n '/变动日期/{n;s/.*<td>\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\).*/\1\2\3/;p;}' "${sohuDir}/${codeStr}.shtml")
  if (( $? != 0 )); then
    continue
  elif [[ -z "${dateStr}" ]]; then
    nothing+="${codeStr} "
    continue
  elif (( ${#dateStr} != 8 )); then
      dateStr=""
  fi
  capStr=$(sed -n '/<tr><td>流通A股/{s/.*<tr><td>流通A股<\/td><td>\(.*\)<\/td><td>.*<\/td><\/tr><tr><td>流通B股<\/td>.*<tr><td>流通H股<\/td>.*<tr><td>其他流通股<\/td>.*<tr><td>流通受限股<\/td>.*<tr><td>未流通股份<\/td>.*<tr><td>总股本<\/td><td>\(.*\)<\/td><td>.*<\/td><\/tr>.*/\2 \1/;s/,//g;p;}' "${emDir}/${codeStr}.html")
  if (( $? != 0 )); then
    continue
  elif [[ -z "${capStr}" ]]; then
    nothing+="${codeStr} "
    continue
  fi
  newData="${dateStr} ${capStr}"
  if [[ -s "${capFileDir}/${codeStr}.txt" ]]; then
    capFileOrig=$(< "${capFileDir}/${codeStr}.txt")
    if [[ "${newData}" != $(printf "%s" "${capFileOrig}" | head -n 1) ]]; then
      newData+=$'\n'"${capFileOrig}"
      echo "${newData}" > "${capFileDir}/${codeStr}.txt"
      showData "${codeStr}" "${capFileOrig}"
    else
      items+="${codeStr} "
    fi
  else
    echo "${newData}" > "${capFileDir}/${codeStr}.txt"
    showData "${codeStr}" ""
  fi
done
[[ -n "${items}" ]] && printf "No updates for\n%s\n" "${items}"
[[ -n "${nothing}" ]] && printf "Nothing for\n%s\n" "${nothing}"
