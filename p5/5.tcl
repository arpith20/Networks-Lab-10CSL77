#set up a new instance of Simulator
set ns [new Simulator]

#Open the trace file and animation file
set f [open 5.tr w]
set nf [open 5.nam w]

$ns trace-all $f
$ns namtrace-all $nf

#Define the finish Procedure
proc finish {} {
	global ns f nf outFile1 outFile2
	$ns flush-trace
	close $f
	close $nf
	exec nam 5.nam &
	exec xgraph Congestion1.xg -geometry 400x400 &
	exec xgraph Congestion2.xg -geometry 400x400 &
	exit 0
}

$ns color 1 red
$ns color 2 green

#set up the nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

#Label the nodes
$n0 label "TCP  FTP Source"
$n3 label "Sink Destination"
$n5 label "TCP  Telnet Source"
$n7 label "Sink Destination"

#Create the LAN topology
$ns make-lan "$n0 $n1 $n2 $n3 $n4 $n5 $n6 $n7" 10Mb 30ms LL Queue/DropTail Mac/802_3

#Set up the TCP Agents
set tcp1 [new Agent/TCP]
$ns attach-agent $n0 $tcp1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink1
$ns connect $tcp1 $sink1
$tcp1 set class_ 1

#Set up the telnet
set tcp2 [new Agent/TCP]
$ns attach-agent $n5 $tcp2
set telnet1 [new Application/FTP]
$telnet1 attach-agent $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n7 $sink2
$ns connect $tcp2 $sink2
$telnet1 set type_ $sink2
$tcp2 set class_ 2
  
set outFile1 [open Congestion1.xg w]
set outFile2 [open Congestion2.xg w]


puts $outFile1 "TitleText: Congestion Window Plot for TCP1"
puts $outFile1 "XUnitText: SimulationTime(Secs)"
puts $outFile1 "YUnitText: CongestionWindowSize"
puts $outFile2 "TitleText: Congestion Window Plot for TCP2"
puts $outFile2 "XUnitText: SimulationTime(Secs)"
puts $outFile2 "YUnitText: CongestionWindowSize"


#define findWindowSize
proc findWindowSize {tcpSource outFile} {
	global ns
	set now [$ns now]
	set cWindSize [$tcpSource set cwnd_]
	puts $outFile "$now $cWindSize"
	$ns at [expr $now + 0.1] "findWindowSize $tcpSource $outFile"
}

#schedule the events
$ns at 0.0 "findWindowSize $tcp1 $outFile1"
$ns at 0.1 "findWindowSize $tcp2 $outFile2"
$ns at 0.3 "$ftp1 start"
$ns at 0.5 "$telnet1 start"
$ns at 50.0 "$ftp1 stop"
$ns at 50.0 "$telnet1 stop"
$ns at 50.0 "finish"
$ns run
