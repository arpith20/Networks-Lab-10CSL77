#Create a new Simulation Instance
set ns [new Simulator]

#Turn on the Trace and the animation files
set f [open out.tr w]
set nf [open out.nam w]

$ns trace-all $f
$ns namtrace-all $nf

#Define the finish procedure to perform at the end of the simulation
proc finish {} {
	global f nf ns
	$ns flush-trace
	close $f
	close $nf 
	exec nam out.nam &
	exec awk -f 4.awk out.tr &
	exit 0
}

#Create the nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]

#create the lan topology
$ns make-lan "$n0 $n1 $n2 $n3 $n4" 1Mb 10ms LL Queue/DropTail Mac/802_3
$ns make-lan "$n5 $n6 $n7 $n8 $n9" 1Mb 10ms LL Queue/DropTail Mac/802_3
$ns duplex-link $n2 $n6 1Mb 30ms DropTail

Mac/802_3 set datarate_ 10Mb

#Create a UDP Agent and attach to the node n1
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

#Create a CBR Traffic source and attach to the UDP Agent
set cbr0 [new Application/Traffic/CBR] 
$cbr0 attach-agent $udp0

$cbr0 set packetSize_ 500
$cbr0 set Interval_ 0.05

#Create a TCP agent and attach to the node n0
set tcp0 [new Agent/TCP]
$ns attach-agent $n3 $tcp0

#Create a FTP source and attach to the TCP agent
set ftp0 [new Application/FTP]
#Attach the FTP source to the TCP Agent
$ftp0 attach-agent $tcp0

$ftp0 set packetSize_ 500

#Create a Null Agent and attach to the node n2
set null0 [new Agent/Null]
$ns attach-agent $n7 $null0

#Create a TCPSink agent and attach to the node n2
set sink0 [new Agent/TCPSink]
$ns attach-agent $n8 $sink0

#Connect
$ns connect $udp0 $null0
$ns connect $tcp0 $sink0

set err [new ErrorModel]
$ns lossmodel $err $n2 $n6

$err set rate_ 0.1

$ns at 1.0 "$cbr0 start"
$ns at 1.0 "$ftp0 start"

$ns at 9.0 "$cbr0 stop"
$ns at 9.0 "$ftp0 stop"

$ns at 10.0 "finish"

$ns run
