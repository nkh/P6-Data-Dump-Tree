
use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DHTML;

my $d1 = Data::Dump::Tree.new(title => 'Config', does => ( DDTR::DHTML,),) ;

my regex header { \s* '[' (\w+) ']' \h* \n+ }
my regex identifier  { \w+ }
my regex kvpair { \s* <key=identifier> '=' <value=identifier> \n+ }
my regex section {
    <header>
    <kvpair>*
}

my $config = q:to/EOI/;
    [passwords]
        jack=password1
        joy=muchmoresecure123
    [quotas]
        jack=123
        joy=42
EOI

$d1 does DDTR::MatchDetails ;
$d1.dump_dhtml($config ~~ /<section>*/) ;

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

my $d = Data::Dump::Tree.new(
	:title('Parsed JSON'), 
	does => ( DDTR::DHTML, DDTR::MatchDetails, DDTR::PerlString,),
	:display_address(DDT_DISPLAY_NONE),
	#:width(79),
	) ;

# limit the output of the matched string to 40 characters in length	
$d.match_string_limit = 40 ;

$d.dump_dhtml($parsed) ;


