BEGIN{
	PacketRcvd=0;
	Throughput=0.0;
}
{
	if(($1=="r")&&($3=="_3_")&&($4=="AGT")&&($7=="tcp")&&($8>1000))
	{
		PacketRcvd++;
	}
}
END {
	Throughput=((PacketRcvd*1000*8)/(95.0*1000000));
	printf "the throughput is:%f\n",Throughput;
}
