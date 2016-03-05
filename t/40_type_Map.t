#!/usr/bin/env perl6

use Test ;
plan 1 ;

use Data::Dump::Tree ;

my $d = Data::Dump::Tree.new ;

my $dump = $d.get_dump(
		Map.new('a', 1, 'b', 2),
		width => 75,
		);

is $dump.lines.elems, 3, '3 lines of dump for Map' ;
