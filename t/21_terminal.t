#!/usr/bin/env perl6

use Test ;
plan 4 ;

use Data::Dump::Tree ;
my $d = Data::Dump::Tree.new ;

class C { has Any $!class_variable  }

my $dump = $d.dump( C.new ) ;

like $dump, /class_variable/, 'default dump' ;
is $dump.lines.elems, 2, '2 lines dump' ;


$d does role { multi method get_header (C $l) { ('value_final', '.type_final', DDT_FINAL) } }

$dump = $d.dump( C.new, Nil, {color => 0}) ;

like $dump, /value_final\.type_final\n/, 'DDT_FINAL' ;
is $dump.lines.elems, 1, '1 line dump' ;

