BEGIN{low=0;high=0;sum=0}
{
 if(FNR>o && FNR<150+o) {
  val=$8/$7*1000000;sum+=$7; val>=1.5 ? ++high : val>0.499 ? ++low : 0;
 } else if (FNR==150+o) {
  exit
 }
}
END{print FILENAME,low,high,sum/149/10000}