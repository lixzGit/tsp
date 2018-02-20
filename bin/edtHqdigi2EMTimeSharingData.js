eval(readline());
print(jsTimeSharingData.pages);
var data=jsTimeSharingData.data,
	dataNum=data.length-1,
	outStr="",
	i;
for (i=0; i<dataNum; i++) {
	outStr+=data[i]+"\n";
}
outStr+=data[i];
print(outStr);