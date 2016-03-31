
use Data::Dump::Tree ;
use Data::Dump::Tree::Diff ;
use Data::Dump::Tree::ExtraRoles ;

my $d = Data::Dump::Tree.new() does DDTR::Diff ;

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
my %df1 = M => $match1, A => %xxx, B => %(< a 1 b 2 c 3 >), C => %(< a 1 b 2 c 3 >),
		D => 3/10, E => 1, F => 2, G => %(< a 1 >), o => $o1 ;

my %df2 = M => $match2, A => %xxx, B => %xxx,               C => %(< a 1 b 2 c 3 >),
		D => 'hi', E => 2, F => %(< a 1 b 2 c 3 >), o => $o2 ;

$d.dump_synched(%df1, %df2, compact_width => True, does => (DDTR::MatchDetails,), color_glyphs => True) ;
''.say ;
$d.dump_synched(%df1, %df2, compact_width => True, does => (DDTR::MatchDetails,), color_glyphs => True,
		diff_glyphs => False, remove_eq => True, remove_eqv => True,
		rhs_header_filters => (&rhs_header_filter,),
		rhs_title => <rhs_title>,
		title => <title>,
		) ;

multi sub rhs_header_filter(\r, Match $s, ($depth, $path, $glyph, @renderings), $)
{
#@renderings.append: $glyph ~ '' ;
r = Data::Dump::Tree::Type::Nothing ;
}


