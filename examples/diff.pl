
use Data::Dump::Tree ;
use Data::Dump::Tree::Diff ;
use Data::Dump::Tree::ExtraRoles ;

my $d = Data::Dump::Tree.new() does DDTR::Diff ;

class O {} 
my $o = O.new ;

my Str $a = 'string' ;
my Str $b = 'string2' ;

my @s1 = [ ( 1, "abc\ndef\nfin", 3, $o), $b, < 3 2 >, [ <a b> ] ] ;
my @s2 = [ ( 1, 2, 4, $o), $a, 1, < A B > ] ;

#$d.dump_synched(@s1, @s1) ;
#$d.dump_synched(@s1, @s2, display_perl_address => True) ;
#$d.dump_synched(@s2, @s1) ;

my $string1 = 'aaaaaaa' ;
my $string2 = 'aaaaaaaa' ;
my regex xxx  { $<t1> = aa  $<t2> = a  a } ;
my regex yyy { ($<t1> = [aa] ) ($<t2> = a) a } ;
my $match1 = $string1 ~~ m:g/<yyy>/ ;
my $match2 = $string2 ~~ m:g/<yyy>/ ;

my %xxx = %(< a 1 b 2 c 3 >), d => %( x => %( < y 1 >)), e => 1 ;
my %df1 = M => $match1, A => %xxx, B => %(< a 1 b 2 c 3 >), C => %(< a 1 b 2 c 3 >), D => 3/10, E => 1, F => 2, G => %(< a 1 >) ;
my %df2 = M => $match2, A => %xxx, B => %xxx,               C => %(< a 1 b 2 c 3 >), D => 'hi', E => 2, F => %(< a 1 b 2 c 3 >) ;

$d.dump_synched(%df1, %df2, compact_width => True, does => (DDTR::MatchDetails,), color_glyphs => True) ;
''.say ;
$d.dump_synched(%df1, %df2, does => (DDTR::MatchDetails,), diff_glyphs => False, compact_width => True, remove_eq => True, remove_eqv => True, color_glyphs => True) ;

#diff filter

my $s3 = %(< a 1 b 2 c 3 d 5 e 6>) ;
my $s4 = %(< a 1 c 3 e 4 f 5>) ;
#$d.dump_synched($s3, $s4, width => 79, diff_synch_filter => &diff_synch_filter) ;

sub diff_synch_filter(
	$s1, @sub_elements1, $cd1, @renderings1, $cont_glyph1,
	@diff_glyphs,
	$s2, @sub_elements2, $cd2, @renderings2, $cont_glyph2
	)
{

#`{{
# by default DDTR::Diff will synch Hash keys
if $s1 ~~ Hash and $s2 ~~ Hash
	{
	my %h1 = @sub_elements1.map: { $_[0] => $_ }  ;
	($s2.keys (-) $s1.keys).map: { %h1{$_.key} = ($_.key, ' (synch)', Data::Dump::Tree::Type::Nothing.new) } ;
	@sub_elements1 = %h1.sort(*.key)>>.kv.map: -> ($k, $v) { $v }

	my %h2 = @sub_elements2.map: { $_[0] => $_ }  ;
	($s1.keys (-) $s2.keys).map: { %h2{$_.key} = ($_.key, ' (synch)', Data::Dump::Tree::Type::Nothing.new) } ;
	@sub_elements2 = %h2.sort(*.key)>>.kv.map: -> ($k, $v) { $v }
	}
}}

}


#Todo: filter per dumper
#$d.dump_synched(@s2, @s1, filters => (&my_filter,)) ;

sub my_filter($s, DDT_FOOTER, ($depth, $filter_glyph, @renderings))
	{
	@renderings.append: $filter_glyph ~ "FOOTER for {$s.^name}" ;
	}

