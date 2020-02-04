function showData () {
  grep "$1" <<< "${companyInfo}"
  diff - "${capFileDir}/$1.txt" <<< "$2" | sed 's/^/ /'
}

cd ~/tsp || exit 1
capFileDir="dat/Capital"
companyInfo=$(< companyName.txt) || exit 1

while read code capDate capitalization capFloating; do
  capStr="$capDate $capitalization $capFloating"
  if [[ -s "$capFileDir/$code.txt" ]]; then
    capFile=$(< "$capFileDir/$code.txt")
    if (( $capDate > ${capFile: 0:8} )); then
      capStr+=$'\n'"$capFile"
      echo "$capStr" > "$capFileDir/$code.txt"
      showData "$code" "$capFile"
    else
      noUpds+="$code "
    fi
  else
    echo "$capStr" > "$capFileDir/$code.txt"
    showData "$code" ""
  fi
done
[[ -n "$noUpds" ]] && echo "No updates for"$'\n'"$noUpds"