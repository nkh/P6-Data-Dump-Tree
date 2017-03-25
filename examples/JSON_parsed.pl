
use Data::Dump::Tree ;
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
my $parsed = JSON::Tiny::Grammar.parse($JSON) ;

# display using .perl
$parsed.perl.say ;

# display using .gist
$parsed.gist.say ;

# show the dump via Data::Dump, this takes ages so it is commented out
#use Data::Dump ;
#Dump($parsed).say ;

# dump with DDT
my $d = Data::Dump::Tree.new(
		title => 'Parsed JSON', 
		#color => False, width => 100, display_info => False, 
		does => 
			(
			DDTR::MatchDetails, DDTR::PerlString,
			DDTR::UnicodeGlyphs, DDTR::Superscribe,
			)
		) ;

# limit the output of the matched string to 40  characters in length	
$d.match_string_limit = 40 ;

$d.dump($parsed) ;

