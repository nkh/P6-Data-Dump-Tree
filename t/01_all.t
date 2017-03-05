#!/usr/bin/env perl6

use Test ;
plan 1 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;

class Strings
{

method ddt_get_header { "say something about this class\nmultiline", '.' ~ self.^name ~ "\n multiline classes" }
method ddt_get_elements 
{ 
	('', '', 'has no name'), 
	("very very long\nexplanation on multiple lines\n", '', "many lines\n" x 5), 
	('single-long', ': ', 'x' x 300), 
	('multiple-long', ': ', 'x' x 300 ~ "\n" ~ 'y' x 200), 

	('12345678901234567890123456789012345', '', [ 1, {a => 3} ]),
	("12345678901234567890123456789012345\nxxx", '', 'test'),

	('coefficient', ' = ', 1), 
}

#class
}

class GenericClass { has $.x ; has $!z ; method zz {} }

class Dog { has $.name; }
role DescribeDog
{

multi method get_header (Dog $d) 
{
'Woof! ', '.Dog (but this one is vagrant, no address)', DDT_NOT_FINAL, DDT_HAS_NO_ADDRESS 
}

multi method get_elements (Dog $d) { (q/the dog's name is/, ': ', $d.name), }

}

class Hermit {}
class LivesUnderRock {}

class Shy is Hermit is LivesUnderRock { has $.in_object }
role DescribeShy { multi method get_elements (Shy $d) { ('Role{DescribeShy} ', '',  1), } }
role DescribeShyFinal { multi method get_header (Shy $d) { 'Role{DescribeShyFinal} ', '.' ~ $d.^name, DDT_FINAL } }

class Mangled
{
method ddt_get_elements { ('inner structure', ' => ', [123, 456]),  }
}

class Table
{

has Str $!title = 'mail addresses:' ;
has $!int = 1 ;

method ddt_get_elements 
{
my @e ;

try 
	{
	require Text::Table::Simple <&lol2table> ;

	my @columns = <id name email>;
	my @rows    = ([1,"John Doe",'johndoe@cpan.org'], [2,'Jane Doe','mrsjanedoe@hushmail.com'],);
	my @table = lol2table(@columns,@rows);

	@e = ($!title, '', @table.join("\n")), |get_Any_attributes(self),  ;
	}

$! ?? (('DDT exception', ': ', "$!"),)  !! @e ;
}

#class
}

# ------------- test --------------

my $d = Data::Dump::Tree.new ;
$d does DescribeDog ;
$d does DescribeShyFinal ;

my $dump = $d.get_dump(
		get_test_structure(),
		title =>'test data',
		caller => True,
		max_depth => 3,
		display_perl_address => True,
		width => 75,
		);

todo 'working on difference between builds' ;
is( $dump.lines.elems, 88, 'all lines') or diag $dump ;

# ------------- helpers  -------------

sub get_test_structure
{
my $nil is default(Nil) = Nil; 
my @a = 1 ;
my $b = [< a >] ;
my $list = < a b > ;
my $sub = sub (Int $a, Str $string) {}
my Routine $routine ;

my $s = [
	'text',
	Str,
	12,
	Int,
	Rat.new(31, 10),
	$sub,
	$routine,
	[],
	@a,
	$b,
	@a,
	$b,
	$list,
	{
		default_nil => $nil,
		Nil => Nil,
		a => 1,
		b => 'string',
	},
	Cool.new(),
	Table.new(),
	GenericClass.new(:x(5), :z('hi there')),
	Mangled.new(),
	Dog.new(name => 'fido'), 
	Shy.new(secret => 'I will not say'),
	Strings.new(),
	#regex
	'aaa' ~~ m:g/(a)/,
	] ;

$s ;
}


