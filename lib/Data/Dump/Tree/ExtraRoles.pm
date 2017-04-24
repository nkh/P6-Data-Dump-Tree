
use Data::Dump::Tree::Enums ;

role DDTR::StringLimiter
{

method limit_string(Str $s, $limit)
{
if $limit.defined && $s.chars > $limit
	{
	$s.substr(0, $limit) ~ '(+' ~ $s.chars - $limit ~ ')'
	}
else
	{
	$s 
	}	
}


} #role

role DDTR::MatchStringLimit does DDTR::StringLimiter
{
has $.match_string_limit is rw = 10 ;

multi method get_header (Match:D $m) 
{
$m.from ==  $m.to - 1 
	?? ($.limit_string(~$m, $.match_string_limit), Q/[/ ~ $m.from ~ Q/]/ , DDT_FINAL)
	!! ($.limit_string(~$m, $.match_string_limit), Q/[/ ~ $m.from ~ '..' ~ $m.to -1 ~ ']', DDT_FINAL) 
}

} #role


role DDTR::MatchDetails does DDTR::StringLimiter 
{

has $.match_string_limit is rw ;

multi method get_header (Match:U $m) { '', '.' ~ $m.^name, DDT_FINAL }
multi method get_header (Match:D $m) 
{
$m.caps.elems
	?? $m.from == $m.to - 1 
		?? ($.limit_string(~$m, $.match_string_limit), Q/[/ ~ $m.from ~ Q/]/)
		!! ($.limit_string(~$m, $.match_string_limit), Q/[/ ~ $m.from ~ '..' ~ $m.to - 1 ~ ']')
			 
	!! $m.from == $m.to - 1 
		?? ($.limit_string(~$m, $.match_string_limit), Q/[/ ~ $m.from ~ Q/]/, DDT_FINAL, DDT_HAS_ADDRESS)
		!! ($.limit_string(~$m, $.match_string_limit), Q/[/ ~ $m.from ~ '..' ~ $m.to -1 ~ ']', DDT_FINAL, DDT_HAS_ADDRESS)

}



multi method get_elements (Match $m)
{
$m.caps.map: -> $p
	{
	my ($k, $v) = $p.kv ;
	( $k, ' => ', $v )
	} 
}

} # role


#`{{
# role to display Match internals, commented out so we don't waste time compiling it

use Data::Dump::Tree ;
role DDTR::MatchObject does DDTR::StringLimiter 
{
# displays type as .Match and details about Match object
has $.match_string_limit is rw ;

multi method get_header (Match:U $m) { '', '.' ~ $m.^name, DDT_FINAL }
multi method get_header (Match:D $m) 
{
$m.caps.elems
	?? ( $.limit_string(~$m, $.match_string_limit), Q/[/ ~ $m.from ~ '..' ~ $m.to ~ '|' ) 
	!! ( $.limit_string(~$m, $.match_string_limit), Q/[/ ~ $m.from ~ '..' ~ $m.to ~ '|', DDT_FINAL, DDT_HAS_ADDRESS ) 
}

multi method get_elements (Match $m) { get_Any_attributes($m) } 

} #role
}}

role DDTR::FixedGlyphs
{
has $.fixed_glyph  = '   ' ;

multi method get_glyphs
{
	{
	last => $.fixed_glyph, not_last => $.fixed_glyph,
	last_continuation => $.fixed_glyph, not_last_continuation => $.fixed_glyph,
	multi_line => $.fixed_glyph, empty => ' ' x $.fixed_glyph.chars, max_depth => '...', 
	filter => $.fixed_glyph,
	}
}

} #role

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

} #role



# scope for @ssl
{

my @ssl ;

for 	(
	< . ( ) + - = @ [ ] | > , (|< · ⁽ ⁾ ⁺ ⁻ ⁼ >, '', ' ', '', ''),
	('0'..'9')        , < ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ >,
	('a'..'z')        , < ᵃ ᵇ ᶜ ᵈ ᵉ ᶠ ᵍ ʰ ⁱ ʲ ᵏ ˡ ᵐ ⁿ ᵒ ᵖ ᵠ ʳ ˢ ᵗ ᵘ ᵛ ʷ ˣ ʸ ᶻ >,
	('A'..'Z')        , < ᴬ ᴮ ᶜ ᴰ ᴱ ᶠ ᴳ ᴴ ᴵ ᴶ ᴷ ᴸ ᴹ ᴺ ᴼ ᴾ ᵠ ᴿ ˢ ᵀ ᵁ ⱽ ᵂ ˣ ʸ ᶻ >, 
	)
	-> $A, $s { @ssl[|$A.map: {.ord}] = |$s	}

role DDTR::SuperscribeBase
{
method do_superscribe($text) { ($text.comb.map: { @ssl[$_.ord] // $_}).join }
}

role DDTR::SuperscribeAddress does DDTR::SuperscribeBase
{
method superscribe($text) { $.do_superscribe($text) }
method superscribe_address($text) {}
}

role DDTR::SuperscribeType does DDTR::SuperscribeBase
{
method superscribe($text) { $.do_superscribe($text) }
method superscribe_type($text) { $.do_superscribe($text) }
}

role DDTR::Superscribe does DDTR::SuperscribeBase
{
method superscribe($text) { $.do_superscribe($text) }
method superscribe_address($text) { $.do_superscribe($text) }
method superscribe_type($text) { $.do_superscribe($text) }
}

# scope for @ssl
}
