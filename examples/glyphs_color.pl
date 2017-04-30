
use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::ExtraRoles ;

my $d = Data::Dump::Tree.new ;

$d.dump([ [ |(1..3), [ |(1..3), [ |(1..3), [ |(1..3), [ 1..3 ] ] ] ] ], 1], :title('Glyphs'));


# dump again with roles on 
$d does DDTR::SuperscribeType ;
$d does DDTR::SuperscribeAddress ;

$d.dump([ [ |(1..3), [ |(1..3), [ |(1..3), [ |(1..3), [ 1..3 ] ] ] ] ], 1], :title('Glyphs'),
	 :glyph_colors( < glyph_0 glyph_1 glyph_2 glyph_3> ) );

$d does DDTR::NumberedLevel ;
$d.dump([ [ |(1..3), [ |(1..3), [ |(1..3), [ |(1..3), [ 1..3 ] ] ] ] ], 1], :title('Glyphs'),
	 :glyph_colors( < glyph_0 glyph_1 glyph_2 glyph_3> ) );


