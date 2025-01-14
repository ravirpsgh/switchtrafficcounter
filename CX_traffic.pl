#use diagnostics;
use Net::Telnet;
use Net::Ping;
use Try::Tiny;
use arybase;
use Cwd;
use Control::CLI
use threads;;
use Data::Dumper;
$| = 1;
my $dir = getcwd;
$dir1=$dir;
$p = Net::Ping->new();
#-----------------------------------------dir----------------------------------------------
use File::Path;
my $directory = "temp";
rmtree([$directory]);
var "temp ver change 1:40"
mkdir $directory;
#-----------------------------------------dir----------------------------------------------
$inputdir= "$dir1".'\input.txt'; #input Directory
$outputdirorg= "$dir1".'\output.txt'; #input Directory

open (READCX, "< $inputdir");


@consdata=<READCX>;
#-----------------------------------------------------threads---------------------------------------------------
my @jobs; 
$nthread=40; #number of threads
@data1 = Dumper(distribute($nthread, [@consdata]));
sub distribute {
    my ($n, $array) = @_;

    my @parts;
    my $i = 0;
    foreach my $elem (@$array) {
        push @{ $parts[$i++ % $n] }, $elem;
    };
    return \@parts;
};
$data1[0]=~ s/\s+//g;
$data1[0]=~ s/\n//g;
$data1[0]=~ s/\$VAR1=\[\[\'//g;
$data1[0]=~ s/','/,,/g;
$data1[0]=~ s/\'\]\]\;//g;

@divdata=split(/\'\]\,\[\'/,$data1[0]);
# print "@divdata\n";		
for($g=0;$g<$nthread;$g++)
{
 push @jobs, threads->create(sub {
 $outputdir= "$dir1".'\temp\tempoutput'."$g".'.txt';
	@dataar=split(/,,/,$divdata[$g]);
	foreach $td(@dataar)
	{
		# print "$td\n";
		main($td);
    }
});

}
$_->join for @jobs; # Wait for everything to finish.	

#-----------------------------------------------------threads---------------------------------------------------	
open(WRITERESULT, "> $outputdirorg");
for($g=0;$g<$nthread;$g++)
{
$outputdir= "$dir1".'\temp\tempoutput'."$g".'.txt';
open(WRITE, "< $outputdir");

@result = <WRITE>;
foreach $result(@result)
{
	open(WRITERESULT, ">> $outputdirorg");
	chomp($result);
	next if $result =~ /^$/;
	print WRITERESULT"$result\n";
	
	
	
}
close(WRITE);
close (READCX);
close (MYFILE);
close (WRITEIN);
unlink $outputdir;
}
rmdir $directory;

sub main()
{	
	my @status_p;
	my @vlanpaav;
	my @cxport;
	my @vlanpaa;
	# ($cx_ip,$cxport)= split(/\//,$_[0]);
	$cx_ip= $_[0];
	chomp($cx_ip);
	chomp($cxport);
	if ($p->ping($cx_ip))
	{
		try
		{
			$telnet = new Net::Telnet ( Timeout=>45, Errmode=>'die');
			$telnet->open("$cx_ip");
			$telnet->waitfor('/Username: $/i');
			$telnet->print("guest");
			$telnet->waitfor('/Password: $/i');
			$telnet->print("guest");
			$telnet->waitfor('/> $/i');
			$telnet->print("enable");
			$telnet->waitfor('/Password: $/i');
			$telnet->print("guest");
			$telnet->waitfor('/# $/i');
			$telnet->print('show interface statistics clear');
			$telnet->waitfor('/# $/i');
			$telnet->print('show interface statistics clear');
			$telnet->waitfor('/# $/i');
			$telnet->print('show interface statistics clear');
			$telnet->waitfor('/# $/i');
			$telnet->print('show interface statistics clear');
			$telnet->waitfor('/# $/i');
			$telnet->print('write');
			$telnet->waitfor('/# $/i');
			# sleep (10);
			my @data=$telnet->cmd("show switch-info\r\r\r\r");
			# $telnet->print('show interface statistics clear\r');
			# $telnet->waitfor('/# $/i');
			# $telnet1->close();
			# print "@data\n";
			$data[8]=~ s/\s+/ /g;
			$data[11] =~ s/\s+/ /g;
			@firmware= split(/ /,$data[11]);
			@vlan=split(" ",$data[8]);
			# print"$vlan[3]\n";
			if($vlan[3] eq 'HES-3109-BAT' )
			{
				for($si=1;$si<=8;$si++)
				{
					# $telnet->print('show interface statistics clear\r');
					# $telnet->waitfor('/# $/i');
					my @datav=$telnet->cmd("show interface statistics traffic $si\r");
					#print "@datav\n";
					foreach $datav1(@datav)
						{
						$datav1=~ s/\s+/ /g;
						#print "@datav1\n";
						if($datav1=~ /Bytes Received/)
						{
						#print "$datav1\n";
						@vlanv=split(/ /,$datav1);
						print "$cx_ip,$si,$vlanv[3]\n";
						#print "$vlanv\n";
						open (OUT, ">> $outputdir");
						print OUT"$cx_ip,$si,$vlanv[3]\n";
						#$vlanv[3]=~s/forwarding/enable/g;
						}
						}
						#if($vlanv[7]=~ /up/)
						{
						#my @mac=$telnet->cmd("show mac address-table interface $si\r\r\r\r\r\r\r\r\r");
						# print "@mac\n";
						foreach $mac1(@mac)
						{
						#$mac1=~ s/\s+/ /g;
						#@mac2=split(/ /,$mac1);
						# print"$mac2[2]\n";
						#if($mac2[3]=~ /[1-8]/)
						{
						#push @cx,$mac2[2];
						# print"$cx_ip,$vlanv[1],$vlanv[3],$vlanv[7],$mac2[2],$vlan[3]\n";
						}
						}
						#my $last_one = pop @cx;
						#print"$cx_ip,$vlanv[1],#$vlanv[3],$vlanv[7],$vlanv[4],$vlanv[5],$last_one,$vlan[3],$firmware[4]\n";
						#open (OUT, ">> $outputdir");
						#print OUT"$cx_ip,$vlanv[1],#$vlanv[3],$vlanv[7],$vlanv[4],$vlanv[5],$last_one,$vlan[3],$firmware[4]\n";
						}
					#else
						{
						#print"$cx_ip,$vlanv[1],#$vlanv[3],$vlanv[7],$vlanv[4],$vlanv[5],,$vlan[3],$firmware[4]\n";
						#open (OUT, ">> $outputdir");
						#print OUT"$cx_ip,$vlanv[1],#$vlanv[3],$vlanv[7],$vlanv[4],$vlanv[5],,$vlan[3],$firmware[4]\n";
						}
				}
			}
			elsif($vlan[3] eq 'HES-3109-BAT-ACX' )
			{
			for($s=1;$s<=8;$s++)
				{
					# $telnet->print('show interface statistics clear\r');
					#$telnet->waitfor('/# $/i');
					my @datav=$telnet->cmd("show interface statistics traffic $s\r\r\r\r");
					#print "@datav\n";
					foreach $datav1(@datav)
						{
						$datav1=~ s/\s+/ /g;
						#print "@datav1\n";
						if($datav1=~ /Bytes Received/)
						{
						# print "$datav1\n";
						@vlanv=split(/ /,$datav1);
						print "$cx_ip,$s,$vlanv[3]\n";
						open (OUT, ">> $outputdir");
						print OUT"$cx_ip,$s,$vlanv[3]\n";
						#$vlanv[3]=~s/forwarding/enable/g;
						}
						}
						#if($vlanv[7]=~ /up/)
						{
						#my @mac=$telnet->cmd("show mac address-table int $s\r\r\r\r\r\r\r");
						# print "@mac\n";
						#foreach $mac1(@mac)
						{
						#$mac1=~ s/\s+/ /g;
						#@mac2=split(/ /,$mac1);
						#if($mac2[4]=~ /[1-8]/)  
						{
						#push @cx,$mac2[2];
						#push @cx1,$mac2[3];
						}
						}
						#my $last_one = pop @cx;
						#my $last_one1 = pop @cx1;
						#print"$cx_ip,$vlanv[1],$vlanv[3],$vlanv[7],$vlanv[4],$vlanv[5],$last_one1,$vlan[3],$firmware[4]\n";
						#open (OUT, ">> $outputdir");
						#print OUT"$cx_ip,$vlanv[1],$vlanv[3],$vlanv[7],$vlanv[4],$vlanv[5],$last_one1,$vlan[3],$firmware[4]\n";
						}
						#else
						{
						#print"$cx_ip,$vlanv[1],$vlanv[3],$vlanv[7],$vlanv[4],$vlanv[5],,$vlan[3],$firmware[4]\n";
						#open (OUT, ">> $outputdir");
						#print OUT"$cx_ip,$vlanv[1],$vlanv[3],$vlanv[7],$vlanv[4],$vlanv[5],,$vlan[3],$firmware[4]\n";
						}
						
				}
			}
		}
			
			# for($g=0;$g<=7;$g++)
				# {
				# print "$cx_ip,@cxport[$g],@vlanpaa[$g],@vlanpaav[$g],@status_p[$g]\n";
				# open (OUT, ">> $outputdir");
				# print OUT "$cx_ip,@cxport[$g],@vlanpaa[$g],@vlanpaav[$g],@status_p[$g]\n";
				# }
		
		catch
		{
			print "$cx_ip,chck manually\n";
			open (OUT, ">> $outputdir");
			print OUT"$cx_ip,$cxport,chck manually\n";
		}
	}
	else
	{
		print "$cx_ip,not pinging\n";
		open (OUT, ">> $outputdir");
		print OUT"$cx_ip,$cxport,not pinging\n";
	}
}
