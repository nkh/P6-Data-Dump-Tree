#!/usr/bin/env perl6

use Test ;
plan 16 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
#use Data::Dump::Tree::DescribeBaseObjects ;

my $d = Data::Dump::Tree.new ;

my $dump = $d.get_dump(Seq(1, 2, 'x')) ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'.Seq'/, 'class name' or diag $dump ;

$dump = $d.get_dump(1...*) ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'.Seq(*)'/, 'class name' or diag $dump ;

$dump = $d.get_dump(1...10_000) ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'.Seq'/, 'class name' or diag $dump ;

$d does DDTR::ConsumeSeq ;
$dump = $d.get_dump(1...10_000) ;
is $dump.lines.elems, 12, '12 line' or diag $dump ;
like $dump, /'.Seq'/, 'class name' or diag $dump ;

$dump = $d.get_dump(1...3) ;
is $dump.lines.elems, 4, '4 line' or diag $dump ;
like $dump, /'.Seq'/, 'class name' or diag $dump ;

$dump = $d.get_dump(1...*) ;
is $dump.lines.elems, 1, '1 line, lazy not consumed' or diag $dump ;
like $dump, /'.Seq(*)'/, 'class name' or diag $dump ;

$d.consume_seq<consume_lazy> = True ;
$dump = $d.get_dump(1...*) ;
is $dump.lines.elems, 12, '12 line' or diag $dump ;
like $dump, /'.Seq(*)'/, 'class name' or diag $dump ;

$d.consume_seq<vertical> = False ;
$dump = $d.get_dump((1...*), :width<80>) ;
is $dump.lines.elems, 7, '7 line' or diag $dump ;
like $dump, /'.Seq(*)'/, 'class name' or diag $dump ;


