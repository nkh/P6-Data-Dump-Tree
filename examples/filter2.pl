
use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Terminal::ANSIColor ;


# this is a small example of a filter. I was curious about how DDT would
# render itself. After a few try runs, wit different options, I got tired of
# seeing a long list which consists of a lot of colors so I decided to filter
# them out


my $d = Data::Dump::Tree.new does DDTR::QuotedString ;

# remove the Hashes
multi sub my_filter($dumper, \r, Hash $s, ($, $path, $glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
# but only the one the ones which names contain the word 'color'
# DDT calls the type handler before the filters so it has already all
# kind of information that we can use in our filter

if k ~~ /color/
	{
	@renderings.push: (|$glyph, (color('red'), 'removing ' ~ k, color('reset')))  ;
	r = Data::Dump::Tree::Type::Nothing ;
	}
}


# we can also act at a higher level, this filter catches the DDT object
# before the Hashes are displayed
multi sub my_element_filter($dumper, Data::Dump::Tree $s, ($, $glyph, @renderings, $), @sub_elements)
{
# simply show that we were called
@renderings.push: (|$glyph, ('', 'sub elements filter called ' ~ $s.^name, '')) ;

# we could have eliminated any sub element from @sub_elements, or even
# added some elements
}

# unfiltered dump
$d.ddt: $d ;

# filtering on
$d.ddt: $d, :header_filters(&my_filter,), :elements_filters(&my_element_filter,) ;


