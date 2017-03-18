use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Terminal::ANSIColor ;

my @a = 1 ;
my $b = [< a >] ;
my $list = < a b > ;
my Str $string = 'XXX' ;

my $s = [
	'text',
	Str,
	12,
	Rat.new(31, 10),
	@a,
	$b,
	@a,
	$b,
	$list,
	$string,
	item($string),
	Mu,
	] ;

my $d = Data::Dump::Tree.new ;

$d.set_element_name($s[0], 'element 0') ;
$d.set_element_name($s[5], 'some list') ;
$d.set_element_name(@a, color('bold yellow on_red') ~ 'some array') ;
$d.set_element_name($string, color('bold yellow on_blue') ~ 'XXX') ;

$d.dump($s) ;
#$d.dump($s, :display_address(DDT_DISPLAY_NONE), :display_info(False)) ;

say "ran for {now - INIT now} s" ;

