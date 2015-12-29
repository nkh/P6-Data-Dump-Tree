
use JSON::Tiny ;
use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;

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
#$parsed.say ;

dump( $parsed, title => 'Parsed JSON',
	 does => 
		(
		DDTR::MatchDetails, DDTR::PerlString,
		DDTR::UnicodeGlyphs, DDTR::SuperscribeType, DDTR::SuperscribeAddress,
		)
	 ) ;


