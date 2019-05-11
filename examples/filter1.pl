
use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::Enums ;

use Terminal::ANSIColor ;

# -------------------------------------------------------------------
# display a data structure after passing through user defined filters
# -------------------------------------------------------------------


# the data structure to dump

class Tomatoe{}
class Potatoe{}

my $s2 =
	[
	123,
	Tomatoe,
	Potatoe,
	{
		third => { a => 1},
	},
	] ;

ddt $s2, :title<unfiltered output>, :nl ;

ddt $s2, :title<filtered output>, :nl, header_filters => (&my_filter,), elements_filters => (&my_filter,), footer_filters => (&my_filter,) ;
ddt $s2, :title<filtered output>, header_filters => (&my_filter,) ;


# -----------
# the filters
# -----------

# everything is put in the same multi sub but different subs could have been used
# filters match on their signatures too


# HEADER FILTER
multi sub my_filter($dumper, $r, Int $s, ($depth, $path, $glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
# add text in the rendering
@renderings.push: (|$glyph, (color('bold white on_yellow'), "Int HEADER filter", color('reset'))) ;

# can replace ourselves with something else, do not forget to update k, b, v, accordingly
# r = < abc def > ;

k = '<my Int> ' ;
b = '<my b>' ;
v = '<my v>' ;
f = '<my f>' ;
final = DDT_NOT_FINAL ;
want_address = True ;
}


# HEADER FILTER
# called for every element in the data structure as $s, in the signature, is not typed
multi sub my_filter($dumper, $r, $s, ($depth, $path, $glyph, @renderings), ($k, $b, $v, $f, $final, $want_address))
{
# add text in the rendering
@renderings.push: (|$glyph , ( '', "<" ~ $s.^name ~ '> @depth ' ~ $depth, '')) ;
}


# HEADER FILTER
# replacement filter, matches Tomatoes, removes them from the dump
multi sub my_filter($dumper, \r, Tomatoe $s, ($depth, $path, $glyph, @renderings), $)
{
# add text in the rendering
@renderings.push: (|$glyph, (color('red'), 'removing tomatoe', color('reset'))) ;

# remove tomatoe
r = Data::Dump::Tree::Type::Nothing ;
}


# ELEMENTS FILTER
# Match Hashes and replace their elements
multi sub my_filter($dumper, Hash $s, ($, $glyph, @renderings, $), @sub_elements)
{
# add text in the rendering
@renderings.push: (|$glyph, ('', "Changing elements of the Hash", '')) ;

# new elements
@sub_elements = (('new element 1', ': ', 2/3), ('new element 2', ': ', 2), ('new element 3', ': ', 3)) ;
}



# FOOTER FILTER
# called for every element in the data structure as $s, in the signature, is not typed
multi sub my_filter($dumper, $s, ($depth, $filter_glyph, @renderings))
{
# add text in the rendering
@renderings.push: (|$filter_glyph, ('', "</{$s.^name}>", '')) ;
}


