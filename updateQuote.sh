jobTime=$(date "+%k%M")
jobDate=$(date "+%Y%m%d")

cd ~/tsp || exit 1
bin/grabIPOCode.sh > IPO
bin/grab.sh < IPO
bin/edtComName.sh < IPO
bin/edtHolderNum.sh < IPO
bin/updCapChg.sh "$jobDate"
bin/updIndex.sh sh000001
bin/updSampleNufmDfcfwCom.sh < codeTbl.txt
echo "工作完成"