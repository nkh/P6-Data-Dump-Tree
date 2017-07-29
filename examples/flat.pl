#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::MultiColumns ;

test1 ;
test2 ;
test3 ;
test4 ;
test5 ;

sub test1
{
ddt 1, 3, [[4..3], 1], :!color, :flat ;
ddt 1, 3, [[4..3], 1], :!color ;
ddt 1, 3, 4 ;
ddt (1, 3, 4) ;
ddt [1, 3, 4,], :flat ;
}

sub test2
{
ddt get_small_test_structure ;
ddt get_small_test_structure, :flat ;

ddt get_small_test_structure_hash ;
ddt get_small_test_structure_hash, :flat ;
}

sub test3
{
ddt get_test_structure ;
dd get_test_structure ;

ddt get_test_structure, :flat(0) ;
ddt get_test_structure, :flat(1) ;
ddt get_test_structure, :flat(2) ;

my $width = %+((qx[stty size] || '0 80') ~~ /\d+ \s+ (\d+)/)[0] ; 
$width = ($width / 2).Int ;

display_columns 
	get_dump_lines_integrated( 
				get_test_structure,
				:$width,
				:flat(0),
				),
	get_dump_lines_integrated(
			get_test_structure,
				:$width,
				:header_filters(),
				) ;

}

sub test4
{
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
	(12,	:title<test [1..3]>, 			$s, 		:flat([1..3],)),
	(14,	:title<test Hash>, 			$s, 		:flat(Hash,)),
	(6,	:title<test 0>, 			$s, 		:flat(0)),
	(11,	:title<test 2>, 			($d, [3..5]), 	:flat(2)),
	(14,	:title<test 3>, 			($d, [3..5], $d), :flat(3)),
	(13,	:title<<test %(a => 1, b => 2)>>, 	$s, 		:flat(%(a => 1, b => 2),)),
	(14,	:title<test %h1>, 			$s, 		:flat(%h1,)),
	(13,	:title<test @a>, 			$s, 		:flat(@a,)),
	(14,	:title<test sub: Hash>, 		$s, 		:flat({$_ ~~ Hash})),
	(12,	:title<test sub Array $s.first: 3>,	$s, 		:flat({$_ ~~ Array && $_.first: 3})),
	(14,	:title<test sub: $s == %h1>,		$s, 		:flat({$_ === %h1})),
	# columns 
	(39,	:title<flat()>,				$d2,		:flat()),
	(38,	:title<flat((H, 2))>,			$d2,		:flat((Hash, 2),)),
	(22,	:title<flat((sA, 2))>,			$d2,		:flat(({$_ ~~ Array && $*d == 1}, 2), )),
	(25,	:title<flat((sA, L1, *5) 2)>,		$d2,		:flat(({$_ ~~ Array && $*d == 1, 5}, 2), )),
	(35,	:title<flat((sA, L2, *5) 2)>,		$d2,		:flat(({$_ ~~ Array && $*d == 2, 5}, 2), )),
	(35,	:title<flat((s@a2, L2, *5) 2)>,		$d2,		:flat(({$_ === @a2 && $*d == 2, 5}, 2), )),
	(35,	:title<flat((sA, L2, *5) 2)>,		$d2,		:flat({$_ ~~ Array && $*d == 2, 5}, )),
	(21,	:title<flat((sA, *5) 2)>,		$d2,		:flat(({$_ ~~ Array, 5}, 2), )),

	# hash flatten if more than two keys, if less only if keys are non final
	# array guess number of columns based on the number of elements and left space and rendering, which we know nothing about :)
	(53,	:title<d3, flat(H, sA-5)>,		$d3,		:flat({$_ ~~ Hash && $_.keys > 1}, {$_ ~~ Array && $_.elems > 5, 5} )),
	)
	{
	my ($lines, $title, $ds, $flat) = |$_ ;
	my Capture $c = \(|$title, $ds, |$flat) ;

	ddt |$c, :width(80) ;
	}
}


sub test5
{
my %h1 = <a 1 b 2> ;
my %h2 = <d 3 e 4> ;

ddt [1..3], %h1, %h2, 123, [1, [2, 3]], :display_perl_address ;
ddt [1..3], %h1, %h2, 123, [1, [2, 3]], :flat, :display_perl_address ;
ddt [1..3], %h1, %h2, 123, [1, [2, 3]], :flat(), :display_perl_address ;
}

# ------------- helpers  -------------

sub get_test_structure
{
my $element  = [1, [2, [3, 4]]] ;
my $element2 = [1, 2] ;
my $element3 = [ $element2, $element xx 11] ;

my $data = [ $element, ([6, [3]],), $element ] ;

my $s = (
	$data,
	[ $element xx 2 ],
	$element3,
	[ |($element xx 2), $element2, [1...3], |($element xx 6) ],
	$element3,
	'12345678',
	) ;

$s ;
}

sub get_small_test_structure
{
my $element  = [1, [2, [3, 4]]] ;
my $element2 = [1, 2, Pair.new(3, [4, 5])] ;
my $element3 = [ $element2, $element xx 11] ;

my $data = [ $element, ([6, [3]],), $element ] ;

my $s = (
	[ $element xx 2 ],
	$element3,
	'12345678',
	$element3,
	) ;

$s ;
}

sub get_small_test_structure_hash
{
my $element  = [1, [2, [3, 4]]] ;
my $element2 = [1, 2, Pair.new(3, [4, 5])] ;
my $element3 = [ $element2, $element xx 11] ;

my $data = [ $element, ([6, [3]],), $element ] ;

my %s = (
	engine => [ $element xx 2 ],
	tires => $element3,
	ID => '12345678',
	components => $element3,
	) ;

%s ;
}


