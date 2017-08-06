#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;

role my_role { has $.something is rw } # test that Int+something type displays correctly 
		
my $my_role = my_role.new(:something<more>) ;

my $i = IntStr.new(4, 'but more') but my_role ;
$i.something = "set to something" ;

my $d2 = [1, IntStr.new(2, '2'), IntStr.new(3, 'three'),
		IntStr.new(4, 'but more') but my_role,
		IntStr.new(4, 'but more') but my_role.new(:something<more>),
		$my_role,
		IntStr.new(4, 'but more') but $my_role,
		$i,
		] ;

ddt $d2 ;
