awk -v tks='股票代码 送股 转增股 派息 除权除息日' 'BEGIN{ntks=split(tks,atks);for(i=1;i<=ntks;i++) f[i]=0}
 {for(i=1;i<=ntks;i++) if(index($0,atks[i])!=0) {f[i]=FNR;break}}
 END{if(ntks>0) for(i=1;i<=ntks;i++) printf "%d ",f[i]}' 