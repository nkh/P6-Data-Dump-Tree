
#!/usr/bin/env perl6

use Data::Dump::Tree ;
my $d = Data::Dump::Tree.new ;

my $j = 1 | 'a' & True ;
class C { has $.j } ;

$d.dump(C.new(:$j)) ;

$d.dump($j) ;

$d.dump([ ($j) ]) ;

