#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::MultiColumns ;
use Data::Dump::Tree::Horizontal ;

#test1 ;
#test2 ;
#test3 ;
#test4 ;
#test5 ;
test6 ;

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

sub test4
{
my %h1 = <a 1 b 2> ;
my @a1 = 11, 12 ;

dump :title<test_1>, [1..3], %h1, @a1, 123, [4..6], :elements_filters(lay_flat([1..3],) ) ;
dump :title<test_2>, [1..3], %h1, @a1, 123, [4..6], :elements_filters(lay_flat(Hash) ) ;
dump :title<test_3_1>, [1..3], %h1, @a1, 123, [4..6], :elements_filters(lay_flat(0) ) ;
dump :title<test_3_2>, [[[[1..3],],],], %h1, @a1, 123, [4..6], :elements_filters(lay_flat(3) ) ;
dump :title<test_4>, [1..3], %h1, @a1, 123, [4..6], :elements_filters(lay_flat(%(a => 1, b => 2),) ) ;
dump :title<test_5_1>, [1..3], %h1, @a1, 123, [4..6], :elements_filters(lay_flat(%h1,) ) ;
dump :title<test_5_2>, [1..3], %h1, @a1, 123, [4..6], :elements_filters(lay_flat(@a1,) ) ;
dump :title<test_6_1>, [1..3], %h1, @a1, 123, [4..6], :elements_filters(lay_flat(sub ($s, $d){$s ~~ Hash},) ) ;
dump :title<test_6_2>, [1..3], %h1, @a1, 123, [4..6], :elements_filters(lay_flat(sub ($s, $d){$s ~~ Array && $s.first: 4},) ) ;
dump :title<test_6_3>, [1..3], %h1, @a1, 123, [4..6], :elements_filters(lay_flat(sub ($s, $d){$s === %h1},) ) ;
}

sub test5
{
my %h1 = <a 1 b 2> ;
my %h2 = <d 3 e 4> ;

dump [1..3], %h1, %h2, 123, [1, [2, 3]], :elements_filters(lay_flat(Array) ), :display_perl_address ;
dump [1..3], %h1, %h2, 123, [4..6], :elements_filters(lay_flat($[1..3]) ), :display_perl_address ;
dump [1..3], %h1, %h2, 123, [4..6], :elements_filters(lay_flat(Hash, $[1..3]) ), :display_perl_address ;
#dump [1..3], %h1, %h2, 123, [4..6], :elements_filters(lay_flat(%(a => 1, b => 2),) ) ;
dump [1..3], %h1, %h2, 123, [4..6], :elements_filters(lay_flat(%h1,) ) ;
dd [1..3], %h1, %h2, 123, [4..6] ;
dump ([1..3], %h1, %h2, 123, [4..6]), :elements_filters(lay_flat(0) ) ;
}

sub test6
{
sub flatten_all($d, $s, ($depth, $glyph, @renderings, $), @sub_elements)
	{
	my $total_width = $d.width - (($depth  + 2 ) * 3) ;

	#@sub_elements = ( ( '', '', Data::Dump::Tree::Horizontal.new(:dumper($d), :elements(@sub_elements), :$total_width)), ) ;
	@sub_elements = ( ( '', '', Data::Dump::Tree::Horizontal.new(:dumper($d), :dumper_options(:!color,), :elements(@sub_elements), :$total_width)), ) ;
	}

dump get_test_structure(), :elements_filters(&flatten_all,) ;
}

sub lay_flat(**@targets)
{
#ddt @targets, :title("lay_flat args"), :elements_filters(flat_zero,) ; #todo: pass options to sub dumpers

return
	# sub elements filter
	sub ($d, $s, ($depth, $glyph, @renderings, $), @sub_elements)
	{

	my $d_m = $depth ~~ any( (|@targets).grep: { $_ ~~ Int }) ;

	my $t_m = $s ~~ any(| @targets.grep: { $_ !~~ Int && $_ !~~ Hash:D && $_ !~~ Sub }) ;

	for @targets.grep: { $_ ~~ Hash:D }
		{
		if $_ === $s 
			{
			$t_m = True ;
			last ;
			} 
		}

	my $s_m = False ;
	
	for @targets.grep: { $_ ~~ Sub }
		{
		if $_($s, $d) 
			{
			$s_m = True ;
			last ;
			} 
		}


#ddt @targets, :title<@targets> ;
#ddt $d_m, :title('$depth match is ') ;
#ddt $s, :title('$s = ') ;
#ddt $t_m, :title('$s matches element of @targets is ') ;
#ddt (@targets.first: { $s }), :title('match is ') ;

 	if $d_m || $t_m || $s_m
		{
		my $total_width = $d.width - (($depth  + 2 ) * 3) ;

		@sub_elements = ( ( '', '', Data::Dump::Tree::Horizontal.new(:dumper($d), :elements(@sub_elements), :$total_width)), ) ;
		}
	}
}

sub flat_zero()
{
return
	# sub elements filter
	sub ($d, $s, ($depth, $glyph, @renderings, $), @sub_elements)
	{
	my $total_width = $d.width - (($depth  + 2 ) * 3) ;

	@sub_elements = (
		(
		'',
		'',
		Data::Dump::Tree::Horizontal.new:
					:dumper($d),
					:dumper_options(:display_perl_address,),
					:elements(@sub_elements),
					:$total_width
		), ) ;
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


