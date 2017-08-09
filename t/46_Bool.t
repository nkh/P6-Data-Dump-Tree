#!/usr/bin/env perl6

use Test ;
plan 2 ;

use Data::Dump::Tree ;

my $d = Data::Dump::Tree.new ;

my $dump = $d.get_dump: True, :!color ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'.Bool'/, 'class name' or diag $dump ;
