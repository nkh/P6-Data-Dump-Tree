#!/usr/bin/env perl6

use Test ;
plan 20 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;

my $d = Data::Dump::Tree.new: :!color ;

my $dump = $d.get_dump: Seq(1, 2, 'x') ;
is $dump.lines.elems, 4, '4 line' or diag $dump ;
like $dump, /'.Seq'/, 'class name' or diag $dump ;

$dump = $d.get_dump: (1...*) ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'.Seq(*)'/, 'class name' or diag $dump ;

$dump = $d.get_dump: (1...10_000) ;
is $dump.lines.elems, 12, '12 line' or diag $dump ;
like $dump, /'.Seq'/, 'class name' or diag $dump ;

$dump = $d.get_dump: (1...3) ;
is $dump.lines.elems, 4, '4 line' or diag $dump ;
like $dump, /'.Seq'/, 'class name' or diag $dump ;

$d.consume_seq<consume_lazy> = True ;
$dump = $d.get_dump: (1...*) ;
is $dump.lines.elems, 12, '12 line' or diag $dump ;
like $dump, /'.Seq(*)'/, 'class name' or diag $dump ;

$d.consume_seq<vertical> = False ;
$dump = $d.get_dump: (1...*), :width(80) ;
is $dump.lines.elems, 6, '6 line' or diag $dump ;
like $dump, /'.Seq(*)'/, 'class name' or diag $dump ;

$d.consume_seq<vertical> = False ;
$dump = $d.get_dump: (1...3), :width(80) ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'(1, 2, 3).Seq'/, 'dump and class name' or diag $dump ;

$d.consume_seq<vertical> = False ;
$dump = $d.get_dump: (1...50), :width(80) ;
is $dump.lines.elems, 4, '4 line' or diag $dump ;
like $dump, /'.Seq'/, 'class name' or diag $dump ;

$d.consume_seq<vertical> = False ;
$dump = $d.get_dump: (1...120), :width(80) ;
is $dump.lines.elems, 6, '6 line' or diag $dump ;
like $dump, /'.Seq'/, 'class name' or diag $dump ;
like $dump, /'100'/, '100 elements' or diag $dump ;
unlike $dump, /'101'/, 'limited to 100 elements' or diag $dump ;


