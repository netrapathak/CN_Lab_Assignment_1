#Netra Pathak_131029
#Computer Networks Lab Submission-1
#Simulating a typical LAN

#Lan simulation
set ns [new Simulator]

#define colour for data flows
$ns color 1 Blue
$ns color 2 Red

#open tracefiles
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1

#open nam file
set namfile [open out.nam w]
$ns namtrace-all $namfile

#define the finish procedure
proc finish {} {
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}

#create 11 nodes
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
set n10 [$ns node]

$n2 color Red
$n2 shape box

#create links between the nodes
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n4 $n5 2Mb 10ms DropTail
$ns duplex-link $n4 $n6 2Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail

set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

#Give node positions
$ns duplex-link-op $n0 $n3 orient right-down
$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient left-up
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n5 $n6 orient down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n10 orient right

#set queue size
$ns queue-limit $n2 $n3 20
$ns queue-limit $n6 $n8 20

#setup TCP connection
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 552
#set FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp 

#setup the first UDP connection
set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp1 $null
$udp1 set fid_ 2

#setup second UDP connection
set udp2 [new Agent/UDP]
$ns attach-agent $n8 $udp2
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp2 $null
$udp2 set fid_ 2

#setup a CBR over UDP connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 0.01Mb
$cbr1 set random_ false

set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 800
$cbr2 set rate_ 0.01Mb
$cbr2 set random_ false

#scheduling the events
$ns at 0.1 "$cbr1 start"
$ns at 1.0 "$ftp start"
$ns at 2.0 "$cbr2 start"
$ns at 75.0 "$ftp stop"
$ns at 100.0 "$cbr1 stop"
$ns at 125.5 "$cbr2 stop"
proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time ] "plotWindow $tcpSource $file"
}
$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 125.0 "finish"
$ns run
















