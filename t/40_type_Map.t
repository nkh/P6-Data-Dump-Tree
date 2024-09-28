#!/usr/bin/env perl6

use Test ;
plan 4 ;

use Data::Dump::Tree ;

my $d = Data::Dump::Tree.new ;

my $dump = $d.ddt: :get, Map.new('a', 1, 'b', 2), :!color, :width(75) ;

is $dump.lines.elems, 3, '3 lines of dump for Map' or diag $dump ;

$dump = $d.ddt: :get, Map.new('a', (a => True), 'b', (b => False)), :!color, :width(75) ;

is $dump.lines.elems, 3, '3 lines of dump for Map with pair keys' or diag $dump ;

$dump = $d.ddt: :get, Map.new((key => True), (value => True), (key => (innerkey => True)), (value => (innervalue => True))), :!color, :width(75) ;
is $dump.lines.elems, 3, '3 lines of dump for Map with pair keys' or diag $dump ;

$dump = $d.ddt: :get, Map.new((key => (innerkey => True)), (value => (innervalue => True)), (key => (innerkey => (innerinnerkey => True))), (value => (innervalue => (innerinnervalue => True)))), :!color, :width(75) ;
is $dump.lines.elems, 7, '7 lines of dump for Map with pairs with pairs as value' or diag $dump ;
