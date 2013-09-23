#!/usr/bin/awk -f
BEGIN { 
	TCPSend=0;
	CBRSend=0;
	TCPDrop=0;
	CBRDrop=0;
	TCPDropRatio=0.0;
	UDPDropRatio=0.0;
	TCPArrivalRatio=0.0;
	CBRArrivalRatio=0.0;
}
 
{ 
	src=$3;
	des=$4;
	type=$5;
	event=$1;
	if((src=="0")&&(des=="2")&&(event=="+")) { 
		TCPSend++;
	} 
	if((src=="1")&&(des=="2")&&(event=="+")) { 
		CBRSend++; 
	}
	if((event=="d")&&(type=="tcp")) { 
		TCPDrop++; 
	}
	if((event=="d")&&(type=="cbr")) { 
		CBRDrop++; 
	}
}

END {
	printf "\nTCPSend %d", TCPSend;
	printf "\nCBRSend %d", CBRSend;
	printf "\nTCPDrop %d", TCPDrop;
	printf "\nCBRDrop %d", CBRDrop;
	
	TCPArrivalRatio=((TCPSend-TCPDrop)/TCPSend);
	TCPDropRatio=(TCPDrop/TCPSend);
	
	UDPArrivalRatio=((CBRSend-CBRDrop)/CBRSend);
	UDPDropRatio=(CBRDrop/CBRSend);
	
	printf "\nTCPArrivalRatio %f", TCPArrivalRatio;
	printf "\nTCPDropRatio %f", TCPDropRatio;
	printf "\nUDPArrivalRatio %f", UDPArrivalRatio;
	printf "\nUDPDropRatio %f", UDPDropRatio;
}
