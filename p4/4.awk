#!/usr/bin/awk -f

BEGIN {
	cbrPktReceived=0;
	totalPktReceived=0;
	ftpPktReceived=0;
	throughput=0.0;
}
{
	src=$3;
	des=$4;
	type=$5;
	event=$1;
	if((event=="+") && (src=="2") && (des=="6") && (type=="cbr"))
		cbrPktReceived++;
	if(($1=="+") && ($3=="2") && ($4=="6") && (type=="tcp"))
		ftpPktReceived++;
	totalPktReceived=cbrPktReceived+ftpPktReceived;
}
END {
	throughput=((totalPktReceived*500*8)/(8*1000000));
	printf "the throughput is:%f\n",throughput;
	printf "the throughput is:%d\n",cbrPktReceived;
	printf "the throughput is:%d\n",ftpPktReceived;
}
