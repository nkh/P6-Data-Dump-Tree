
use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;

# use json parser
use JSON::Tiny ;

# The Json that needs parsing
my $JSON =
Q<<{
    "glossary": {
        "title": "example glossary",
		"GlossDiv": {
            "title": "S",
			"GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
					"SortAs": "SGML",
					"GlossTerm": "Standard Generalized Markup Language",
					"Acronym": "SGML",
					"Abbrev": "ISO 8879:1986",
					"GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
						"GlossSeeAlso": ["GML", "XML"]
                    },
					"GlossSee": "markup"
                }
            }
        }
    }
}>> ;

# parse data
my $parsed = JSON::Tiny::Grammar.parse: $JSON ;

# display using .perl
#$parsed.perl.say ;

# display using .gist
$parsed.gist.say ;

# show the dump via Data::Dump, this takes ages so it is commented out
#use Data::Dump ;
#Dump($parsed).say ;

# dump with DDT
my $d = Data::Dump::Tree.new:
		:title<Parsed JSON>, 
		#:!color, :width(100), :!display_info, 
		:display_address(DDT_DISPLAY_NONE),
		:does(DDTR::MatchDetails, DDTR::PerlString, DDTR::Superscribe) ;

# limit the output of the matched string to 40  characters in length	
$d.match_string_limit = 40 ;
$d.dump: $parsed ;


$d.dump: $parsed, :header_filters(&header_filter,), :elements_filters(&elements_filter,) ;

sub header_filter($dumper, \r, $s, ($depth, $path, $glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
# simplifying the dump, this is optional

# <pair> with a value that has no sub elements can be displayed in a more compact way
if k eq "<pair>" 
	{ 
	my %caps = $s.caps ;
 
	if %caps<value>.caps[0][0].key eq 'string'
		{
		v = ls(~%caps<string>, 40)  ~ ' => ' ~ ls(~%caps<value>, 40) ;
		final = DDT_FINAL ;
		}
	}

# "<object>" | "<pairlist>" | "<array>" | '<arraylist>' need no details
if k eq "<object>" | "<pairlist>" | "<array>" | '<arraylist>'
	{ 
	v = '' ;
	f = '' ;
	}

}

sub elements_filter($dumper, $s, ($depth, $glyph, @renderings, $element), @sub_elements)
{
# simplifying the dump, this is optional

my ($k, $b) = $element ;

# <string> matches will have two elements that add nothing to the dump, remove them
@sub_elements = () if $k eq '<string>' ; 

# <value> has a <string> element that add nothing to the dump; remove it
@sub_elements = @sub_elements.grep({$_[0] ne '<string>' }) if $k eq "<value>" ; 
}


# helper sub

sub ls(Str $s, $limit)
{
if $limit.defined && $s.chars > $limit
	{
	$s.substr(0, $limit) ~ '(+' ~ $s.chars - $limit ~ ')'
	}
else
	{
	$s 
	}	
}


