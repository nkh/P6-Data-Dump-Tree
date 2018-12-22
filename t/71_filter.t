#!/usr/bin/env perl6

use Test ;
use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;

plan 4 ;

# this is a small example of a filter. I was curious about how DDT would
# render itself. After a few try runs, with different options, I got tired of
# seeing a long list which consists of a lot of colors so I decided to filter
# them out


# remove the Hashes
multi sub header_filter($dumper, \r, Hash $s, ($depth, $path, $glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
# but only the one the ones which names contain the word 'color'
# DDT calls the type handler before the filters so it has already all
# kind of information that we can use in our filter

if k ~~ /color/
	{
	@renderings.push: (|$glyph, ('', 'removing ' ~ k, '')) ;
	r = Data::Dump::Tree::Type::Nothing ;
	}
else
	{
	@renderings.push: (|$glyph, ('', 'not removing ' ~ k, '')) ;
	}
}


# we can also act at a higher level, this filter catches the DDT object
# before the Hashes are displayed
multi sub elements_filter($dumper, Data::Dump::Tree $s, ($depth, $glyph, @renderings, $), @sub_elements)
{
# simply show that we were called
@renderings.push: (|$glyph, ('', 'SUB ELEMENTS', '')) ;

# we could have eliminated any sub element from @sub_elements, or even
# added some elements
}

my $d = Data::Dump::Tree.new does DDTR::AsciiGlyphs ;
my $dump = $d.ddt: :get, $d, :!color, :width<80>, :header_filters[&header_filter], :elements_filters[&elements_filter] ;

is $dump.lines.elems, 49, 'lines output' or diag $dump ;
like $dump, /removing/, 'removing' or diag $dump ;
like $dump, /'not removing'/, 'not removing' or diag $dump ;
like $dump, /'SUB ELEMENTS'/, 'sub elements filter' or diag $dump ;

