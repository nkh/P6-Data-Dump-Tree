
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

#role
}


# scope for @ssl
{

my @ssl ;

for 	(
	< . ( ) + - = @ > , < · ⁽ ⁾ ⁺ ⁻ ⁼ ᶝ >,
	('0'..'9')        , < ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ >,
	('a'..'z')        , < ᵃ ᵇ ᶜ ᵈ ᵉ ᶠ ᵍ ʰ ⁱ ʲ ᵏ ˡ ᵐ ⁿ ᵒ ᵖ ᵠ ʳ ˢ ᵗ ᵘ ᵛ ʷ ˣ ʸ ᶻ >,
	('A'..'Z')        , < ᴬ ᴮ ᶜ ᴰ ᴱ ᶠ ᴳ ᴴ ᴵ ᴶ ᴷ ᴸ ᴹ ᴺ ᴼ ᴾ ᵠ ᴿ ˢ ᵀ ᵁ ⱽ ᵂ ˣ ʸ ᶻ >, 
	)
	-> $A, $s { @ssl[|$A.map: {.ord}] = |$s	}

role DDTR::SuperscribeAddress
{
method superscribe($text) { ($text.comb.map: { @ssl[$_.ord] // $_}).join }
method superscribe_address($text) { ($text.comb.map: { @ssl[$_.ord] // $_}).join }
}

role DDTR::SuperscribeType
{
method superscribe($text) { ($text.comb.map: { @ssl[$_.ord] // $_}).join }
method superscribe_type($text) { ($text.comb.map: { @ssl[$_.ord] // $_}).join }
}

role DDTR::Superscribe
{
method superscribe($text) { ($text.comb.map: { @ssl[$_.ord] // $_}).join }
method superscribe_address($text) { ($text.comb.map: { @ssl[$_.ord] // $_}).join }
method superscribe_type($text) { ($text.comb.map: { @ssl[$_.ord] // $_}).join }
}

# scope for @ssl
}
