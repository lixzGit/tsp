#!/bin/zsh
unsetopt MULTIBYTE
zmodload zsh/net/tcp
autoload -U tcp_open

[[ $# > 0 ]] || { echo "Date must be specified."; exit 1; }
xdDate="$1"
TCP_SILENT=1
TCP_PROMPT=
reqHead='GET'
reqTail=$'HTTP/1.1\r\nHost: stock.10jqka.com.cn\r\nUser-Agent: tsp/0.0.1\r\n\r\n'
readTO=3

tcp_open -q stock.10jqka.com.cn http || { echo "connection failed"; exit 1; }

reqBody='/fhspxx_list/'
tcp_send -n "${reqHead} ${reqBody} ${reqTail}"
tcp_expect -t $readTO 'HTTP/1.1 200 OK[[:space:]]*' \
  || { echo "HTTP HEAD: error $?"; tcp_close -q; exit 2; }
if tcp_expect -t $readTO 'Content-Type: *; charset=[[:alnum:]]*[[:space:]]*'; then
  [[ "$TCP_LINE" =~ 'Content-Type: (.*); charset=([[:alnum:]]*)[[:space:]]*' ]] \
    && charSet="${match[2]}"
else
  echo "HTTP HEAD: error $?"
  tcp_close -q
  exit 2
fi
tcp_expect -t $readTO 'Transfer-Encoding: chunked[[:space:]]*' \
  || { echo "not chunked: error $?"; tcp_close -q; exit 2; }
tcp_expect -t $readTO '[[:space:]]*' || { echo "HTTP HEAD: error $?"; tcp_close -q; exit 2; }
for (( ; ; )) do
  read -t $readTO -u $TCP_LINE_FD rspLine \
    || { echo "CHUNK size: error $?"; tcp_close -q; exit 2; }
  cSize=$(( 16#$(tr -d '[[:space:]]' <<< "$rspLine") + 2 ))
  (( $cSize > 2 )) || break
  read -d '' -k $cSize -u $TCP_LINE_FD rspLine \
    || { echo "CHUNK data: error $?"; tcp_close -q; exit 2; }
  chunks+="$rspLine"
done

pageUrl=$(iconv -c -f "$charSet" -t utf8 <<< "$chunks" \
  | sed -n 's/.*沪（深）市分红配送信息提示.*" href="\(.*\/'"$xdDate"'\/.*\)">.*<\/a>.*/\1/p')
[[ -z "$pageUrl" ]] || pageName=$(basename "$pageUrl")
[[ -z "$pageName" ]] && { echo "empty doc name"; tcp_close -q; exit 2; }
tcp_close -q
exit
tcp_send -n "${reqHead} /${xdDate}/${pageName} ${reqTail}"
tcp_expect -t $readTO 'HTTP/1.1 200 OK[[:space:]]*' || {
  echo "HTTP HEAD: error $?"; tcp_close -q; exit 2; }
if tcp_expect -t $readTO 'Content-Type: *; charset=[[:alnum:]]*[[:space:]]*'; then
  [[ "$TCP_LINE" =~ 'Content-Type: (.*); charset=([[:alnum:]]*)[[:space:]]*' ]] && \
  charSet="${match[2]}"
else
  echo "HTTP HEAD: error $?"
  tcp_close -q
  exit 2
fi
tcp_expect -t $readTO '[[:space:]]*' || { echo "HTTP HEAD: error $?"; tcp_close -q; exit 2; }
tcp_read -d || { echo "HTTP BODY: error $?"; tcp_close -q; exit 2; }
rspLines=''
for rspLine in $tcp_lines; do
  rspLines+="$rspLine"$'\n'
done
iconv -c -f "$charSet" -t utf8 <<< "$rspLines"
tcp_close -q
