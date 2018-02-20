function getStockFullInfo(strArr) {
  for (var i=0, total=strArr.length; i<total; i++) {
  	var elems=strArr[i].split(",");
  	for (var j=0, jTotal=elems.length-1, line=""; j<jTotal; j++) {
  		line+=elems[j].replace(/[\n|\r]/g,"")+" ";
  	}
  	line+=elems[j];
  	print(line);
  }
}
eval(readline());