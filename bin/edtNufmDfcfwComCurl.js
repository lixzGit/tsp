function s(t) {
	var e = t.substring(0, 1),
		o = t.substring(0, 3);
	return "5" == e || "6" == e || "9" == e ? "01" : "009" == o || "126" == o || "110" == o || "201" == o || "202" == o || "203" == o || "204" == o ? "01" : "02"
}

var inStr=readline();
if (inStr=="") quit();
var codes=inStr.split(" ");
var codesLen=codes.length-1, codeStr="";

for (var i = 0; i < codesLen; i++) {
	if (codes[i]!="") codeStr=codeStr+codes[i]+parseInt(s(codes[i])).toString()+",";
}
if (codes[i]!="") {
	codeStr=codeStr+codes[i]+parseInt(s(codes[i])).toString();
} else if (codeStr.charAt(codeStr.length-1)==",") {
	codeStr=codeStr.substring(0,codeStr.length-1);
}

print("http://nufm.dfcfw.com/EM_Finance2014NumericApplication/JS.aspx?ps=500&token=64a483cbad8b666efa51677820e6b21c&type=CT&cmd="
	  + codeStr
      + "&sty=CTALL&cb=getStockFullInfo&js=([(x)])&"
      + Math.random());