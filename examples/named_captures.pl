#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;

my $d0 = Data::Dump::Tree.new(display_address => False) ;
$d0 does (DDTR::PerlString, DDTR::FixedGlyphs) ;

my $dump_0 = $d0.get_dump('aaaaa' ~~ m:g/ $<token> = a $<T2> = a/);
$dump_0.say ;

my $d = Data::Dump::Tree.new(display_address => False) does DDTR::MatchDetails(40) ;
$d does (DDTR::PerlString, DDTR::FixedGlyphs) ;

#my $d = Data::Dump::Tree.new does (DDTR::MatchDetails(40), DDTR::PerlString, DDTR::FixedGlyphs) ;

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

my $header = regex { \s* '[' (\w+) ']' \h* \n+ }

my $dump_5 = $d.get_dump([ $header, $m ], title => 'config') ;
$dump_5.say ;

