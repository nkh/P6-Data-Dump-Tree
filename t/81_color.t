#!/usr/bin/env perl6

use Test;
use Data::Dump::Tree;
use Data::Dump::Tree::MultiColumns ;

use Test ;
plan 21 ;

# render in BW and color and compare the lines generated

my @a = [4..5] ;
my $d = [[[[1..2],[3..4],],]] ;
my %h1 = <c 3> ;
my %h2 = <a 1 b 2> ;
my $s = ([1..3], %h1, %h2, @a) ;

my %h3 = <a 1 b 2 c 3 d 4> ;
my @a2 = [1..10] ;
my $d2 = ([1..10], [|(1..10), @a2 ], %h3) ;

my $d3 = ([1..10], [|(1..10), [|(1..22), %h1, %h2,%h2, |(23..30), [1..6], |(1..4)] ], {some => {a => 1, b => [|(1..5), %h1]}, thing => $s}) ;

for
	(
	(13,	:title<test 10, string>,	 	$s, 		:flat(10, <hello>)),
	(13,	:title<test [1..3]>, 			$s, 		:flat([1..3],)),
	(12,	:title<test Hash>, 			$s, 		:flat(Hash,)),
	(5,	:title<test 0>, 			$s, 		:flat(0)),
	(10,	:title<test 2>, 			($d, [3..5]), 	:flat(2)),
	(12,	:title<test 3>, 			($d, [3..5], $d), :flat(3)),
	(13,	:title<<test %(a => 1, b => 2)>>, 	$s, 		:flat(%(a => 1, b => 2),)),
	(13,	:title<test %h1>, 			$s, 		:flat(%h1,)),
	(12,	:title<test @a>, 			$s, 		:flat(@a,)),
	(12,	:title<test sub: Hash>, 		$s, 		:flat({$_ ~~ Hash})),
	(11,	:title<test sub Array $s.first: 3>,	$s, 		:flat({$_ ~~ Array && $_.first: 3})),
	(13,	:title<test sub: $s == %h1>,		$s, 		:flat({$_ === %h1})),
	# columns 
	(39,	:title<flat()>,				$d2,		:flat()),
	(38,	:title<flat((H, 2))>,			$d2,		:flat((Hash, 2),)),
	(23,	:title<flat((sA, 2))>,			$d2,		:flat(({$_ ~~ Array && $*d == 1}, 2), )),
	(26,	:title<flat((sA, L1, *5) 2)>,		$d2,		:flat(({$_ ~~ Array && $*d == 1, 5}, 2), )),
	(35,	:title<flat((sA, L2, *5) 2)>,		$d2,		:flat(({$_ ~~ Array && $*d == 2, 5}, 2), )),
	(35,	:title<flat((s@a2, L2, *5) 2)>,		$d2,		:flat(({$_ === @a2 && $*d == 2, 5}, 2), )),
	(35,	:title<flat((sA, L2, *5) 2)>,		$d2,		:flat({$_ ~~ Array && $*d == 2, 5}, )),
	(22,	:title<flat((sA, *5) 2)>,		$d2,		:flat(({$_ ~~ Array, 5}, 2), )),

	# hash flatten if more than two keys, if less only if keys are non final
	# array guess number of columns based on the number of elements and left space and rendering, which we know nothing about :)
	(47,	:title<d3, flat(H, sA-5)>,		$d3,		:flat({$_ ~~ Hash && $_.keys > 1}, {$_ ~~ Array && $_.elems > 5, 5} )),
	)
	{
	my ($lines, $title, $ds, $flat) = | $_ ;
	my Capture $c = \(|$title, $ds, |$flat) ;

	my $bw = ddt :get_lines_integrated, |$c, :width(80), :!color ;
	my $col = ddt :get_lines_integrated, |$c, :width(80) ;

	my regex ansi_color { \e \[ \d+ [\;\d+]* <?before [\;\d+]* > m } 

	is($col.map({ S:g/ <ansi_color> // with $_}), $bw, 'same contents')  or do
		{
		display_columns ('-' x 40, |$bw, '-' x 40), ('-' x 40, |$col, '-' x 40) ;
		}
	}



