
use Data::Dump::Tree ;

# get role to show diff
use Data::Dump::Tree::Diff ;

# get role to show Match details
use Data::Dump::Tree::ExtraRoles ;

# --------------------------------
# diff between two data strings
# --------------------------------

my (@df1, @df2) := get_data_structures() ;

# dumper with diff role
my $d = Data::Dump::Tree.new does DDTR::Diff ;

# show full structures with glyphs showing what differences exists
$d.dump_synched: @df1, @df2, :compact_width, :does(DDTR::MatchDetails,), :color_glyphs ;

''.say ;

# show only the differences between the structures
$d.dump_synched: @df1, @df2, :compact_width, :does(DDTR::MatchDetails,), :color_glyphs,
		
		# show only difference
		:!diff_glyphs, :remove_eq, :remove_eqv,
		
		# give names to the data structures
		:title<title>,
		:rhs_title<rhs_title> ;

say "ran for {now - INIT now} s" ;



# --------------- helpers --------------

sub get_data_structures
{
my Str $s1 = "abccdefghijkln" ;
my Str $s2 = "abcxdefghoijkn" ;

return ($s1.comb(1), $s2.comb(1)) ;
}


