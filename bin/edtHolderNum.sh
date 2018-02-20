function showData () {
  grep "$1" <<< "$companyInfo"
  diff - "$1.num" <<< "$2" | sed 's/^/ /'
}

while read line; do
  lines+="$line "
done
codes=($lines)

cd ~/tsp || exit 1
emHolderDir="tmp/em"
holderDir="dat/Holder"
companyInfo=$(< companyName.txt) || exit 1

for code in ${codes[@]}; do
  htmlPage=$(< "${emHolderDir}/${code}.html")
  [[ -n "$htmlPage" ]] || continue
  data=$(awk '/股东人数明细/,/十大流通股东/{if(match($0,"时间.*股东人数.*较上期增长.*人均持股数.*较上期增加")) print}' <<< "$htmlPage" | awk -f bin/grabTbodyValue.awk | sed -n '1d;p')
  [[ -n "$data" ]] || { echo "nothing: $code" >&2; continue; }
  newRows=$(awk '{gsub("-","",$1)
    index($2,"万")?gsub("万","",$2):($2/=10000)
    gsub(",|%","",$3)
    gsub(",|%","",$5)
    print}' <<< "$data")
  [[ $? == 0 && -n "$newRows" ]] || continue
  if [[ -s "${holderDir}/${code}.num" ]]; then
    rows=$(< "${holderDir}/${code}.num")
    rowArr=($rows)
#  [[ -s "${holderDir}/${code}.num" ]] && rows+=$'\n'$(< "${holderDir}/${code}.num")
#  sort -n -r -k 1 <<< "$rows" | uniq > "${holderDir}/${code}.num"
#  rows=$(sort -n -r -k 1 <<< "$rows" | uniq)
    awk -v inRow="${rowArr[*]}" \
    'BEGIN{prevDate="99999999";n=split(inRow,rowArr);i=1}
     {date=rowArr[i]
      if($1==date) {
       rows=rows $0 "\n"
       prevDate=$1
      } else if($1>date) {
       rows=rows $0 "\n"
       prevDate=$1
       next
      } else {
       rows=rows rowArr[i] " " rowArr[i+1] " " rowArr[i+2] " " rowArr[i+3] " " rowArr[i+4] "\n"
       prevDate=date
      }
      i+=5
     }
     END{for(;i<n;i+=5) rows=rows rowArr[i] " " rowArr[i+1] " " rowArr[i+2] " " rowArr[i+3] " " rowArr[i+4] "\n"
      printf "%s",rows}
    ' <<< "$newRows" > "${holderDir}/${code}.num"
#    echo "$rows" > "${holderDir}/${code}.num"
    showData "$code" "$rows"
  else
    grep "$code" <<< "$companyInfo"
    echo "$newRows" > "${holderDir}/${code}.num"
    echo "$newRows" | sed 's/^/ /'
  fi
done
