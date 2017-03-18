use Data::Dump::Tree ;
use Terminal::ANSIColor ;

my @a = 1 ;
my $b = [< a >] ;
my $list = < a b > ;

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
	] ;

my $d = Data::Dump::Tree.new ;

$d.set_element_name($s[5], 'some list') ;
$d.set_element_name(@a, color('bold yellow on_red') ~ 'some array') ;

$d.dump($s) ;

say "ran for {now - INIT now} s" ;

