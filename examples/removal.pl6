
use Data::Dump::Tree ;

my $s =
	[
	123,
	456,
	class Tomatoe {has $.seeds}.new(:seeds<3>),
	] ;

"
NOTE: the array shows 3 elements even when an element is removed, this is because
the filters is done after the header for the Array is rendered
". say ;

ddt $s, :title<With Tomatoe>, :nl ;
ddt $s, :title<remove Tomatoe>, :nl, removal_filters => (&remove_tomatoe,) ;
ddt $s, :title<Filter Nil>, :nl, removal_filters => (&return_Nil,) ;
ddt $s, :title<remove Tomatoe 2 filters>, :nl, removal_filters => (&remove_tomatoe, &keep_tomatoe) ;
ddt $s, :title<broken gllyph>, :nl, header_filters => (&remove_tomatoe_header_filter,) ;
ddt $s, :title<container filter 1>, :nl, elements_filters => (&remove_tomatoe_container_filter_1,) ;
ddt $s, :title<container filter 2>, :nl, elements_filters => (&remove_tomatoe_container_filter_2,) ;


multi sub remove_tomatoe($dumper, Tomatoe $s, $path) { True }
multi sub return_Nil($dumper, Tomatoe $s, $path) { }
multi sub keep_tomatoe($dumper, Tomatoe $s, $path) { False }

multi sub remove_tomatoe_header_filter($dumper, \replacement, Tomatoe $s, $, $)
{
replacement = Data::Dump::Tree::Type::Nothing ;
}

multi sub remove_tomatoe_container_filter_1($dumper, \replacement, Tomatoe $s, $, $)
{
replacement = Data::Dump::Tree::Type::Nothing ;
}

multi sub remove_tomatoe_container_filter_1(
	$dumper,
	Array $s, 

	($depth, $glyph, @renderings, ($key, $binder, $value, $path)),

	# elements you can modify 
	@sub_elements
	)
{
# set/filter  the elements 
@sub_elements[2]:delete ;
}

multi sub remove_tomatoe_container_filter_2(
	$dumper,
	Array $s, 

	($depth, $glyph, @renderings, ($key, $binder, $value, $path)),

	# elements you can modify 
	@sub_elements
	)
{
# set/filter  the elements 
@sub_elements[2] = ('tomatoe', '', Data::Dump::Tree::Type::Nothing.new) ;
}


