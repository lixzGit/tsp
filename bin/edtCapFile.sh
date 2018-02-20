function showData () {
  echo "${companyInfo}" | grep "$1"
  sed 's/^/ /' "${capFileDir}/$1.txt"
}

while read line; do
  lines+="$line "
done
codes=($lines)

cd ~/tsp || exit 1
capFileDir="dat/Capital"
datTmpDir="tmp"
companyInfo=$(< companyName.txt) || exit 1

for codeStr in ${codes[@]}; do
  dateStr=$(sed -n '/变动日期/{n;s/.*<td>\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\).*/\1\2\3/;p;}' "${datTmpDir}/sohu/${codeStr}.shtml")
  if (( $? != 0 )); then
    continue
  elif [[ -z "${dateStr}" ]]; then
    nothing+="${codeStr} "
    continue
  fi
  capStr=$(sed -n '/<tr><td>流通A股/{s/.*<tr><td>流通A股<\/td><td>\(.*\)<\/td><td>.*<\/td><\/tr><tr><td>流通B股<\/td>.*<tr><td>流通H股<\/td>.*<tr><td>其他流通股<\/td>.*<tr><td>流通受限股<\/td>.*<tr><td>未流通股份<\/td>.*<tr><td>总股本<\/td><td>\(.*\)<\/td><td>.*<\/td><\/tr>.*/\2 \1/;s/,//g;p;}' "${datTmpDir}/em/${codeStr}.html")
  if (( $? != 0 )); then
    continue
  elif [[ -z "${capStr}" ]]; then
    nothing+="${codeStr} "
    continue
  fi
  newData="${dateStr} ${capStr}"
  if [[ ! -e "${capFileDir}/${codeStr}.txt" ]]; then
    echo "${newData}" > "${capFileDir}/${codeStr}.txt"
    showData "${codeStr}"
  elif [[ "${newData}" != $(head -n 1 "${capFileDir}/${codeStr}.txt") ]]; then
    newData+=$'\n'$(< "${capFileDir}/${codeStr}.txt")
    echo "${newData}" > "${capFileDir}/${codeStr}.txt"
    showData "${codeStr}"
  else
    items+="${codeStr} "
  fi
done
echo "No updates for"$'\n'"${items}"
echo "Nothing for"$'\n'"${nothing}"
