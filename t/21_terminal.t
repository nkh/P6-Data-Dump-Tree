#!/usr/bin/env perl6

use Test ;
plan 4 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::DescribeBaseObjects ;

my $d = Data::Dump::Tree.new does DDTR::AsciiGlyphs ;

class C { has Any $!class_variable  }

my $dump = $d.get_dump: C.new, :!color ;

like $dump, /class_variable/, 'default dump' ;
is $dump.lines.elems, 2, '2 lines dump' ;


$d does role { multi method get_header (C $l) { ('value_final', '.type_final', DDT_FINAL) } }

$dump = $d.get_dump: C.new, :!color ;

like $dump, /value_final\.type_final/, 'DDT_FINAL' ;
is $dump.lines.elems, 1, '1 line dump' ;

