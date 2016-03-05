#!/usr/bin/env perl6

use Data::Dump::Tree;


my $d = Data::Dump::Tree.new does DDTR::MatchDetails ;
$d does DDTR::PerlString ;

my $dump_1 = $d.get_dump('aaaaa' ~~ m:g/ $<token> = a $<T2> = a/);
$dump_1.say ;

my $dump_2 = $d.get_dump('aaaaa' ~~ m:g/ ($<token> = a) ($<T2> = a) a/);
$dump_2.say ;

my $dump_3 = $d.get_dump('abc-abc-abc' ~~ / $<string>=( [ $<part>=[abc] ]* % '-' ) /) ;
$dump_3.say ;


my regex line { \N*\n }
my $m = "abc\ndef\nghi" ~~ /<line>* ghi/ ;

my $dump_4 = $d.get_dump($m) ;
$dump_4.say ;


my regex header { \s* '[' (\w+) ']' \h* \n+ }
my regex identifier  { \w+ }
my regex kvpair { \s* <key=identifier> '=' <value=identifier> \n+ }
my regex section {
    <header>
    <kvpair>*
}

my $contents = q:to/EOI/;
    [passwords]
        jack=password1
        joy=muchmoresecure123
    [quotas]
        jack=123
        joy=42
EOI

$m = $contents ~~ /<section>*/ ;

#Todo: parse bareword regex
#my $dump_5 = $d.get_dump([ section, $m ], title => 'config', display_perl_address => True) ;


my $header = regex { \s* '[' (\w+) ']' \h* \n+ }
my $dump_5 = $d.get_dump([ $header, $m ], title => 'config', display_perl_address => True) ;
$dump_5.say ;

