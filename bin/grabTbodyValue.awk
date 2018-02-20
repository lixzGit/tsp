BEGIN{col=length(nc)>0?(nc+1):1}
{lns=lns $0}
END{nTr=split(lns,trs,"<tr[^>]*>")
for(iTr=1;iTr<=nTr;iTr++){
 nTd=split(trs[iTr],tds,"<td[^>]*>")
 for(iTd=2;iTd<=nTd;iTd++){
  if(iTd==col) continue
  if(match(tds[iTd],".*</td>")){
   printf "%s%s",substr(tds[iTd],RSTART,RLENGTH-5),(iTd==nTd?"\n":" ")
  } else {
   exit
  }
 }
}}