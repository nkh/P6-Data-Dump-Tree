
use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;

my @s = [ [ [ [ [ [], ], ], ], ],  ] ;

dump(@s) ;
dump(@s, title => 'nested structure', glyph_colors => < glyph_0 glyph_1 glyph_2 glyph_3 >) ;

my regex header { \s* '[' (\w+) ']' \h* \n+ }
my regex identifier  { \w+ }
my regex kvpair { \s* <key=identifier> '=' <value=identifier> \n+ }
my regex section {
    <header>
    <kvpair>*
}

my $contents = q:to/EOI/;
    [passwords]
        jack=password1
        joy=muchmoresecure123
    [quotas]
        jack=123
        joy=42
EOI

my $d = Data::Dump::Tree.new(display_perl_address => True) ;


$d does DDTR::MatchDetails ;

my $m = $contents ~~ /<section>*/ ;
$d.dump($m) ;

$d does DDTR::NumberedLevel ;
$d does DDTR::Superscribe ;

$m = $contents ~~ /<section>*/ ;
$d.dump($m, glyph_colors => < glyph_0 glyph_1 glyph_2 glyph_3 >) ;

