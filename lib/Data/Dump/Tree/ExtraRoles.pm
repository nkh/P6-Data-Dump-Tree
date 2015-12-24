
role DDTR::FixedGlyphs
{
has $.fixed_glyph ;

multi method get_glyphs
{
	{
	last => $.fixed_glyph, not_last => $.fixed_glyph,
	last_continuation => $.fixed_glyph, not_last_continuation => $.fixed_glyph,
	multi_line => $.fixed_glyph, empty => ' ' x $.fixed_glyph.chars, max_depth => '...', 
	}
}

#role
}

role DDTR::NumberedLevel
{

method get_level_glyphs($level)
{
my %glyphs = $.get_glyphs() ;

my $superscript_level = $.superscribe($level) ;

for <last not_last> { %glyphs{$_}= $superscript_level ~ ' ' ~ %glyphs{$_} }
for <last_continuation not_last_continuation multi_line empty>
	{ %glyphs{$_} = ' ' x $superscript_level.chars ~ ' ' ~ %glyphs{$_} }

my $glyph_width = %glyphs<empty>.chars + $superscript_level.chars ;

# multiline glyph is on the next level, color accordingly
my $multi_line = %glyphs<multi_line> ;

my %colored_glyphs = $.colorizer.color(%glyphs, @.glyph_colors_cycle[$level]) ;
%colored_glyphs<multi_line> = $.colorizer.color($multi_line, @.glyph_colors_cycle[$level + 1]) ;

%colored_glyphs<__width> = $glyph_width ; #squirel in the width

%colored_glyphs, $glyph_width
}


}

role DDTR::Superscribe
{

my @ssl ;
@ssl[32] = ' ';
@ssl[40, 41, 43, 45, 61, 64] = < ⁽ ⁾ ⁺ ⁻ ⁼ ᶝ > ;
@ssl[48..57] = <⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹> ;
@ssl[97..123] = <ᵃ ᵇ ᶜ ᵈ ᵉ ᶠ ᵍ ʰ ⁱ ʲ ᵏ ˡ ᵐ ⁿ ᵒ ᵖ ᵠ ʳ ˢ ᵗ ᵘ ᵛ ʷ ˣ ʸ ᶻ> ;

method superscribe($text is copy)
{
($text.comb.map: { @ssl[$_.ord] // $_}).join ; 
}

#role
}

