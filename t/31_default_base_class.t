#!/usr/bin/env perl6

use Test ;
plan 2 ;

use Data::Dump::Tree ;


class Hermit {}
class LivesUnderRock {}
class Shy is Hermit is LivesUnderRock { has $.in_object }

my $dump = get_dump( Hermit.new , color => False, display_address => False) ;
like $dump, /\.Hermit/, '1 class' ;

$dump = get_dump( Shy.new , color => False, display_address => False) ;
like $dump, /\.Shy \s  \.Hermit \s \.LivesUnderRock/, '3 classes' ;

