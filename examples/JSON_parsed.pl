
use JSON::Tiny ;
use Data::Dump::Tree ;

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
$parsed.say ;

my $d = get_dumper {roles => (DDTR::MatchDetails, DDTR::PerlString), } ;

$d.dump( $parsed, 'Parsed JSON', {width => 135} );

