#!/usr/bin/env perl6

use Test ;
plan 4 ;


use Data::Dump::Tree ;

class MyClass { has Int $.size ; has Str $.name }

my $s =	MyClass.new(:size(6), :name('P6 class')),

my $d = Data::Dump::Tree.new ;
my $dump =  dump $s, Nil, { color => 0 } ;

like $dump.lines[0], /'.MyClass'/, 'class name' ;
like $dump.lines[1], /'$.size = 6.Int'/, 'Int attribute' ;
like $dump.lines[2], /'$.name = P6 class.Str'/, 'Str attribute' ;
is $dump.lines.elems, 3, '3 lines dump' ;
