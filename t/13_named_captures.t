#!/usr/bin/env perl6

use Test ;
plan 1 ;

use Data::Dump::Tree;

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

my $d = get_dumper( {does => ( DDTR::MatchDetails, DDTR::PerlString) } ) ;

my $m = $contents ~~ /<section>*/ ;

my $dump_5 = $d.get_dump($m, 'config', {width => 115}) ;
is($dump_5.lines.elems, 37, '37 lines of section parsing') or diag $dump_5 ;


