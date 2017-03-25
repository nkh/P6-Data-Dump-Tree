
use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;


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
my regex section {
    <header>
    <kvpair>*
}

# create a match object to dump
my $m = $contents ~~ /<section>*/ ;

# dump with match details and number the levels
my $d = Data::Dump::Tree.new ;
$d does DDTR::MatchDetails ;
$d does DDTR::NumberedLevel ;

$d.dump($m) ;


# dump again with superscribed text and color glyphs
$d does DDTR::SuperscribeType ;
$d does DDTR::SuperscribeAddress ;

$m = $contents ~~ /<section>*/ ;
$d.dump($m, glyph_colors => < glyph_0 glyph_1 glyph_2 glyph_3 >) ;

