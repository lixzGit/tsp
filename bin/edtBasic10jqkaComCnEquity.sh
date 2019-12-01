function showData () {
  echo "$companyInfo" | grep "$1"
  sed 's/^/ /' "$capFileDir/$1.txt"
}

cd ~/tsp || exit 1
capFileDir="dat/Capital"
companyInfo=$(< companyName.txt) || exit 1

while read code capDate capitalization capFloating; do
  newData="$capDate $capitalization $capFloating"
  if [[ ! -e "$capFileDir/$code.txt" ]]; then
    echo "$newData" > "$capFileDir/$code.txt"
    showData "$code"
  elif [[ "$newData" != $(head -n 1 "$capFileDir/$code.txt") ]]; then
    newData+=$'\n'$(< "$capFileDir/$code.txt")
    echo "$newData" > "$capFileDir/$code.txt"
    showData "$code"
  else
    noUpds+="$code "
  fi
done
[[ -n "$noUpds" ]] && echo "No updates for"$'\n'"$noUpds"