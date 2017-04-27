#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;

# ----------------------------------------------------
# display result of regex matching with named captures
# ----------------------------------------------------

# displaying the addresses adds no value to the dump, disable it
my $d = Data::Dump::Tree.new(display_address => DDT_DISPLAY_NONE) does DDTR::MatchDetails(40) ;

$d.dump('aaaaabx' ~~ m:g/ ($<token> = a) ($<T2> = a) ./, title => '"aaaaabx" ~~ m:g/ ($<token> = a) ($<T2> = a) ./');

$d.dump('abc-abc-abc' ~~ / $<string>=( [ $<part>=[abc] ]* % '-' ) /, title => '"abc-abc-abc" ~~ / $<string>=( [ $<part>=[abc] ]* % "-" ) /') ;


# larger example
my regex header { \s* '[' (\w+) ']' \h* \n+ }
my regex identifier  { \w+ }
my regex kvpair { \s* <key=identifier> '=' <value=identifier> \n+ }
my regex section {
    <header>
    <kvpair>*
}

my $config = q:to/EOI/;
    [passwords]
        jack=password1
        joy=muchmoresecure123
    [quotas]
        jack=123
        joy=42
EOI

my $regex = regex { \s* '[' (\w+) ']' \h* \n+ }

my $match = $config ~~ /<section>*/ ;

$d.dump( { :$config, :$regex, :$match }, title => 'config parsing', elements_filters => (&sorter,)) ;

# filter display the elements in a specific order
# for the only hash that will be in the dump
# 	for names <config regex match>
# 		get the element in hash where the key is the name
#
multi sub sorter(Hash $s, $, @sub_elements)
{
my %h = @sub_elements.map: -> $e { $e[0] => $e } ;
@sub_elements = <config regex match>.map: -> $e { %h{$e} }
}

say "ran for {now - INIT now} s" ;

