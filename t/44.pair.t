#!/usr/bin/env perl6

use Test ;
plan 4 ;

use Data::Dump::Tree ;

my $d = Data::Dump::Tree.new ;

my $dump = $d.get_dump(1 => 'a') ;

like $dump.lines[0], /'.Pair'/, 'class name' or diag $dump ;
like $dump.lines[1], /'key'/, 'key' or diag $dump ;
like $dump.lines[2], /'value'/, 'value' or diag $dump ;
is($dump.lines.elems, 3, '3 dump lines') or diag $dump ;

