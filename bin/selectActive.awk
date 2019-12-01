{gt5=0;lt2=0;nval=split($0,vals);for(i=2;i<=nval;i++) if(vals[i]>5) gt5++; else if(vals[i]<2) lt2++; if(gt5>4 && gt5<11 && lt2>11) print $1}
