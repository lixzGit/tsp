cd ~/tsp || exit 1

while read code; do
	if [[ -s dat/Capital/$code.txt ]]; then
		capCols=($(head -n 1 dat/Capital/$code.txt))
		if [[ -s dat/Sample/$code.txt ]]; then
			smplCols=($(head -n 1 dat/Sample/$code.txt))
			marketValue=$(echo "scale=2;${smplCols[4]}/1000*${capCols[1]}" | bc)

			(( $(echo "scale=2;$marketValue>199999 && $marketValue<490000 && ${smplCols[4]}> 1990 && ${smplCols[4]}<30000" | bc) )) && {
				printf '%s' $code$'\t'
			}
		else
			echo 'fail to open sample file:' $code >&2
		fi
	else
		echo 'fail to open capital file:' $code >&2
	fi
done
