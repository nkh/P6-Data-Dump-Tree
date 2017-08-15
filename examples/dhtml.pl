
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

$d1.dump_dhtml: $config ~~ /<section>*/ ;
note $d1.get_dump: $config ~~ /<section>*/ ;

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

my $d = Data::Dump::Tree.new:
		:title<Parsed JSON>, 
		:does(DDTR::DHTML, DDTR::MatchDetails, DDTR::PerlString),
		:display_address(DDT_DISPLAY_NONE) ;

# limit the output of the matched string to 40 characters in length	
$d.match_string_limit = 40 ;

$d.dump_dhtml: $parsed ;
$d.ddt: :note, $parsed ;



class Strings
{
# a class that defines DDT specific methods

method ddt_get_header { "say something about this class\nmultiline", '.' ~ self.^name ~ "\n multiline classes" }

method ddt_get_elements 
{ 
	('', '', 'has no name'), 
	("very very long\nexplanation on multiple lines\n", '', "many lines\n" x 5), 
	('single-long', ': ', 'x' x 300), 
	('multiple-long', ': ', 'x' x 300 ~ "\n" ~ 'y' x 200), 

	('12345678901234567890123456789012345', '', [ 1, {a => 3} ]),
	("12345678901234567890123456789012345\nxxx", '', 'test'),

	('coefficient', ' = ', 1), 
}

#class
}

# class with elements and methods but has not type handler nor DDT specific methods
class GenericClass { has $.x ; has $!z ; method zz {} }

# class with role that can be added to DDT
class Dog { has $.name; }
role DescribeDog
{

multi method get_header (Dog $d) 
{
'Woof! ', '.Dog (but this one is vagrant, no address)', DDT_NOT_FINAL, DDT_HAS_NO_ADDRESS 
}

multi method get_elements (Dog $d) { (q/the dog's name is/, ': ', $d.name), }

}


# class with inheritance and with 2 different roles that can be added to DDT
class Hermit {}
class LivesUnderRock {}
class Shy is Hermit is LivesUnderRock { has $.in_object }

# hide all internals
role DescribeShy { multi method get_elements (Shy $d) { } }

#hide itself behind a scalar
role DescribeShyFinal { multi method get_header (Shy $d) { 'Role{DescribeShyFinal} ', '.' ~ $d.^name, DDT_FINAL } }

# class which returns computed "internal" representation 
class Mangled
{
method ddt_get_elements { ('inner structure', ' => ', [123, 456]),  }
}

# class which returns a text representation, in the form of a table if Text::Table::Simple is installed
class Table
{

has Str $!title = 'mail addresses:' ;
has $!int = 1 ;

method ddt_get_elements 
{
my @e ;

try 
	{
	require Text::Table::Simple <&lol2table> ;

	my @columns = <id name email>;
	my @rows    = ([1,"John Doe",'johndoe@cpan.org'], [2,'Jane Doe','mrsjanedoe@hushmail.com'],);
	my @table = lol2table(@columns,@rows);

	@e = ($!title, '', @table.join("\n")), |get_attributes(self),  ;
	}

$! ?? (('DDT exception', ': ', "$!"),)  !! @e ;
}

#class
}

# ------------- test --------------

my $dall = Data::Dump::Tree.new:
		:title<test data>,
		:does(DDTR::DHTML, DDTR::MatchDetails, DescribeDog, DescribeShyFinal),
		:caller,
		:display_perl_address,
		:width(75),
		:max_depth(3) ;

$dall.dump_dhtml: get_test_structure ;
$dall.ddt: :note, get_test_structure ;

# ------------- helpers  -------------

sub get_test_structure
{
my $nil is default(Nil) = Nil; 
my @a = 1 ;
my $b = [< a >] ;
my $list = < a b > ;
my $sub = sub (Int $a, Str $string) {}
my Routine $routine ;

my $s = [
	'text',
	Str,
	12,
	Int,
	Rat.new(31, 10),
	$sub,
	$routine,
	[],
	@a,
	$b,
	@a,
	$b,
	$list,
	{
		default_nil => $nil,
		Nil => Nil,
		a => 1,
		b => 'string',
	},
	Cool.new(),
	Table.new(),
	GenericClass.new(:x(5), :z('hi there')),
	Mangled.new(),
	Dog.new(name => 'fido'), 
	Shy.new(secret => 'I will not say'),
	Strings.new(),
	#regex
	'aaa' ~~ m:g/(a)/,
	] ;

$s ;
}



