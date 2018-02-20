while read line; do
  lines+="$line "
done
codes=($lines)

cd ~/tsp || exit 1
emDir="tmp/em"

for code in ${codes[@]}; do
  nameStrArr=($(sed -n 's/.*<meta name="Keywords" content="\(.*\),.*,f9,.*/\1/p;s/.*<td.*>公司名称<\/td><td.*>\(.*\)<\/td>.*<td.*>法人代表<\/td>.*/\1/p' "${emDir}/${code}.html"))
  if (( $? != 0 )); then
    continue
  elif [[ ${#nameStrArr[@]} != 2 ]]; then
    echo "nothing for ${code}" >&2
    continue
  fi
  names+="${nameStrArr[@]};"
  inCodes+="${code} "
done
orig=$(< companyName.txt)
rows=$(awk -v inNames="$names" -v inCodes="$inCodes" '
 BEGIN{nCode=split(inCodes,codeArr);split(inNames,nameArr,";")}
 {for(i=1;i<=nCode;i++)
   if(codeArr[i]==$1) {rows=rows $1 " " nameArr[i] "\n";delete codeArr[i];next}
  rows=rows $0 "\n"}
 END{for(i=1;i<=nCode;i++)
      if(length(codeArr[i])>0) rows=rows codeArr[i] " " nameArr[i] "\n"
     printf "%s",rows}
' <<< "$orig")
printf '%s' "$rows" | sort -k 1 > companyName.txt
diff - companyName.txt <<< "$orig"
