#!/bin/zsh
zmodload zsh/net/tcp
autoload -U tcp_open

(( $# > 0 )) || exit 1
TCP_SILENT=1
TCP_PROMPT=''
reqHead='GET /list='
reqTail=$'HTTP/1.1\r\nHost: hq.sinajs.cn\r\nUser-Agent: tsp/0.0.1\r\n\r\n'
readTO=2

tcp_open -q hq.sinajs.cn http || { echo 'connection failed' >&2; exit 1; }

for reqBody; do
#while read reqBody; do
  tcp_send -n "${reqHead}${reqBody} ${reqTail}"
  tcp_expect -t $readTO 'HTTP/1.1 200 OK[[:space:]]*' || {
    echo "HTTP HEAD: error $?" >&2; tcp_close -q; exit 2; }
  if tcp_expect -t $readTO 'Content-Type: *; charset=[[:alnum:]]*[[:space:]]*'; then
    [[ "$TCP_LINE" =~ 'Content-Type: (.*); charset=([[:alnum:]]*)[[:space:]]*' ]] && \
    charSet="${match[2]}"
  else
    echo "HTTP HEAD: error $?" >&2
    tcp_close -q
    exit 2
  fi
  tcp_expect -t $readTO '[[:space:]]*' || { echo "HTTP HEAD: error $?" >&2; tcp_close -q; exit 2; }
  tcp_read -d || { echo "HTTP BODY: error $?" >&2; tcp_close -q; exit 2; }
  for rspLine in $tcp_lines; do
    rspLines+="$rspLine"$'\n'
  done
  printf '%s' "$rspLines" | iconv -f "$charSet" -t utf8
  (( $? == 0 )) || echo 'decoding error' >&2
  rspLines=''
done
tcp_close -q
