use Test ;
plan 8 ;

use Data::Dump::Tree ;

my $d = Data::Dump::Tree.new: :!color, :width(79), :!display_perl_address ;

my $r = $d.ddt: :get, :title<Slip>, Slip ;
is($r.lines.elems, 1, '1 dump line') or diag $r ;
like $r, /'.Slip:U'/, 'undefined Slip' or diag $r ;

$r = $d.ddt: :get, :title<Slip>, ().Slip ;
is($r.lines.elems, 1, '1 dump line') or diag $r ;
like $r, /'(0).Slip'/, 'empty Slip' or diag $r ;

$r = $d.ddt: :get, :title<Slip>, (1,2,3).Slip ;
is($r.lines.elems, 4, '4 dump lines') or diag $r ;
like $r, /'(3).Slip'/, '3 elements' or diag $r ;
like $r, /'0 = 1'/, "first line" or diag $r ;
like $r, /'2 = 3'/, "last line" or diag $r ;


