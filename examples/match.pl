
use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::Enums ;

# content to be matched
my $contents = q:to/EOI/;
    [passwords]
        jack=password1
        joy=muchmoresecure123
    [quotas]
        jack=123
        joy=42
EOI

# define some regexp structure 
my regex header { \s* '[' (\w+) ']' \h* \n+ }
my regex identifier  { \w+ }
my regex kvpair { \s* <key=identifier> '=' <value=identifier> \n+ }
my regex section { <header> <kvpair>* }

# create a match object to dump
my $m = $contents ~~ /<section>*/ ;

dump(:title('Parsing dump without any extra roles'), $m);

# dump with different roles 
my $d = Data::Dump::Tree.new ;
$d does DDTR::MatchDetails ;
$d does DDTR::SuperscribeType ;
$d does DDTR::SuperscribeAddress ;

$d.dump(:title('Parsing with MatchDetails role'), $m );

$d does DDTR::PerlString ;
$d.dump(:title('Parsing with MatchDetails and PerlString roles'), $m );

$d.dump(:title('Parsing with MatchDetails and PerlString roles, custom colors and no address'),
	$m,
	does => (DDTR::FixedGlyphs,),
	:display_address(DDT_DISPLAY_NONE),
	:colors(
		<<
		ddt_address 17  perl_address 58  link   23
		key         32  binder       32  value  246  header 53
		wrap        23

		glyph_0 95  glyph_1 59  glyph_2 64  glyph_3 94  glyph_4 31
		>>), 
	 );


