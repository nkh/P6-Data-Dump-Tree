#!/usr/bin/env perl6

use Test ;
plan 8 ;

use Data::Dump::Tree;

my $dump = dump '1234567890' x 6, Nil, {color => 0} ;
is $dump.lines.elems, 1, '1 line, default width setting' or diag $dump ;

$dump = dump '1234567890' x 8, Nil, {color => 0} ;
is $dump.lines.elems, 4, '4 lines, default width setting' or diag $dump ;

$dump = dump '1234567890' x 8, Nil, {color => 0, width => 20} ;
is $dump.lines.elems, 7, '7 lines, width set to 20' or diag $dump ;
is all($dump.lines>>.chars) <= 20,  True, 'all lines under 20 chars' or do { diag $dump.lines>>.chars ;diag $dump ; }

$dump = dump ['1234567890' x 8], Nil, {color => 0, width => 20} ;
is $dump.lines.elems, 9, '9 lines, width set to 20' or diag $dump ;
is all($dump.lines>>.chars) <= 20,  True, 'all lines under 20 chars' or do { diag $dump.lines>>.chars ;diag $dump ; }

$dump = dump '1234567890' x 5, 'title' x 5, {color => 0, width => 20} ;
is $dump.lines.elems, 6, '6 lines, width set to 20' or diag $dump ;
is all($dump.lines>>.chars) <= 70,  True, 'all lines under 70 chars' or do { diag $dump.lines>>.chars ;diag $dump ; }

