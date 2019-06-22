
use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::ExtraRoles ;

use Terminal::ANSIColor ;
use LWP::Simple;
use DOM::Tiny ;

#my @colors = < on_240 on_241 on_244 on_245 on_254 on_230 on_136 on_166 on_160 on_125 on_61 on_33 on_37 on_64 > ;
my @colors = <  on_230 on_136 on_166 on_160 on_125 on_61 on_33 on_37 on_64 > ;
my @colors_fg = < 0 > ;

my $t0 = now ;

my $html = DOM::Tiny.parse(LWP::Simple.get("http://www.google.com"));
#my $html = DOM::Tiny.parse('<div><p id="a" x="3">Test</p><p id="b">123</p></div>');
"parsing: {now - $t0} s".say ;

$t0 = now ;
#ddt $html ;
"rendering: {now - $t0} s".say ;

my $d = Data::Dump::Tree.new:
	:string_type(''),
	:string_quote('"'),
	#:!color,
	#:color_filters[&color_background],
	:color_kbs,
	:header_filters[&header],
	:elements_filters[&elements],
	:nl ;


$t0 = now ;
$d.ddt: $html ;
"rendering: {now - $t0} s".say ;

multi sub header($, \r, DOM::Tiny::HTML::Tag $s, @, (\k, \b, \v, \f, \final, \want_address))
{
k = '<' ~ $s.tag ~ ' ' ~ $s.attr.kv.map(-> $k, $v {"$k=$v"}).join(' ') ~ '>' ;
b = ' ' ;

if $s.children.elems == 1 && $s.children[0] ~~ DOM::Tiny::HTML::Text
	{
	v = $s.children[0].text ; 
	final = True ;
	}
else
	{
	v = Data::Dump::Tree::Type::Nothing ;
	}

f = '' ;
want_address = False ;
}

multi sub elements($, $s, @, @sub_elements)
{
@sub_elements = @sub_elements.grep:
			{
			$_[0] !~~ 
				'%.attr is rw' |
				'$.parent is rw' |
				'$.tag is rw' |
				'$.rcdata is rw'
			}  ;

if $s ~~ DOM::Tiny::HTML::Tag
	{
	my @new_elements ;

	for @sub_elements.grep({ $_[0] ~~ '@.children is rw' }) -> $e
		{
		my ($k, $b, $v, $p) = $e ;
		for $v.List 
			{
			@new_elements.push: $_ ~~ DOM::Tiny::HTML::Text | DOM::Tiny::HTML::Raw 
						?? ('', '', $_.text)
						!! ('', '', $_) ;
			}
		}

	@sub_elements = @new_elements ;
	}
}

multi sub color_background($dumper, $s, $depth, $path, $key, @glyphs, \override_color,  @reset_color)
{
my $color = color(@colors[$depth % @colors.elems]) ~ color(@colors_fg[$depth % @colors_fg.elems]) ;
@reset_color.push: (color('reset'), '' , '') ;

my ($glyph_width, $glyph, $continuation_glyph, $multi_line_glyph, $empty_glyph, $filter_glyph) = @glyphs ;

$glyph              = ($color, |$glyph[1..2]) ;
$continuation_glyph = ($color, |$continuation_glyph[1..2]) ;
$multi_line_glyph   = ($color, |$multi_line_glyph[1..2]) ;
$empty_glyph        = ($color, |$empty_glyph[1..2]) ;
$filter_glyph       = ($color, |$filter_glyph[1..2]) ;

@glyphs = ($glyph_width, $glyph, $continuation_glyph, $multi_line_glyph, $empty_glyph, $filter_glyph) ;
}


