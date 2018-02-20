(( $# != 2 )) && { echo 'Date and page number must be specified.' >&2; exit 1; }

cd ~/tsp || exit 1
pgUrl="http://data.10jqka.com.cn/financial/sgpx/date/2016-12-31/board/ALL/field/cqcxr/order/desc/page/$2/ajax/1/"
userAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.1 Safari/603.1.30'

html=$(curl -A "$userAgent" "$pgUrl" | iconv -c -f gbk -t utf8) || exit 1
if [[ -z "$html" ]]; then
  echo "failed: $pgUrl" >&2
  exit 1
fi

bin/edtWeight.sh "$1" <<< "$html"