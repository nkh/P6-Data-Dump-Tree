#!/usr/bin/env perl6

use Test ;
use Data::Dump::Tree ;

plan 5 ;

my $d = Data::Dump::Tree.new() ;

class C  { has $.in_object = 'in_object' }

my $dump = $d.get_dump( C.new, color => False) ;
like $dump,  /in_object/, 'default dumper' ;

$d does role { multi method get_elements (C $c) { [('Role{1}', '', 1),] }}
$dump = $d.get_dump( C.new , color => False) ;

like $dump, /Role\{1\}/, 'first role' ;
is $dump.lines.elems, 2, '2 lines dump' or diag $dump ;

$d does role { multi method get_elements (C $c) { [('Role{2}', '', 2),] }}
$dump = $d.get_dump( C.new, color => False) ;

like $dump, /Role\{2\}/, 'second role' ;
is $dump.lines.elems, 2, '2 lines dump' or diag $dump ;



