codeCnt=0
delm=','
for codeStr; do
  if ((${codeStr: 0:1} == 6)); then
    outStr+="sh${codeStr}${delm}"
  else
    outStr+="sz${codeStr}${delm}"
  fi
  if (( ++codeCnt == 500 )); then
    echo "$outStr"
    codeCnt=0
    outStr=''
  fi
done
echo "$outStr"
