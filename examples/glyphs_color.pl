
use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::Enums ;

my $d = Data::Dump::Tree.new ;
my $m = [ [ |(1..3), [ |(1..3), [ |(1..3), [ |(1..3), [ 1..3 ] ] ], |(1..3) ] ], 1] ;

$d does DDTR::SuperscribeType ;
$d does DDTR::SuperscribeAddress ;

$d.ddt: $m, :title<Glyphs> ;

$d.ddt: $m, :title<Glyphs, numbered levels>, :does(DDTR::NumberedLevel,) ;

$d.ddt: $m, :title<Glyphs, colored glyphs default>, :color_glyphs ;

$d.ddt: $m, :title<Glyphs, custom colors, 3 first level green>,
		:colors(< gl_0 green gl_1 green gl_2 green >), 
		:color_glyphs ;


