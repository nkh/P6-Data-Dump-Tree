#!/usr/bin/env perl6

use Test;
use Data::Dump::Tree;

plan 6 ;

my $d_1 = Data::Dump::Tree.new ;

my $dump_1 = $d_1.get_dump("nl\nnl\nnl") ;

is $dump_1.lines.elems, 5, 'multi lines' or diag $dump_1 ;

my $d_2 = Data::Dump::Tree.new does Data::Dump::Tree::Role::PerlString ;
my $dump_2 = $d_2.get_dump("nl\nnl\nnl") ;

is $dump_2.lines.elems, 1, '1 lines' or diag $dump_2 ;


my $d_3 = Data::Dump::Tree.new ;
my $dump_3 = $d_3.get_dump(sub{}) ;

like $dump_3, /sub/, 'default sub dump' ;
is $dump_3.lines.elems, 1, 'default sub lines' or diag get_dump $dump_3;

$d_3 does Data::Dump::Tree::Role::SilentSub ;
$dump_3 = $d_3.get_dump(sub{}) ;

unlike $dump_3, /sub/, 'silent sub dump' ;
is $dump_3.lines.elems, 1, 'silent sub lines' ;

