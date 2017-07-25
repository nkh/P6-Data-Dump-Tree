#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::MultiColumns ;

class DDT_Columns
{
has Str $.title = '' ;
has $.total_width ;
has $.dumper ;
has $.element ;

method ddt_get_header
{ 
my $columnizer = Data::Dump::Tree.new does DDT::MultiColumns ;

my $columns = $columnizer.get_columns:   
				:$.total_width,
				|($!element.map(
					{ 
					get_dump_lines_integrated(
						$_,
						:title($++ ~ ' ='),
						:address_from($!dumper),
						)
					 })) ;

($!title ne '' ?? "$!title\n" !! '') ~ $columns, '', DDT_FINAL 
}

} #class

test1 ;
test2 ;
test3 ;

sub test1
{
dump (1, 3, 4), :elements_filters(lay_flat(0)) ;
dump( 
	get_test_structure(),
	:title<horizontal>,
	:elements_filters(lay_flat(0)),
	) ;
}

sub test2
{
dump( 
	get_test_structure(),
	:title<horizontal>,
	:elements_filters(lay_flat(1),),
	) ;
}

sub test3
{
my $columnizer = Data::Dump::Tree.new does DDT::MultiColumns ;
$columnizer.display_columns:	get_dump_lines_integrated( 
					get_test_structure(),
					:title<horizontal>,
					:width(75),
					:elements_filters(lay_flat(1),),
					),
				get_dump_lines_integrated(
					get_test_structure(),
					:title<horizontal>,
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

		@sub_elements = ( ( '', '', DDT_Columns.new(:xtitle<title>, :dumper($d), :element($s), :$total_width )), ) ;
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


