use Data::Dump::Tree ;

class Tomatoe{ has $.color ;}
class Potatoe{}

my $s =
	[
	Tomatoe,
	[ [ Tomatoe,], ],
	123,
	Tomatoe.new( color => 'green'),
	{
		first => [ < a b c > ],
		second => < a b c >,
		third => { a => 1, b => 2,},
	},
	0.5,
	] ;


my $d = Data::Dump::Tree.new ;
$d.dump($s, :keep_paths, header_filters => (&header_filter,)) ;

multi sub header_filter(\r, $s, ($depth, $path, $glyph, @renderings), $)
{
@renderings.append: $glyph ~ 'path:' ~ ($path.map: { $d.get_element_header($_)[1]}).join(" ") ;
}

