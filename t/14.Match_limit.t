#!/usr/bin/env perl6

use Test ;
plan 13 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;

my $d = Data::Dump::Tree.new() ;

my $string = "aaaaa\n" x 4 ;
my $dump ;

$dump = $d.get_dump($string ~~ /.*/, title => 'title') ;
is($dump.lines.elems, 6, '6 lines') or diag $dump ;

$d does DDTR::PerlString ;
$dump = $d.get_dump($string ~~ /.*/) ;
is($dump.lines.elems, 1, '1 line') or diag $dump ;
unlike $dump, /\+/, '' ;

$d does DDTR::MatchStringLimit ;
$dump = $d.get_dump($string ~~ /.*/) ;
is($dump.lines.elems, 1, '1 line') or diag $dump ;
like $dump, /\+14/, '' ;

$d does DDTR::MatchStringLimit(12) ;
$dump = $d.get_dump($string ~~ /.*/) ;
is($dump.lines.elems, 1, '1 line') or diag $dump ;
like $dump, /\+12/, '' ;

$d.match_string_limit = 15 ;
$dump = $d.get_dump($string ~~ /.*/) ;
is($dump.lines.elems, 1, '1 line') or diag $dump ;
like $dump, /\+9/, '' ;

$d does DDTR::MatchDetails(3) ;
$dump = $d.get_dump($string ~~ /(.*)/) ;
is($dump.lines.elems, 2, '2 lines') or diag $dump ;
like $dump, /\+21/, '' or diag $dump ;

$d.match_string_limit = 15 ;
$dump = $d.get_dump($string ~~ /(.*)/) ;
is($dump.lines.elems, 2, '2 lines') or diag $dump ;
like $dump, /\+9/, '' ;

