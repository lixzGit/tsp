grep $1 tsp/dat/Report/$2 | tr ' ' '\n' | awk '{if(NR==1) next;if($1>5) print NR-1,$1}'