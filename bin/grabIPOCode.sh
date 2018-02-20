pgUrl="http://data.10jqka.com.cn/ipo/xgsgyzq/"
userAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.1 Safari/603.1.30'

cd ~/tsp || exit 1
if (( $# == 1 )); then 
  dt="$1"
else
  dt=$(date "+%m%d")
  echo "No date specified. $dt is used." >&2
fi

html=$(curl -A "$userAgent" "$pgUrl" | iconv -c -f gbk -t utf8) || exit 1

ipo=$(sed -n '/<tbody class="m_tbd">/,/<\/tbody>/p' <<< "$html" | awk -v nc=13 -f bin/grabTbodyValue.awk | tr -ds '\t' '[:blank:]' | \
sed -n 's/<a[^>]*>\([^<]*\)<\/a>/\1/g;s/<!--a[^<]*>\([^<]*\)<\/a-->/\1/gp' | \
awk -v dt="$dt" '{gsub("-","",$14);if(NF==18 && $14==dt) print $1}')
bin/insCodeTbl.sh <<< "$ipo"
echo "$ipo"