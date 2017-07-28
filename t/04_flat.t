#!/usr/bin/env perl6

use Data::Dump::Tree ;

use Test ;
plan 11 ;

my @a = [4..5] ;
my $d = [[[[1..2],[3..4],],]] ;
my %h1 = <c 3> ;
my %h2 = <a 1 b 2> ;
my $s = ([1..3], %h1, %h2, @a) ;

for
	(
	(13,	 :title<test 10, string>,	 	$s, 		:flat(10, <hello>)),
	(12,	 :title<test [1..3]>, 			$s, 		:flat([1..3],)),
	(14,	 :title<test Hash>, 			$s, 		:flat(Hash,)),
	(6,	 :title<test 0>, 			$s, 		:flat(0)),
	(11,	 :title<test 2>, 			($d, [3..5]), 	:flat(2)),
	(13,	 :title<<test %(a => 1, b => 2)>>, 	$s, 		:flat(%(a => 1, b => 2),)),
	(14,	 :title<test %h1>, 			$s, 		:flat(%h1,)),
	(13,	 :title<test @a>, 			$s, 		:flat(@a,)),
	(14,	 :title<test sub: Hash>, 		$s, 		:flat(sub ($s, $d){$s ~~ Hash})),
	(12,	 :title<test sub Array $s.first: 3>,	$s, 		:flat(sub ($s, $d){$s ~~ Array && $s.first: 3})),
	(14,	 :title<test sub: $s == %1>,		$s, 		:flat(sub ($s, $d){$s === %h1})),
	# option passing
	)
	{
	my ($lines, $title, $ds, $flat) = | $_ ;

	my Capture $c = \(|$title, $ds, |$flat) ;

	my $r = get_dump_lines_integrated |$c ;
	is($r.elems, $lines) or diag $r.join("\n") ;

	#diag get_dump |$c ;
	}

