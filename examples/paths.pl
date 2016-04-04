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

say "ran for {now - INIT now} s" ;

multi sub header_filter(\r, $s, ($depth, $path, $glyph, @renderings), $)
{
# $path contains a list of [parent, key (as rendered)]

# the rendering of the path information is simplistic, take the parent object
# get a rendering from the dumper, IE an array of 6 elements would give [6]
# apend it to the key, and add it as an extra information to th current
# element. Eg: element 3 of an array of 6 elements would be rendered
# as [6]/3.  

@renderings.append: $glyph ~ 'path:' ~ ($path.map: { $d.get_element_header($_[0])[1] ~ '/' ~ $_[1]}).join(" ") ;
}

