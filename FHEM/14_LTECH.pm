package main;

use strict;
use warnings;

# werden benötigt, aber im Programm noch extra abgetestet 
#use Digest::CRC qw(crc);
#use Math::Trig;

sub LTECH_Initialize($) {
	my ($hash) = @_;

	$hash->{Match}     = "^P97#[A-Fa-f0-9]+";   
	$hash->{DefFn}     = "LTECH_Define";
	$hash->{UndefFn}   = "LTECH_Undef";
	$hash->{ParseFn}   = "LTECH_Parse";
	$hash->{AttrFn}	   = "LTECH_Attr";
	$hash->{AttrList}  = "IODev do_not_notify:1,0 ignore:0,1 showtime:1,0 "
                       ."Brightness: 0,5,10,15,20,25,30,35,40,45,50,55,60.65,70,75,80,85,90,95,100"
                       ."$readingFnAttributes ";
	$hash->{AutoCreate} =
		{ "LTECH.*" => { ATTR => "event-min-interval:.*:300 event-on-change-reading:.* verbose:5" , FILTER => "%NAME",  autocreateThreshold => "2:180",  GPLOT => " "} };
}



#####################################
sub
LTECH_Define($$)
{
  my ($hash, $def) = @_;
  my @a = split("[ \t][ \t]*", $def);

	my $a = int(@a);
	#print "a0 = $a[0]";
  return "wrong syntax: define <name> LTECH <code>".int(@a)
		if(int(@a) < 3);

  $hash->{CODE}    = $a[2];
  $hash->{lastMSG} =  "";

  my $name= $hash->{NAME};

  $modules{LTECH}{defptr}{$a[2]} = $hash;
  #$hash->{STATE} = "Defined";

  #AssignIoPort($hash);
  return undef;
}

#####################################
sub
LTECH_Undef($$)
{
  my ($hash, $name) = @_;
  delete($modules{LTECH}{defptr}{$hash->{CODE}}) if($hash && $hash->{CODE});
  return undef;
}

#####################################
sub
LTECH_Parse($$)
{
  my ($iohash,$msg) = @_;
	my (undef ,$rawData) = split("#",$msg);

	my $name = $iohash->{NAME};
	my @a = split("", $msg);
	Log3 $iohash, 4, "$name LTECH_Parse: incomming $msg";
  return $name;
}

#####################################
sub
LTECH_Attr(@)
{
  my @a = @_;

  # Make possible to use the same code for different logical devices when they
  # are received through different physical devices.
  return if($a[0] ne "set" || $a[2] ne "IODev");
  my $hash = $defs{$a[1]};
  my $iohash = $defs{$a[3]};
  my $cde = $hash->{CODE};
  delete($modules{LTECH}{defptr}{$cde});
  $modules{LTECH}{defptr}{$iohash->{NAME} . "." . $cde} = $hash;
  return undef;
}

1;

=pod
=item summary    Supports various rf sensors with hideki protocol
=item summary_DE Unterst&uumltzt verschiedenen Funksensoren mit hideki Protokol
=begin html

<a name="LTECH"></a>
<h3>LTECH</h3>
<ul>
  The LTECH module is a module for decoding LTECH LED controller remote controls, which use the LTECH protocol.
  <br><br>
</ul>

=end html

=begin html_DE

<a name="LTECH"></a>
<h3>LTECH</h3>
<ul>
  Das LTECH module dekodiert empfangene Nachrichten von LTECH LED Controller Fernbedienungen, welche das LTECH Protokoll verwenden. 
  <br><br>
  

</ul>

=end html_DE
=cut

