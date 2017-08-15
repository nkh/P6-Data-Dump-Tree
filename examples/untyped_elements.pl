#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;

# example of filter to remove the type from the rendering 
# we only remove type IntStr and derivatives in Arrays in this example

role my_role { has $.something is rw } # test that Int+something type displays correctly 
		
my $my_role = my_role.new(:something<more>) ;

my $i = IntStr.new(5, 'but more') but my_role ;
$i.something = "set to something" ;

my $d2 = [1, IntStr.new(2, '2'), IntStr.new(3, 'three'),
		IntStr.new(4, 'but more') but my_role,
		$i,
		] ;

ddt $d2 ;
ddt $d2, :elements_filters[&untype] ;

my class NoType { has Int $.val ; method ddt_get_header { $.val, '   ', DDT_FINAL } }

multi sub untype($dumper, Array $s, $, @elements)
{
@elements .= map: { $_[2].^name ~~ /^IntStr/ ?? (|$_[0,1], NoType.new(:val($_[2]))) !! $_ }	
}

