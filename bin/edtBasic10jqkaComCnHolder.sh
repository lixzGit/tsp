function showData () {
  echo "$companyInfo" | grep "$1"
  sed 's/^/ /' "$capFileDir/$1.txt"
}

cd ~/tsp || exit 1
hldFileDir="dat/Holder"
companyInfo=$(< companyName.txt) || exit 1

while read -a flds; do
  eval awk -v "fld='${flds[@]}'" \
  "'BEGIN{nV=split(fld,v);for(i=2;i<nV;i+=6) m[v[i]]=sprintf(\"%s %s %s %s %s\",v[i+1],v[i+2],v[i+3],v[i+4],v[i+5]);}{if(m[\$1]) {print \$1,m[\$1];delete m[\$1];} else print;}END{for(l in m) if(m[l]) print l,m[l];}'" \
  "$hldFileDir/${flds[0]}.num" | sort -r
done
