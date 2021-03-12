#!/usr/bin/perl

use strict;
use warnings;

my @regexes = map { qr/^$_/ } @ARGV;
my $last_regex = 0;
my $last_line = '';

while (<STDIN>) {
	my $matched = 0;
	chomp;

	for my $regex (@regexes) {
		next unless $_ =~ $regex;

		if ($last_regex == $regex) {
			die "duplicate lines: '$_'\n" unless $last_line ne $_;
			die "unsorted lines: '$last_line' before '$_'\n" unless $last_line lt $_;
		}

		$matched = 1;
		$last_regex = $regex;
		$last_line = $_;
	}

	unless ($matched) {
		$last_regex = 0;
		$last_line = '';
	}
}
