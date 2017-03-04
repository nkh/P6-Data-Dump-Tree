
use JSON::Tiny ;
use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;

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

my $parsed = JSON::Tiny::Grammar.parse($JSON) ;
$parsed.perl.say ;
$parsed.gist.say ;

use Data::Dump ;
Dump($parsed).say ;

my $d = Data::Dump::Tree.new(
		title => 'Parsed JSON', 
		#color => False, width => 100, display_info => False, 
		does => 
			(
			DDTR::MatchDetails, DDTR::PerlString,
			DDTR::UnicodeGlyphs, DDTR::Superscribe,
			)
		) ;
	
$d.match_string_limit = 40 ;
$d.dump($parsed) ;

