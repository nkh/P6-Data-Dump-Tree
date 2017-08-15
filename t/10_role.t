#!/usr/bin/env perl6

use Test ;
use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;

plan 5 ;

my $d = Data::Dump::Tree.new does DDTR::AsciiGlyphs ;

class C  { has $.in_object = 'in_object' }

my $dump = $d.ddt: :get, C.new, color => False ;
like $dump,  /in_object/, 'default dumper' ;

$d does role { multi method get_elements (C $c) { [('Role{1}', '', 1),] }}
$dump = $d.ddt: :get, C.new , color => False ;

like $dump, /Role\{1\}/, 'first role' ;
is $dump.lines.elems, 2, '2 lines dump' or diag $dump ;

$d does role { multi method get_elements (C $c) { [('Role{2}', '', 2),] }}
$dump = $d.ddt: :get, C.new, color => False ;

like $dump, /Role\{2\}/, 'second role' ;
is $dump.lines.elems, 2, '2 lines dump' or diag $dump ;



