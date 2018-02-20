cd ~/tsp || exit 1
if (( $# == 1)); then
  bin/grabNufmDfcfwCom.sh | bin/edtNufmDfcfwCom.sh -p 'dat/Sample' -d "$1"
else
  bin/grabNufmDfcfwCom.sh | bin/edtNufmDfcfwCom.sh -p 'dat/Sample'
fi