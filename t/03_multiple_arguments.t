#!/usr/bin/env perl6

use Test ;
plan 4 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;

my $d = Data::Dump::Tree.new: :!color ;

my $dump = $d.ddt: :get, :!color ;
is $dump.lines.elems, 0, '0 line' or diag $dump ;
is $dump, '', 'error' or diag $dump ;


$dump = $d.ddt: :get, 1, :!color ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;

$dump = $d.ddt: :get,  1, 2, 3, :!color, 4, 5, (12, 3) ;
is $dump.lines.elems, 8, '8 line' or diag $dump ;

