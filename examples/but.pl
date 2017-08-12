#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;

role my_role { has $.something is rw } # test that Int+something type displays correctly 
		
my $my_role = my_role.new(:something<more>) ;

my $i = IntStr.new(4, 'but more') but my_role ;
$i.something = "set to something" ;

my $data = [1, IntStr.new(2, '2'), IntStr.new(3, 'three'),
		IntStr.new(4, 'but more') but my_role,
		IntStr.new(4, 'but more') but my_role.new(:something<more>),
		$my_role,
		IntStr.new(4, 'but more') but $my_role,
		$i,
		] ;

ddt $data, :nl ;

#more examples, specially the one demonstrating that assigning to an 
# @array does just that, so don not @ = @+role, use binding or scalars

my role MaxLines { has $.max_lines is rw = 0 } 

my @a = [1..2] ;
my $current_block = [1..2] but MaxLines ;
my @b = [1..3] but MaxLines ;
my $b = @a but MaxLines ;
my @b_bind := [1..3] but MaxLines ;
@b_bind.max_lines = 7 ;

my @c = @a but MaxLines ;

my @d2 does MaxLines = [1..2] ;
@d2.max_lines = 1 ;

my @d22 = @b_bind ;
my @d33 := @b_bind ;

my @d3 does MaxLines = @b_bind ;
my @d4 does MaxLines = [1..2] ;

ddt :flat(0), (@a, $current_block, @b, $b, @b_bind, @c, @d2, @d22, @d33,  @d3, @d4) ;

