function getstockmarket(StockCode) {
	var i = StockCode.substring(0, 1);
	var j = StockCode.substring(0, 3);
	if (i == "5" || i == "6" || i == "9") {
		return "1";
	} else {
		if (j == "009" || j == "126" || j == "110") {
			return "1";
		} else {
			return "2";
		}
	}
}

var inStr=readline(),
	input=inStr.split(" ");
var host="hqdigi2.eastmoney.com",
	code=input[0],
	pageNo=input[1],
	marketNo=getstockmarket(code);
var userAgentHdr="-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:49.0) Gecko/20100101 Firefox/49.0'",
	refererHdr="-H 'Referer: http://quote.eastmoney.com/f1.html?code="+code+"&market="+marketNo+"'",
	hostHdr="-H 'Host: "+host+"'",
	connHdr="-H 'Connection: keep-alive'",
	acceptLangHdr="-H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3'",
	acceptEncHdr="-H 'Accept-Encoding: gzip, deflate'",
	acceptHdr="-H 'Accept: */*'",
	parameter="Type=OB&stk="+code+marketNo+"&Reference=xml&limit=0&page="+pageNo+"&rt="+Math.random(),
	urlStr="http://"+host+"/EM_Quote2010NumericApplication/CompatiblePage.aspx";

print("'"+urlStr+"?"+parameter+"' "+acceptHdr+" "+acceptEncHdr+" "+acceptLangHdr+" "+connHdr+" "+hostHdr+" "+refererHdr+" "+userAgentHdr);