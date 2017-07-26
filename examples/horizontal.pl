#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::MultiColumns ;
use Data::Dump::Tree::Horizontal ;

test1 ;
test2 ;
test3 ;

sub test1
{
dump 1, 3, 4 ;
dump [1, 3, 4,], :elements_filters(lay_flat(0),) ;

dump get_small_test_structure() ;
dump get_small_test_structure(),:elements_filters(lay_flat(0)) ;

dump get_small_test_structure_hash() ;
dump get_small_test_structure_hash(),:elements_filters(lay_flat(0)) ;
}

sub test2
{
dump get_test_structure() ;
dump get_test_structure(), :elements_filters(lay_flat(0)) ;
dump get_test_structure(), :elements_filters(lay_flat(1)) ;
dump get_test_structure(), :elements_filters(lay_flat(2)) ;
}

sub test3
{
display_columns get_dump_lines_integrated( 
				get_test_structure(),
					:width(75),
					:elements_filters(lay_flat(1),),
					),
				get_dump_lines_integrated(
					get_test_structure(),
					:width(75),
					:header_filters(),
					) ;

dd get_test_structure ;
}

sub lay_flat($flatten_at_depth)
{
return
	# sub elements filter
	sub ($d, $s, ($depth, $glyph, @renderings, $), @sub_elements)
	{
	if $depth == $flatten_at_depth  
		{
		my $total_width = $d.width - (($depth  + 2 ) * 3) ;

		@sub_elements = ( ( '', '', Data::Dump::Tree::Horizontal.new(:dumper($d), :elements(@sub_elements), :$total_width)), ) ;
		}
	}
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


