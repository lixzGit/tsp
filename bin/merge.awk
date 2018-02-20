BEGIN{if(fl) while(getline <(fl) >0) rs[$1]=$0}
{if(rs[$1]=="" || upd==1) rs[$1]=$0}
END{for(r in rs) print rs[r]}