
use Test ;
use Data::Dump::Tree ;

plan 11 ;

class edible { has $taste = 1 / 3 ; }
class Fruit is edible { has $.seeds }
role Tomato {has $.color = 'red'} ;

role E { has Fruit $fruit = Fruit.new(:seeds(3)) but Tomato ; }

for 
	(
	(1, 2, 3),
	[1..3],
	%( <a 1 b 2 > ),
	42,
	'string',
	False,
	IntStr.new(42, 'fourty two'),
	1/3,
	(1..3),
	(1..*),
	(1 => []),
	)
	{
	my $dump = get_dump $_ but E, :!color ;
	like $dump, /'$.color +{Tomato}'/, 'role done' or diag $dump ;
	}


