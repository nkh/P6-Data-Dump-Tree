#!/usr/bin/env perl6

use Test ;
plan 2 ;

use Data::Dump::Tree ;

my $dump = get_dump [ [[[],],], [[],], [] ], max_depth => 3, color => False ;
is  $dump.lines.elems, 8, '8 dump lines' or diag $dump ;
is +($dump ~~ m:g/(max \s depth)/) , 2, '2 over limit' ;

