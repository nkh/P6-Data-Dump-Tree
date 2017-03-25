use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Terminal::ANSIColor ;

my @a = 1 ;
my $b = [< a >] ;
my $list = (<a>, $b) ;

my $s = [
	'text',
	@a,
	$b,
	@a,
	$b,
	$list,
	] ;

my $d = Data::Dump::Tree.new ;

# add a name to some containers to make it easier to see them in the dump
# the name is displayed after the address (and the link to an address) so 
# addresses must be enabled. Enabling address display is recommended when
# dumping a structure with linked data

$d.set_element_name($s[2], 'list b') ;

# color the name
$d.set_element_name(@a, color('bold yellow on_red') ~ 'some array') ;

$d.dump($s) ;

say "ran for {now - INIT now} s" ;

