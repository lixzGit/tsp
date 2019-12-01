jobTime=$(date "+%k%M")
jobDate=$(date "+%Y%m%d")
xdDate=$(date "+%Y-%m-%d")
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
bin/grabIPOCode.sh > IPO
bin/grab.sh < IPO
bin/edtComName.sh < IPO
bin/edtHolderNum.sh < IPO
bin/updCapChg.sh "$jobDate"
bin/updIndex.sh sh000001
bin/updSampleNufmDfcfwCom.sh < codeTbl.txt
#bin/evalScore.sh -n 60 -d "$jobDate" < codeTbl.txt > "dat/Report/$jobDate"
#awk -f bin/selectActive.awk "dat/Report/$jobDate" > "../$jobDate"
echo "工作完成"
