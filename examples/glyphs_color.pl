use Data::Dump::Tree ;

my @s = [ [ [ [ [ [], ], ], ], ],  ] ;

dump(@s) ;
dump(@s, title => 'nested structure', glyph_colors => < glyph_0 glyph_1 glyph_2 glyph_3 >) ;




