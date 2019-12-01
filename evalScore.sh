cd ~
for code in $(< tsp/codeTbl.txt); do 
	awk 'BEGIN{low=0;high=0} {if(FNR<150) {val=$8/$7*1000000; val>=1.5 ? ++high : val>0.499 ? ++low : 0;} else exit} END{print FILENAME,low,high}' tsp/dat/Sample/$code.txt; 
done