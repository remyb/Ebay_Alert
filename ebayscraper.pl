#! /usr/bin/perl -w

my $debug = 0;	

my $dollars = 20;

# do not edit the code beyond this point

use strict;
use warnings;
use LWP::Simple;

my $page = get("http://att.ebay.com/Pages/SearchResults.aspx?emvcc=0&sv=macbook+pro+15+-bag+-case+-skin");

my @section = split(/<\/table>/, $page);

my @items;
foreach my $line (@section) {

	my %item = ();
	if ($line =~ m/aid=(\d+)&/ ) {
		print "ID: $1\n" if $debug;
		$item{'id'} = $1;
	}
	if ($line =~ m/bold;\">([^<]+)</) {
		print "Desc: $1\n" if $debug;
		$item{'desc'} = $1;
	}
	
	if ($line =~ m/US\s\$(\d+\.\d{2})/) {
		print "Price: $1\n" if $debug;
		$item{'price'} = $1;
	}
	
	if ($line =~ m/(\d+[dhms]\s?\d*[dhms]?)/ ) {
		print "Time Left: $1\n" if $debug;
		$item{'time'} = $1;
	}
	
	if ($line =~ m/([\d]\s)Bids/){
		print "Bids: $1\n" if $debug;
		$item{'bids'} = $1;
	} 

	if (keys %item ge 5 and $item{'price'} le $dollars) {
		print "NUMBER KEYS ".(keys %item)."\n"if $debug;
		push(@items,\%item);
		print "====================\n\n" if $debug;
	}
	
}

#my $file_no = scalar (@items);
#print $file_no;

print "Items Matched to Dollars:\n";
foreach (@items) {
	print $_->{'id'}."\n";
	print $_->{'desc'}."\n";
	print $_->{'price'}."\n";
}
