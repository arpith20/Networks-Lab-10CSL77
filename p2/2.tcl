set ns [new Simulator]
set f [open out.tr w]
set nf [open out.nam w]

$ns trace-all $f
$ns namtrace-all $nf
$ns color 1 "Blue"
$ns color 2 "Red"

proc finish {} {
	global ns f nf
	$ns flush-trace
	close $f 
	close $nf
	exec nam out.nam &
	exec awk -f 2.awk out.tr &
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 2Mb 10ms DropTail 
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2.75Mb 20ms DropTail

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

$ns queue-limit $n2 $n3 50

set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0
$udp0 set class_ 2

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 1000
$cbr0 set interval_ 0.005


set null0 [new Agent/Null]
$ns attach-agent $n3 $null0
$ns connect $udp0 $null0

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
$tcp0 set class_ 1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
$ns connect $tcp0 $sink

$ns at 0.1 "$cbr0 start"
$ns at 1.0 "$ftp0 start"
$ns at 4.0 "$ftp0 stop"
$ns at 4.5 "$cbr0 stop"

$ns at 5.0 "finish"
$ns run
