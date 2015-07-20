set ns [new Simulator]

$ns color 1 Blue 
$ns color 2 Red
$ns color 3 Green

set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1

set namfile [open out.nam w]
$ns namtrace-all $namfile

proc finish {} \
{
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}

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

#$n1 color Red
#$n1 shape box

$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
#$ns simplex-link $n2 $n3 0.3Mb 100ms DropTail
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
#$ns simplex-link $n2 $n1 0.3Mb 100ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail

#$ns simplex-link $n9 $n10 0.3Mb 100ms DropTail
$ns duplex-link $n10 $n9 2Mb 10ms DropTail
#$ns duplex-link $n4 $n5 0.3Mb 100ms DropTail
$ns duplex-link $n5 $n4 2Mb 10ms DropTail
#$ns duplex-link $n6 $n4 0.3Mb 100ms DropTail
$ns duplex-link $n4 $n6 2Mb 10ms DropTail

$ns duplex-link $n5 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n3 $n2 orient down
$ns duplex-link-op $n4 $n5 orient right-down
$ns duplex-link-op $n4 $n6 orient right-up
$ns duplex-link-op $n5 $n6 orient right-down
$ns duplex-link-op $n6 $n7 orient right-down
$ns duplex-link-op $n6 $n8 orient right-up
$ns duplex-link-op $n9 $n10 orient right



#$ns queue-limit $n2 $n3 20
#$ns queue-limit $n2 $n1 20
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 552

set ftp [new Application/FTP]
$ftp attach-agent $tcp

set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp $null
$udp set fid_ 2

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 0.01Mb
$cbr set random_ false

set udp0 [new Agent/UDP]
$ns attach-agent $n8 $udp0
set null0 [new Agent/Null]
$ns attach-agent $n0 $null0
$ns connect $udp0 $null0
$udp set fid_ 3


set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set type_ CBR
$cbr0 set packet_size_ 1000
$cbr0 set rate_ 0.01Mb
$cbr0 set random_ false

$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 0.1 "$cbr0 start"
$ns at 124.0 "$ftp stop"
$ns at 125.5 "$cbr stop"
$ns at 126.5 "$cbr0 stop"
proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
 $ns at [expr $now+$time] "plotWindow $tcpSource $file"
}
$ns at 0.1 "plotWindow $tcp $winfile"
 $ns at 125.0 " finish"
 $ns run 
