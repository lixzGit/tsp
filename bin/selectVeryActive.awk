{gt5=0;nval=split($0,vals);for(i=2;i<=nval;i++) if(vals[i]>5) gt5++; if(gt5==12) print $1}
