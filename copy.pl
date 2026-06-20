#!/usr/bin/perl

use strict;
use warnings;
use File::Copy qw(copy);

sub printHelp {
	print "Usage: ./copy.pl -[nvim|vim]\n";
	print "to copy files to the ~/.config/nvim/syntax/ directory, use -nvim\n";
	print "to copy files to the ~/.vim/syntax directory, use -vim\n";
	exit(1);
}


my $vim = 0;

if (defined $ARGV[0]) {
	if ($ARGV[0] eq "-nvim") {
		$vim = 1;
	}
	elsif ($ARGV[0] eq "-vim") {
		$vim = 2;
	}
	else {
		printHelp();
	}
}
else {
	printHelp();
}

my @files = glob("./*.vim");
my $home = glob('~');
my $dir = '';

if ($vim eq 1) {
	$dir = "$home/.config/nvim/syntax";
}
elsif ($vim eq 2) {
	$dir = "$home/.vim/syntax";
}
else {
	exit(1);
}

foreach my $file (@files) {
	copy($file, $dir) or die "Copy failed: $!";
}
