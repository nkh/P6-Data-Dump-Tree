
use Data::Dump::Tree ;

# get role to show diff
use Data::Dump::Tree::Diff ;

# get role to show Match details
use Data::Dump::Tree::ExtraRoles ;

# --------------------------------
# diff between two data structures
# --------------------------------

my (%df1, %df2) := get_data_structures() ;

# dumper with diff role
my $d = Data::Dump::Tree.new() does DDTR::Diff ;

# show full structures with glyphs showing what differences exists
$d.dump_synched(%df1, %df2, compact_width => True, does => (DDTR::MatchDetails,), color_glyphs => True) ;

''.say ;

# show only the differences between the structures
$d.dump_synched(%df1, %df2, compact_width => True, does => (DDTR::MatchDetails,), color_glyphs => True,
		
		# show only difference
		diff_glyphs => False, remove_eq => True, remove_eqv => True,
		
		# give names to the data structures
		rhs_title => <rhs_title>,
		title => <title>,
		) ;

say "ran for {now - INIT now} s" ;



# --------------- helpers --------------

sub get_data_structures
{
# define some elements to put in the data structures
class O { has $.a ; }  
multi infix:<eqv>(O $l, O $r) { True }
my $o1 = O.new(a => 1) ;
my $o2 = O.new(a => 2) ;

my $string1 = 'aaaaaaa' ;
my $string2 = 'aaaaaaaa' ;
my regex xxx { ($<t1> = [aaa] ) ($<t2> = a) } ;
my regex yyy { ($<t1> = [aa] ) ($<t2> = a) a } ;
my $match1 = $string1 ~~ m:g/<xxx>/ ;
my $match2 = $string2 ~~ m:g/<yyy>/ ;

my %xxx = %(< a 1 b 2 c 3 >), d => %( x => %( < y 1 >)), e => 1 ;

# define the data structures
my %df1 = M => $match1, A => %xxx, B => %(< a 1 b 2 c 3 >), C => %(< a 1 b 2 c 3 >),
		D => 3/10, E => 1, F => 2, G => %(< a 1 >), o => $o1 ;

my %df2 = M => $match2, A => %xxx, B => %xxx,               C => %(< a 1 b 2 c 3 >),
		D => 'hi', E => 2, F => %(< a 1 b 2 c 3 >), o => $o2 ;

return (%df1, %df2) ;
}


