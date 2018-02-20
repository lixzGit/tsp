{lns=lns $0}
END{nTr=split(lns,trs,"<tr[^>]*>")
for(iTr=1;iTr<=nTr;iTr++){
 nTh=split(trs[iTr],ths,"<th[^>]*>")
 for(iTh=2;iTh<=nTh;iTh++){
  if(match(ths[iTh],".*</th>")){
   printf "%s%s",substr(ths[iTh],RSTART,RLENGTH-5),(iTh==nTh?"\n":" ")
  } else {
   exit
  }
 }
}}