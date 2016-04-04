#!/usr/bin/env perl6

use Test ;
plan 8 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;

my $d = Data::Dump::Tree.new(width => 79, display_perl_address => False)  does DDTR::MatchDetails ;

my $string = 'aaaaaaaa' ;
my regex xxx  { $<t1> = aa  $<t2> = a  a } ;
my regex yyy { ($<t1> = [aa] ) ($<t2> = a) a } ;

my $dump_1 = $d.get_dump(title => "$string ~~ " ~ 'xxx', $string ~~ m:g/<xxx>/ );
is($dump_1.lines.elems, 9, '9 dump lines') or diag $dump_1 ;

my $dump_2 = $d.get_dump(color => False, title => "$string ~~ " ~ 'yyy', $string ~~ m:g/<yyy>/ );
is($dump_2.lines.elems, 13, '13 dump lines, with capture') or diag $dump_2 ;
like $dump_2, /"0 => aa"/, 'capture' or diag $dump_2 ;

my $dump_3 = $d.get_dump(color => False, 'abc-abc-abc' ~~ / $<string>=( [ $<part>=[abc] ]* % '-' ) /) ;
is($dump_3.lines.elems, 5, '5 lines: title, top match, 3 sub macthes') or diag $dump_3 ;
like $dump_3, /"string => abc-abc-abc"/, 'top match' or diag $dump_3 ;

my regex line { \N*\n }
my $dump_4 = $d.get_dump("abc\ndef\nghi" ~~ /<line>* ghi/, does => (DDTR::PerlString,)) ;
is($dump_4.lines.elems, 3, '3 Match lines') or diag $dump_4 ;

my $dump_5 = $d.get_dump( color => False, regex { \s* '[' (\w+) ']' \h* \n+ } ) ;
is($dump_5.lines.elems, 1, '1 line regex dump') or diag $dump_5 ;
like $dump_5, /'\s* \'[\' (\w+) \']\' \h* \n+'/, 'regex rendering' or diag $dump_5 ;


