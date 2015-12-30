#!/usr/bin/env perl6

use Test ;
use Data::Dump::Tree ;

plan 3 ;

class HasNothing
{

#method ddt_get_header { ('', '.' ~ self.^name) } # use default
method ddt_get_elements 
{ 
	[ 
	('nothing', '', Data::Dump::Tree::Type::Nothing),
	('text', ' ', 'text'),
	]
}

#class
}

my $d = Data::Dump::Tree.new(color => False) ;
my $dump = $d.get_dump(HasNothing.new()) ;

is $dump.lines.elems, 3, '3 lines output' ;
like $dump, /nothing\n/, 'nothing as no value' ;
like $dump, /\.Str\n/, 'something has value' ;


