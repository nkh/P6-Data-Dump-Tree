#!/usr/bin/env perl6

use Test ;
plan 4 ;

use Data::Dump::Tree ;

my $d = Data::Dump::Tree.new ;

my $dump = $d.get_dump(1 => 'a', :!color) ;

like $dump.lines[0], /'(1, a).Pair'/, 'class name' or diag $dump ;
is($dump.lines.elems, 1, '1 dump lines') or diag $dump ;


$dump = $d.get_dump((a => (< a >,)), :!color) ;
like $dump.lines[0], /^'.Pair'/, 'class name' or diag $dump ;
is($dump.lines.elems, 3, '3 dump lines') or diag $dump ;

