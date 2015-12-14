#!/usr/bin/env perl6

use Test;
plan 2 ;

use Data::Dump::Tree;

my $dump = get_dump X::AdHoc.new(payload => 'text') ;

like $dump, /X\:\:AdHoc/, 'exception' ;
is $dump.lines.elems, 4, 'exception lines' or diag $dump;


