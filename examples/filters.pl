use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Terminal::ANSIColor ;

my $s =
	[
	123,
	{
		first => [ < a b c > ],
		second => < a b c >,
		third => { a => 1, b => 2,},
	},
	Int,
	1.234,
	] ;


my $d = Data::Dump::Tree.new ;
$d does DDTR::QuotedString ;

multi sub my_filter(Int $s, DDT_HEADER, ($depth, $glyph, @renderings), (\k, \v, \f, \final, \want_address))
{
@renderings.append:
	$glyph ~
	#color('bold white on_yellow') ~
	"Int HEADER " ~ k ~ " - " ~ (v // v.^name) ~ " - " ~ f ~ ' - @depth' ~ $depth ;

#k = 'filter key' ;
#v = 'filter value' ;
#f = 'filter type'
}

multi sub my_filter($s, DDT_HEADER, ($depth, $glyph, @renderings), ($k, $v, $f, $final, $want_address))
{
@renderings.append: $glyph ~ "HEADER " ~ $k ~ " - " ~ ($v // $v.^name) ~ " - " ~ $f ~ ' - @depth' ~ $depth ;
}

multi sub my_filter(Hash $s, DDT_SUB_ELEMENTS, ($depth, $glyph, @renderings), (@sub_elements))
{
@renderings.append: $glyph ~ "SUB ELEMENTS" ;
#@sub_elements = (('key', 'value'),) ;
}

multi sub my_filter($s, DDT_FOOTER, ($depth, $filter_glyph, @renderings))
{
@renderings.append: $filter_glyph ~ "FOOTER for {$s.^name}" ;
}

$d.dump($s, filters => (&my_filter)) ;


