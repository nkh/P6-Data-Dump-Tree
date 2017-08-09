#!/usr/bin/env perl6

use Test;
plan 2 ;

use Data::Dump::Tree;
use Data::Dump::Tree::DescribeBaseObjects ;

my $d = Data::Dump::Tree.new does DDTR::AsciiGlyphs ;

my $dump = $d.get_dump: X::AdHoc.new(payload => 'text'), :!color ;

like $dump, /X\:\:AdHoc/, 'exception' ;
is $dump.lines.elems, 4, 'exception lines' or diag $dump;


