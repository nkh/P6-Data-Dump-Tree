
role DDTR::ColorBlobLevel
{

method custom_setup
{
$.color = False ; # to let glyph colors bleed to the end  of the line
$.glyph_filters.push: &color_blob ;
} 

use Terminal::ANSIColor ;

has @.blob_colors is rw = <  on_230 on_136 on_166 on_160 on_125 on_61 on_33 on_37 on_64 > ;
has @.blob_colors_fg is rw = < 0 > ;

my $reset_color = (color('reset'), '' , '') ;

multi sub color_blob($d, $, $depth, $, $, @glyphs, @reset_elements)
{
# return the glyph colored per level, it could be per type, path, ...

my $color = color(
		$d.blob_colors[$depth % $d.blob_colors.elems]) ~
		color($d.blob_colors_fg[$depth % $d.blob_colors_fg.elems]
		) ;

@glyphs = @glyphs[0], |@glyphs[1..*-1].map({ ($color, |$_[1..2]) }) ;

@reset_elements.push: $reset_color ;
}

} # role


