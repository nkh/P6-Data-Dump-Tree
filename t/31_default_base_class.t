#!/usr/bin/env perl6

use Test ;
plan 2 ;

use Data::Dump::Tree ;


class Hermit {}
class LivesUnderRock {}
class Shy is Hermit is LivesUnderRock { has $.in_object }

my $dump = dump( Hermit.new , Nil, {color => 0, display_address => 0}) ;
like $dump, /\.Hermit\n/, '1 class' ;

$dump = dump( Shy.new , Nil, {color => 0, display_address => 0}) ;
like $dump, /\.Shy \s  \.Hermit \s \.LivesUnderRock\n/, '3 classes' ;

