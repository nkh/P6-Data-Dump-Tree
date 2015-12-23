#!/usr/bin/env perl6

use Test ;
plan 4 ;


use Data::Dump::Tree ;

class MyClass { has Int $.size ; has Str $.name }

my $s =	MyClass.new(:size(6), :name('P6 class')),

my $d = Data::Dump::Tree.new ;
my $dump = get_dump $s, color => False ;

like $dump.lines[0], /'.MyClass'/, 'class name' or diag $dump ;
like $dump.lines[1], /'$.size = 6.Int'/, 'Int attribute' or diag $dump ;
like $dump.lines[2], /'$.name = P6 class.Str'/, 'Str attribute' or diag $dump ;
is $dump.lines.elems, 3, '3 lines dump' or diag $dump ;

