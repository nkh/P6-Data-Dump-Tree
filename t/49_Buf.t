#!/usr/bin/env perl6

use Data::Dump::Tree ;

use Test ;
plan 6 ;

my $r = ddt :get, :!color, Buf ;
is $r.lines.elems, 1, '1 line' or diag $r ;
like $r, /'.Buf:U'/, 'Buf' or diag $r ;

$r = ddt :get, :!color, Buf.new(1, 2, 3) ;
is $r.lines.elems, 4, '4 lines' or diag $r ;
like $r, /'.Buf[3] <array>'/, 'Buf.new' or diag $r ;

$r = ddt :get, :!color, "ddt_remote".encode('utf-8') ;
is $r.lines.elems, 11, '11 lines' or diag $r ;
like $r, /'.utf8[10] <array>'/, 'utf8' or diag $r ;


