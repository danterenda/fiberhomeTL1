#!/usr/bin/perl
#use strict;
use warnings;
my $olt= ("10.10.10.10" );

my $tl1srv ="172.16.0.2";
my $slot;
my $pon;
my $onu;

use Net::Telnet ();
$remote = new Net::Telnet (Port => 3337,Timeout => 15,Input_Log => "/var/log/tl1.log", Errmode => 'return',Prompt => '/;/');
$remote->open($tl1srv) ;
$remote->print("LOGIN:::CTAG::UN=admin,PWD=xxxxxx;");
$remote->waitfor('/;/');

@output = $remote->cmd("LST-ONU::OLTID=".$olt.":CTAG::;");
foreach $onu (@output) {
    $onu  =~ s/\s+/_/g;
    if ($onu =~ /FHTT/) {
        @onuid = split(/_/, $onu);
        $slotPort= $onuid[1];
        @slotPortId = split(/-/, $slotPort);
        $slot = $slotPortId[2];
        $pon = $slotPortId[3];
        $onuId =$onuid[2];
        #print $slot."-".$pon.":".$onuId."\n";
        $tl1='MODIFY-WIFISERVICE::OLTID='.$olt.',PONID=NA-NA-'.$slot.'-'.$pon.',ONUIDTYPE=ONU_NUMBER,ONUID='.$onuId.':CTAG::SSID=1,WORKING-FREQUENCY=2.4Ghz,FREQUENCY-BANDWIDTH=40MHZ;';
        print $tl1."\n";
        @salida = $remote->cmd($tl1);
        foreach $salidat (@salida) {
            $salidat =~ s/(\n|\r|\x0d)//g;
            $salidat =~ s/^\s+|\s+$//g;
            if ($salidat =~ /CTAG/) {
                if ($salidat =~ /CTAG COMPLD/) {
                    print "ok\n";
                }else{
                    #print $salidat."\n";
                    print "error:".$slot."-".$pon."-".$onuId."\n";
                }
            }
        }
    }
}
$remote->close;
