[[ $# > 0 ]] || { echo "No code specified."; exit 1; }

cd ~/tsp || exit 1
holderDir="tmp/em"

for codeStr; do
  htmlPage=$(< "${holderDir}/${codeStr}.html")
  [[ -n "$htmlPage" ]] || continue
  data=$(sed -n '/十大流通股东/,/十大股东/ {
    s/.*十大流通股东(\([0-9]\{4\}\)年\([0-9]\{2\}\)月\([0-9]\{2\}\)日.*/\1\2\3/p
    /名次.*股东名称.*股份类型.*持股数.*持股比例/s/<tr>/\
/gp
    }' <<< "$htmlPage")
  [[ $? == 0 ]] || continue
  dateStr=$(head -n 1 <<< "$data")
  data=$(sed -n '3,$p' <<< "$data" | tr ' ' '_' \
  | sed -n 's/<td>.*<\/td><td>\(.*\)<\/td><td>\(.*\)<\/td><td>\(.*\)<\/td><td>\(.*\)%<\/td><td>\(.*\)<\/td>.*/\1 \2 \3 \4 \5/p' \
  | awk '{gsub(",","",$3);gsub(",","",$5);gsub("&amp;","\\\&",$1);print}')
  [[ -n "$data" && ${#dateStr} == 8 ]] || {
    echo "wrong: $codeStr" >&2
    continue
  }
#  echo "$data" > "dat/Holder/${codeStr}.top10"
  echo "$data"
done
