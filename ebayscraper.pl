#! /usr/bin/perl -w

my $debug = 0;	

my $dollars = 20000;

# do not edit the code beyond this point

use strict;
use warnings;
use LWP::Simple;

#my $page = get("http://att.ebay.com/Pages/SearchResults.aspx?emvcc=0&sv=macbook+pro+15+-bag+-case+-skin");
my $page = get("http://shop.ebay.com/i.html?LH_Auction=1&_sop=1&_nkw=macbook+pro+15+-bag+-case+-skin");
my @section = split(/<\/table>/, $page);

my @items;
foreach my $line (@section) {
	#print "LINE: ".$line."\n";
	my %item = ();
	#if ($line =~ m/aid=(\d+)&/ ) {
	if ($line =~ m/<div class=\"ttl\"><a href=\"([^"]+)"/) {
		print "URL: $1\n" if $debug;
		$item{'url'} = $1;
	}
	#if ($line =~ m/bold;\">([^<]+)</) {
	if ($line =~ m/r=\"\d+\">([^<]+)<\/a>/){
		print "Desc: $1\n" if $debug;
		$item{'desc'} = $1;
	}
	
	if ($line =~ m/\$(\d+\.\d{2})/) {
		print "Price: $1\n" if $debug;
		$item{'price'} = $1;
	}
	
	if ($line =~ m/rt\">(\d+[dhms])(&#160;)?(\d*[dhms]?)/ ) {
		print "Time Left: $1 $3\n" if $debug;
		$item{'time'} = "$1 $3";
	}
	
	if ($line =~ m/([\d]\s)Bids/){
		print "Bids: $1\n" if $debug;
		$item{'bids'} = $1;
	} 

	if (keys %item ge 5 and $item{'price'} le $dollars) {
		print "NUMBER KEYS ".(keys %item)."\n"if $debug;
		push(@items,\%item);
		print "=========ADDED===========\n\n" if $debug;
	}
	print "====================\n\n" if $debug;
}

#my $file_no = scalar (@items);
#print $file_no;

print "Items Matched to Dollars:\n================\n";
foreach (@items) {
	print $_->{'url'}."\n";
	print $_->{'desc'}."\n";
	print $_->{'price'}."\n";
	print $_->{'bids'}."\n";
	print $_->{'time'}."\n";
	print "\n===================\n\n";
}
