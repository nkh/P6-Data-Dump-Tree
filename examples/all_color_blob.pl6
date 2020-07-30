#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::Enums ;

# -------------------------------------------------------
# example with different types of elements and some roles
# -------------------------------------------------------

class Strings
{
# a class that defines DDT specific methods

method ddt_get_header { "say something about this class\nmultiline", '.' ~ self.^name ~ "\nmultiline classes" }

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

# class with elements and methods but has not type handler nor DDT specific methods
class GenericClass { has $.x ; has $!z ; method zz {} }
role GenericRole { has $.role }
role Whatnot { has $.whatnot is rw = 13 }

# class with role that can be added to DDT
class Dog { has $.name; }
role DescribeDog
{

multi method get_header (Dog $d)
{
'Woof! ', '.Dog (but this one is vagrant, no address)', DDT_NOT_FINAL, DDT_HAS_NO_ADDRESS
}

multi method get_elements (Dog $d) { (q/the dog's name is/, ': ', $d.name), }

}


# class with inheritance and with 2 different roles that can be added to DDT
class Hermit {}
class LivesUnderRock {}
class Shy is Hermit is LivesUnderRock { has $.in_object }

# hide all internals
role DescribeShy { multi method get_elements (Shy $d) { } }

#hide itself behind a scalar
role DescribeShyFinal { multi method get_header (Shy $d) { 'Role{DescribeShyFinal} ', '.' ~ $d.^name, DDT_FINAL } }


# class which returns computed "internal" representation
class Mangled
{
method ddt_get_elements { ('inner structure', ' => ', [123, 456]),  }
}

# class which returns a text representation, in the form of a table if Text::Table::Simple is installed
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
	my $table = lol2table(@columns, @rows).join("\n") ;

	# Add some fancy data rendering
	# on the left side row number 1..7, then 3 separate rendering side by side
	# DVO removes the type of the fancy rendering
	use Data::Dump::Tree::MultiColumns ;
	use Data::Dump::Tree::ExtraRoles ;

	my $element = [1, [2, [3, 4]]] ;
	my @data = $element, ([6, [3]],), $element ;

	my $columns = get_columns (1..7), |(@data.map({ get_dump_lines_integrated $_, :does[DDTR::Superscribe] })) ;

	@e = ($!title, '', $table), ('fancy table data', ':', DVO($columns)), |get_attributes(self),  ;
	}

$! ?? (('DDT exception', ': ', "$!"),)  !! @e ;
}

#class
}

# ------------- test --------------

use Terminal::ANSIColor ;
my @colors = < on_22 on_17 on_20 on_52 on_56 on_92 > ;
my $color_filter_type = 1 ;

ddt
	get_test_structure(),
	:title<test data>,
	:caller,
	:display_perl_address,
	:width(75),
	:does[DescribeDog, DescribeShyFinal], #DescribeShy
	:max_depth(3) ;

ddt
	get_test_structure(),
	:title<test data>,
	:!color,
	:glyph_filters[&color_background],
	:caller,
	:display_perl_address,
	:width(75),
	:does[DescribeDog, DescribeShyFinal], #DescribeShy
	:max_depth(3) ;

multi sub color_background($dumper, $s, $depth, $path, $key, @glyphs, @reset_color)
{
my $color = '' ;

if $color_filter_type == 1
	{
	$color = color(@colors[$depth % @colors.elems]) ;
	}
elsif $color_filter_type == 2
	{
	# level colored as previous level
	if $depth != 2 | 3 | 5 
		{
		$color = color(@colors[$depth % @colors.elems]) ;
		}
	}
else
	{
	if $depth == 2 || $depth > 5 
		{
		$color = color(@colors[$depth % @colors.elems]) ;
		}	
	else
		{
		$color = color('reset') ;
		}	
	}

@reset_color.push: (color('reset'), '' , '') ;

my ($glyph_width, $glyph, $continuation_glyph, $multi_line_glyph, $empty_glyph, $filter_glyph) = @glyphs ;

$glyph              = ($color, |$glyph[1..2]) ;
$continuation_glyph = ($color, |$continuation_glyph[1..2]) ;
$multi_line_glyph   = ($color, |$multi_line_glyph[1..2]) ;
$empty_glyph        = ($color, |$empty_glyph[1..2]) ;
$filter_glyph       = ($color, |$filter_glyph[1..2]) ;

@glyphs = ($glyph_width, $glyph, $continuation_glyph, $multi_line_glyph, $empty_glyph, $filter_glyph) ;
}
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
	(GenericClass.new(:x(5), :z('hi there')) does GenericRole) but Whatnot,
	Mangled.new(),
	Dog.new(name => 'fido'),
	Shy.new(secret => 'I will not say'),
	Strings.new(),
	#regex
	'aaa' ~~ m:g/(a)/,
	] ;

$s ;
}


