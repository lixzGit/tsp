var PEAK = {
    BIZ: {}
},location = {
	protocol: "http:"
},formatDate = function(e) {
	for (var t = e.split("-"), n = 0; n < t.length; n++) {
		var a = t[n];
		1 == a.length && (t[n] = "0" + a)
	}
	return t.join("")
};
PEAK.BIZ.HOST = location.protocol + "//q.stock.sohu.com", 
PEAK.BIZ.HqServer = location.protocol + "//hq.stock.sohu.com", 
PEAK.BIZ.cookieDomain = "stock.sohu.com", 
PEAK.BIZ.cookieExpires = 8760, 
PEAK.BIZ.MyStockNumber = 60, 
PEAK.BIZ.MyStockCookieName = "BIZ_MyStock", 
PEAK.BIZ.serverTime = new Date, 
PEAK.BIZ.threeIndex = location.protocol + "//hq.stock.sohu.com/zs/zs-1.html", 
PEAK.getDataChannel = function() {
    return "object" == typeof __dataChannel && __dataChannel instanceof jaw.commet ? __dataChannel : (__dataChannel = new jaw.commet, __dataChannel.reusage = !0, __dataChannel)
};

historyHqSearch = function(e) {
	for (var t = biz_Code, n = e.sd, a = e.ed, r = n.value.trim(), i = a.value.trim(), o = "", s = e.t, d = 0; d < s.length; d++) {
		var l = s[d];
		if (l.checked) {
			o = l.value;
			break
		}
	}
	if (r.isEmpty())
		return alert("请输入开始日期");
	if (i.isEmpty())
		return alert("请输入结束日期");
	var c = /^(\d{4})-(\d{1,2})-(\d{1,2})$/;
	if (!c.test(r))
		return n.focus(), alert("开始日期格式不正确");
	if (!c.test(i))
		return a.focus(), alert("结束日期格式不正确");
	var p = new Date(r.replace(/-/g, "/")),
	u = new Date(i.replace(/-/g, "/"));
	if (p > u)
		return alert("开始日期不能比结束日期大");
	r = formatDate(r), i = formatDate(i);
	var m = PEAK.BIZ.HOST + "/hisHq?code=" + t + "&start=" + r + "&end=" + i + "&stat=1&order=D&period=" + o + "&callback=historySearchHandler&rt=jsonp&r=" + Math.random();
	jaw.evalScript({
		url: m
	})
}

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