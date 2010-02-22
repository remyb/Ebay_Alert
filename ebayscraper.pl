#! /usr/bin/perl -w

# Ebay Alert!  by Remy Baumgarten
# Parses Ebay Pages for Matching Bids and sends an email/text
# of new auction items.  
# by Remy Baumgarten

my $email_from = "xxxxx";		# Send From: example: bob\@gmail.com
my $email_to = "xxxxxxx";	# Send To:
my $email_title = "Ebay Alert!";			# Text Title
my $smtp_user = "xxxxxx";     				# SMTP Username
my $smtp_pass = "xxxxxx";  				# SMTP Password
my $smtp_host = "xxxxxx";			# SMTP Host
my $sleep_time = 300;						# Sleep Time in Seconds
my $max_time_left = 30;						# Default Auction Max

# Do not edit the code beyond this point
# ======================================
use strict;
use warnings;
use LWP::Simple;

my $debug = 0;
my @items;
my $dollars = 0.00;

# parses ebay for matching results
sub parser {
	my ($section, $items) = @_; 
	my @text_message = ();
	foreach my $line (@$section) {
		my %item = ();
		if ($line =~ m/<div class=\"ttl\"><a href=\"([^"]+)"/) {$item{'url'} = $1;}
		if ($line =~ m/r=\"\d+\">([^<]+)<\/a>/){$item{'desc'} = $1;}	
		if ($line =~ m/\$(\d+\.\d{2})/) { $item{'price'} = $1;}
		if ($line =~ m/rt\">(\d+[dhms])(&#160;)?(\d*[dhms]?)/ ) {$item{'time'} = "$1$3";}
		if ($line =~ m/([\d])\sBids/){$item{'bids'} = $1;} 
		if (keys %item ge 5 and $item{'price'} < $dollars and convert_time($item{'time'})) {
			if (grep $_->{'url'} ne $item{'url'}, @items) { 
				push(@items,\%item);
				my $text = $item{'desc'}.", ".$item{'bids'}.", ".$item{'price'}.", ".$item{'time'}.", ".$item{'url'}."\n";
				push(@text_message, $text)
			}
		}
	} return @text_message;
}

# returns true if time is under max time left
sub convert_time {
	my $time = shift;
	(my $hours, my $days, my $minutes) = (0,0,0);
	if($time =~ m/(\d+)h/) { $hours = $1*60;}
	if($time =~ m/(\d+)d/) { $days = $1*24*60;}
	if($time =~ m/(\d+)m/) { $minutes = $1; }
	return 1 if ($hours + $days + $minutes) <= $max_time_left;
	return 0;
}

# calls sendEmail.pl to send an email/text
sub text_send {
	my $message = "";
	foreach(@_) { print "[*] New Find! ". $_."\n"; $message = $message . $_."\n";}
	$message =~ s/[\"]/in/g;
	my $command = "perl sendEmail.pl -f '$email_from' -t '$email_to' -u '$email_title'  -s '$smtp_host'  -xu '$smtp_user' -xp '$smtp_pass' -m '$message'\n";
	my $result = system($command);
	print "[*] Email Command Sent: ".$result if $debug;
}

# main program section
if ($#ARGV+1 < 2 or $#ARGV > 3) { die("Error: You must supply 2 or 3 args\nUsage: perl program.pl search dollars [time] \nExample: perl program.pl macbook+pro+-bag 300 45\n");}
my $search_term = $ARGV[0];
$dollars = $ARGV[1];
if ($#ARGV+1 eq 3) { $max_time_left = $ARGV[2];}
# main loop
while(1) {
	print "Scanning Ebay for New Items matching $search_term...\n";
	my $page = get("http://shop.ebay.com/i.html?LH_Auction=1&_sop=1&_nkw=$search_term");
	my @section = split(/<\/table>/, $page);
	my @new_items = parser(\@section,\@items);
	text_send(@new_items) if @new_items ge 1;
	print "Nothing new...\n" if @new_items eq 0 and $debug;
	sleep($sleep_time);
}
