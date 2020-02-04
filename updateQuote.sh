jobTime=$(date "+%k%M")
xdDate=${1:-$(date "+%Y-%m-%d")}
[[ -z $(grep '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' <<< "$xdDate") ]] && {
	echo "xdDate pattern: YYYY-mm-dd"
	exit 1
}
jobDate=$(sed -n 's/-//gp' <<< $xdDate)
xdFile="../Downloads/xdData"
cd ~/tsp || exit 1
[[ -f "$xdFile" ]] && {
	read -a cols < "$xdFile"
	if [[ ${cols[12]} == $xdDate ]]; then 
		bin/edtWeight.sh "$jobDate" < "$xdFile"
		rm -f "$xdFile"
	else
		echo "xdDate not equal"
	fi
}
bin/phantomjs bin/grabIPOCode.js ${xdDate: 5:5} > IPO
bin/insCodeTbl.sh < IPO
bin/updComName.sh < IPO
#bin/edtHolderNum.sh < IPO
bin/phantomjs bin/grabBasic10jqkaComCn.js equity < IPO | bin/updCapChgBasic10jqkaComCnEquity.sh
bin/updIndex.sh sh000001
bin/updSampleNufmDfcfwCom.sh "$jobDate" < codeTbl.txt
bin/filterCode.sh < codeTbl.txt | bin/phantomjs bin/grabOrderRatioHqSinajsCn.js > OrderRatio
#bin/evalScore.sh -n 60 -d "$jobDate" < codeTbl.txt > "dat/Report/$jobDate"
#awk -f bin/selectActive.awk "dat/Report/$jobDate" > "../$jobDate"
echo "工作完成"
