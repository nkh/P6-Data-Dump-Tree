
use Data::Dump::Tree ;
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
	Tomatoe,
	123,
	Tomatoe,
	Potatoe,
	{
		third => { a => 1},
	},
	0.5,
	Tomatoe,
	] ;


my $d = Data::Dump::Tree.new ;

# dump unfiltered
dump $s2 ;

# dump filtered
dump $s2, header_filters => (&my_filter,), elements_filters => (&my_filter,), footer_filters => (&my_filter,) ;


# -----------
# the filters
# -----------

# everything is put in the same multi sub but different subs could have been used
# filters match on their signatures too


# 
multi sub xmy_filter(\r, Int $s, ($depth, $path, $glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
# add text in the rendering
@renderings.append: $glyph ~ color('bold white on_yellow') ~ "Int replacement" ;

r = { a => 1, b => 2 }  ;

k = k ~ ' Int replaced by ' ;
#b = '' ;
#v = '' ;
#f = '' ;
final = DDT_NOT_FINAL ;
want_address = True ;

}


# HEADER, called for every element in the data structure as $s, in the signature, is not typed
multi sub my_filter($r, $s, ($depth, $path, $glyph, @renderings), ($k, $b, $v, $f, $final, $want_address))
{
# add text in the rendering
@renderings.append: $glyph ~ "<" ~ $s.^name ~ '> @depth ' ~ $depth ;
}


# replacement filter, matches Tomatoes, removes them from the dump
multi sub my_filter(\r, Tomatoe $s, ($depth, $path, $glyph, @renderings), $)
{
# add text in the rendering
@renderings.append: $glyph ~ color('red') ~ 'removing tomatoe' ;

# remove tomatoe
r = Data::Dump::Tree::Type::Nothing ;
}


# Match Hashes and replace their elements
multi sub my_filter(Hash $s, ($depth, $glyph, @renderings), @sub_elements)
{
# add text in the rendering
@renderings.append: $glyph ~ "Changing the elements of the Hash" ;

# new elements
@sub_elements = (('rep key1', ': ', 1), ('rep key2', ': ', 2)) ; 
}



# FOOTER, called for every element in the data structure as $s, in the signature, is not typed
multi sub my_filter($s, ($depth, $filter_glyph, @renderings))
{
# add text in the rendering
@renderings.append: $filter_glyph ~ "</{$s.^name}>" ;
}


