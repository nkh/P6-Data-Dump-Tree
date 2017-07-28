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
ddt 1, 3, 4 ;
ddt (1, 3, 4) ;
ddt [1, 3, 4,], :flat(0) ;

ddt get_small_test_structure ;
ddt get_small_test_structure, :flat(0) ;

ddt get_small_test_structure_hash ;
ddt get_small_test_structure_hash,:flat(0) ;
}

sub test2
{
#dd get_test_structure ;
#ddt get_test_structure, :flat(0) ;
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

	ddt |$c ;
	}
}


sub test5
{
my %h1 = <a 1 b 2> ;
my %h2 = <d 3 e 4> ;

ddt [1..3], %h1, %h2, 123, [1, [2, 3]], :flat(0), :display_perl_address ;
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


