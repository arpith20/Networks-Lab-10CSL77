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
	exec awk -f 1.awk out.tr &
	exit 0
}

#Create the nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]


#Label the nodes
$n0 label "TCP Source"
$n1 label "UDP Source"
$n2 label "Sink"

#Set the color 
$ns color 1 red
$ns color 2 blue

#Create the Topology
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 1.75Mb 20ms DropTail

#Attach a Queue of size N Packets between the nodes n1 n2
$ns queue-limit $n1 $n2 10

#Make the Link Orientation
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right

#Create a UDP Agent and attach to the node n1
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

#Create a CBR Traffic source and attach to the UDP Agent
set cbr0 [new Application/Traffic/CBR] 
$cbr0 attach-agent $udp0

#Specify the Packet Size and interval
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005 

#Create a Null Agent and attach to the node n2
set null0 [new Agent/Null]
$ns attach-agent $n2 $null0

#Connect the CBR Traffic source to the Null agent
$ns connect $udp0 $null0

#Create a TCP agent and attach to the node n0
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

#Create a FTP source and attach to the TCP agent
set ftp0 [new Application/FTP]

#Attach the FTP source to the TCP Agent
$ftp0 attach-agent $tcp0

#Create a TCPSink agent and attach to the node n2
set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink

#Specify the Max file Size in Bytes
$ftp0 set maxPkts_ 1000

#Connect the TCP Agent with the TCPSink
$ns connect $tcp0 $sink

$udp0 set class_ 1
$tcp0 set class_ 2

#Schedule the Events
$ns at 0.1 "$cbr0 start"
$ns at 1.0 "$ftp0 start"
$ns at 4.0 "$ftp0 stop"
$ns at 4.5 "$cbr0 stop"
$ns at 5.0 "finish"
$ns run

