
#!/usr/bin/env perl6

use Test ;
plan 12 ;

use Data::Dump::Tree ;

my $d = Data::Dump::Tree.new: :!color, :width(79), :!display_perl_address ;

my $r = $d.ddt: :get, :title<Bag>, <a b c a>.Bag ;
is($r.lines.elems, 4, '4 dump lines') or diag $r ;
like $r, /'Bag(3)'/, '3 elements' or diag $r ;
like $r, /'a => 2'/, "2 'a's" or diag $r ;
like $r, /'c => 1'/, "1 'c'" or diag $r ;

$r = $d.ddt: :get, :title<Bag>, Bag ;
is($r.lines.elems, 1, '1 dump lines') or diag $r ;
like $r, /\.Bag\:U/, 'undefined Bag' or diag $r ;


$r = $d.ddt: :get, :title<BagHash>, BagHash.new: <a b c a> ;
is($r.lines.elems, 4, '4 dump lines') or diag $r ;
like $r, /'BagHash(3)'/, '3 elements' or diag $r ;
like $r, /'a => 2'/, "2 'a's" or diag $r ;
like $r, /'c => 1'/, "1 'c'" or diag $r ;

$r = $d.ddt: :get, :title<BagHash>, BagHash ;
is($r.lines.elems, 1, '1 dump lines') or diag $r ;
like $r, /\.BagHash\:U/, 'undefined BagHash' or diag $r ;


