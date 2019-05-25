use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Terminal::ANSIColor ;

my $d = Data::Dump::Tree.new: :caller ;
$d.ddt ;
ddt ;

dd [0..1] ;
ddt [1..2] ;
ddt [2..3], :title<title> ;

$d.ddt: [3..4] ;
ddt [4..5], :caller ;
ddt [5..6], :caller, :title<title> ;

my @a = [6..7] ;

ddt @a, :caller ;
ddt @a, :title<title> ;

ddt True, @a, :caller;
ddt True, @a, :title<title> ;

my Int $int = 3 ;
dd $int ;
ddt $int ;

