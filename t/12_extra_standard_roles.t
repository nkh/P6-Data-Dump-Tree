#!/usr/bin/env perl6

use Test;
use Data::Dump::Tree;

plan 9 ;

my $d_1 = Data::Dump::Tree.new ;

my $dump_1 = $d_1.get_dump("nl\nnl\nnl") ;

is $dump_1.lines.elems, 5, 'multi lines' or diag $dump_1 ;

my $d_2 = Data::Dump::Tree.new does DDTR::PerlString ;
my $dump_2 = $d_2.get_dump("nl\nnl\nnl") ;

is $dump_2.lines.elems, 1, '1 lines' or diag $dump_2 ;

my $d_3 = Data::Dump::Tree.new ;
my $dump_3 = $d_3.get_dump(sub{}) ;

like $dump_3, /anon/, 'default sub dump' ;
is $dump_3.lines.elems, 1, 'default sub lines' or diag get_dump $dump_3;

$d_3 does DDTR::PerlSub ;
$dump_3 = $d_3.get_dump(sub{}) ;

unlike $dump_3, /sub \(\)/, 'silent sub dump' ;
is $dump_3.lines.elems, 1, 'silent sub lines' ;


grammar my_grammar {
    token TOP { 'fuu' \s+ <bar_t> \s+ <baz_t> \s <buu_t> };
    token buu_t { <char_t>+ };
    token bar_t { <char_t>+ };
    token baz_t { <char_t>+ };
    token char_t { \S };
};

my $d_4 = Data::Dump::Tree.new does DDTR::MatchDetails ;

my $dump_4 = $d_4.get_dump(my_grammar.parse("fuu \n\nbart baz x"));
like $dump_4, /0\.\.16/, 'Grammar Match' ;
is $dump_4.lines.elems, 18, 'Grammar Match lines' or diag get_dump $dump_4;

my $dump_4_2 = $d_4.get_dump('aaaaa' ~~ m:g/(aa)/);
is $dump_4_2.lines.elems, 3, 'terminal Match lines' or diag get_dump $dump_4_2;

#`{{{
my $d_5 = Data::Dump::Tree.new does DDTR::MatchDetails ;
my $dump_5 = $d_5.get_dump([Match, Grammar]);
is $dump_5.lines.elems, 0, 'type object matches' or diag get_dump $dump_5;
}}}
