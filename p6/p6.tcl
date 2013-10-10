if {$argc != 1} {
	error "Command: ns <ScriptName.tcl> <Number_of_Nodes>"
	exit 0
}

#Define the simulation options
set val(chan)       Channel/WirelessChannel 
set val(prop)       Propagation/TwoRayGround 
set val(ant)        Antenna/OmniAntenna 
set val(ll)         LL 
set val(ifq)        Queue/DropTail/PriQueue 
set val(ifqlen)     50 
set val(netif)      Phy/WirelessPhy 
set val(mac)        Mac/802_11 
set val(rp)         AODV
set val(nn)         [lindex $argv 0]
set opt(x)  	    750
set opt(y)          750
set val(stop)       100


set ns [new Simulator]
set trfd [open Wireless.tr w]
set namfd [open Wireless.nam w]

$ns trace-all $trfd
$ns namtrace-all-wireless $namfd $opt(x) $opt(y)

set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
set god_ [create-god $val(nn)]

#Configure the nodes
$ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-channelType $val(chan) \
		-propType $val(prop) \
		-antType $val(ant) \
		-ifqLen $val(ifqlen) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
                -movementTrace OFF		

for {set i 0} {$i < $val(nn)} {incr i} {
	set n($i) [$ns node]
}

#Randomly placing the nodes
for {set i 0} {$i < $val(nn)} {incr i} {
	set XX [expr rand()*750]
	set YY [expr rand()*750]
	$n($i) set X_ $XX
	$n($i) set Y_ $YY 
}

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns initial_node_pos $n($i) 30
}

set tcp1 [new Agent/TCP]
$ns attach-agent $n(1) $tcp1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n(3) $sink1

$ns connect $tcp1 $sink1

$ns at 0.0 "destination"
proc destination {} {
	global ns val n
	set now [$ns now]
	set time 5.0
	for {set i 0} {$i < $val(nn)} {incr i} {
		set XX [expr rand()*750]
		set YY [expr rand()*750]
		$ns at [expr $now + $time] "$n($i) setdest $XX $YY 20.0"
	}
	$ns at [expr $now + $time] "destination"
}

#tell nodes when the simulation ends
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at $val(stop) "$n($i) reset"
}

$ns at 5.0 "$ftp1 start"

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"

proc stop {} {
	global ns trfd namfd
	close $trfd
	close $namfd
	exec nam Wireless.nam &
	exec awk -f 6.awk Wireless.tr &
	exit 0
}

$ns run


