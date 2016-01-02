#!/usr/bin/env perl6

use Test ;
use Data::Dump::Tree ;

plan 4 ;

# this is a small example of a filter. I was curious about how DDT would
# render itself. After a few try runs, wit different options, I got tired of
# seing a long list which consists of a lot of colors so I decided to filter
# them out 


# remove the Hashes
multi sub my_filter(\r, Hash $s, DDT_HEADER, ($depth, $glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
# but only the one the ones which names contain the word 'color'
# DDT calls the type handler before the filters so it has already all
# kind of information that we can use in our filter

if k ~~ /color/
	{
	@renderings.append: $glyph ~ 'removing ' ~ k ;
	r = Data::Dump::Tree::Type::Nothing ;
	}
else
	{
	@renderings.append: $glyph ~ 'not removing ' ~ k ;
	}
}


# we can also act at a higher level, this filter catches the DDT object
# before the Hashes are displayed
multi sub my_filter( Data::Dump::Tree $s, DDT_SUB_ELEMENTS, ($depth, $glyph, @renderings), (@sub_elements))
{
# simply show that we were called
@renderings.append: $glyph ~ "SUB ELEMENTS " ~ $s.^name ;

# we could have eliminated any sub element from @sub_elements, or even
# added some elements
}

my $d = Data::Dump::Tree.new(color => False) ;
my $dump = $d.get_dump($d, filters => (&my_filter,)) ;

is $dump.lines.elems, 21, 'lines output' ;
like $dump, /removing/, 'removing' ;
like $dump, /'not removing'/, 'not removing' ;
like $dump, /'SUB ELEMENTS'/, 'sub elements filter' ;
