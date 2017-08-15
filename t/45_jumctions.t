
#!/usr/bin/env perl6

use Test ;
plan 6 ;

use Data::Dump::Tree ;
my $d = Data::Dump::Tree.new: :!color ;

my $j = 1 | 'a' & True ;
class C { has $.j } ;

my $dump = $d.ddt: :get,C.new(:$j) ;
is $dump.lines.elems, 2, '2 line' or diag $dump ;
like $dump, /'.Junction'/, 'class name' or diag $dump ;


$dump = $d.ddt: :get,$j ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'.Junction'/, 'class name' or diag $dump ;


$dump = $d.ddt: :get,[ ($j) ] ;
is $dump.lines.elems, 2, '2 line' or diag $dump ;
like $dump, /'.Junction'/, 'class name' or diag $dump ;

