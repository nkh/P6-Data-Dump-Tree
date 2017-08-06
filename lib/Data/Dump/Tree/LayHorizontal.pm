
use Data::Dump::Tree::Horizontal ;

unit module Data::Dump::Tree::LayHorizontal ;

=begin pod

=NAME
Date::Dump::Tree::LayHorizontal - layout data in horizontal or column mode

=SYNOPSIS
	use Data::Dump::Tree ;
	
	ddt $some_complex_data, :flat(Array) ; 
		
See I<examples/flat.pl> in the distribution for multiple examples

=DESCRIPTION

Renders data elements matching :flat conditions in a horizontal or columns
layout ; this allows you to mix vertical and horizontal layout in the same
rendering.

=head1 Horizontal layout 

 Vertical layout:
 (6) @0
 ├ 0 = [3] @1
 │ ├ 0 = [2] @2
 │ │ ├ 0 = 1.Int
 │ │ └ 1 = [2] @3
 │ │   ├ 0 = 2.Int
 │ │   └ 1 = [2] @4
 │ │     ├ 0 = 3.Int
 │ │     └ 1 = 4.Int
 │ ├ 1 = (1) @5
 │ │ └ 0 = [2] @6
 │ │   ├ 0 = 6.Int
 │ │   └ 1 = [1] @7
 │ │     └ 0 = 3.Int
 │ └ 2 = [2] §2
 ├ 1 = [2] @9
 │ ├ 0 = [2] §2
 │ └ 1 = [2] §2
 ├ 2 = [2] @12
 │ ├ 0 = [2] @13
 │ │ ├ 0 = 1.Int
 │ │ └ 1 = 2.Int
 │ └ 1 = .Seq(11) @14
 │   ├ 0 = [2] §2
 │   ├ 1 = [2] §2
 │   ├ 2 = [2] §2
 │   ├ 3 = [2] §2
 │   ├ 4 = [2] §2
 │   ├ 5 = [2] §2
 │   ├ 6 = [2] §2
 │   ├ 7 = [2] §2
 │   ├ 8 = [2] §2
 │   ├ 9 = [2] §2
 │   └ ...
 ├ 3 = [10] @25
 │ ├ 0 = [2] §2
 │ ├ 1 = [2] §2
 │ ├ 2 = [2] §13
 │ ├ 3 = [3] @29
 │ │ ├ 0 = 1.Int
 │ │ ├ 1 = 2.Int
 │ │ └ 2 = 3.Int
 │ ├ 4 = [2] §2
 │ ├ 5 = [2] §2
 │ ├ 6 = [2] §2
 │ ├ 7 = [2] §2
 │ ├ 8 = [2] §2
 │ └ 9 = [2] §2
 ├ 4 = [2] §12
 └ 5 = 12345678.Str

 dd's output for comparison:

 $($[[1, [2, [3, 4]]], ([6, [3]],), [1, [2, [3, 4]]]], [[1, [2, [3, 4]]], [1, [2, [3
 , 4]]]], $[[1, 2], ([1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [
 3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1
 , [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]]).Seq], [[1, [2, [3, 4]]], [1, [2
 , [3, 4]]], [1, 2], [1, 2, 3], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]]
 , [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]]], $[[1, 2], ([1, [2, [3, 4]]
 ], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, 
 [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [
 1, [2, [3, 4]]]).Seq], "12345678")

 Rendered horizontally with :flat(0)

 (6) @0
 0 = [3] @1        1 = [2] @9   2 = [2] @12        3 = [10] @25
 ├ 0 = [2] @2      ├ 0 = [2] §2 ├ 0 = [2] @13      ├ 0 = [2] §2
 │ ├ 0 = 1.Int     └ 1 = [2] §2 │ ├ 0 = 1.Int      ├ 1 = [2] §2
 │ └ 1 = [2] @3                 │ └ 1 = 2.Int      ├ 2 = [2] §13
 │   ├ 0 = 2.Int                └ 1 = .Seq(11) @14 ├ 3 = [3] @29
 │   └ 1 = [2] @4                 ├ 0 = [2] §2     │ ├ 0 = 1.Int
 │     ├ 0 = 3.Int                ├ 1 = [2] §2     │ ├ 1 = 2.Int
 │     └ 1 = 4.Int                ├ 2 = [2] §2     │ └ 2 = 3.Int
 ├ 1 = (1) @5                     ├ 3 = [2] §2     ├ 4 = [2] §2
 │ └ 0 = [2] @6                   ├ 4 = [2] §2     ├ 5 = [2] §2
 │   ├ 0 = 6.Int                  ├ 5 = [2] §2     ├ 6 = [2] §2
 │   └ 1 = [1] @7                 ├ 6 = [2] §2     ├ 7 = [2] §2
 │     └ 0 = 3.Int                ├ 7 = [2] §2     ├ 8 = [2] §2
 └ 2 = [2] §2                     ├ 8 = [2] §2     └ 9 = [2] §2
 			          ├ 9 = [2] §2
 			          └ ...
 4 = [2] §12 5 = 12345678.Str

=head1 Column layout 

If you just flatten, the elements will be rendered after each other. If it
reaches the maximum width, a new row is started.

In the example below you can see how the elements of the Array are listed after
each other.

While listing Hashes is better horizontally, Arrays tend to look better in
columns layout giving them a table look.

I<:flat(Array)>

 (3) @0
 ├ 0 = [10] @1
 │     0 = 1.Int 1 = 2.Int 2 = 3.Int 3 = 4.Int 4 = 5.Int 5 = 6.Int
 │     6 = 7.Int 7 = 8.Int 8 = 9.Int 9 = 10.Int
 │
 ├ 1 = [11] @2
 │     0 = 1.Int 1 = 2.Int 2 = 3.Int 3 = 4.Int 4 = 5.Int 5 = 6.Int
 │     6 = 7.Int 7 = 8.Int 8 = 9.Int 9 = 10.Int 10 = [10] @3
 │                                              ├ 0 = 1.Int
 │                                              ├ 1 = 2.Int
 │                                              ├ 2 = 3.Int
 │                                              ├ 3 = 4.Int
 │                                              ├ 4 = 5.Int
 │                                              ├ 5 = 6.Int
 │                                              ├ 6 = 7.Int
 │                                              ├ 7 = 8.Int
 │                                              ├ 8 = 9.Int
 │                                              └ 9 = 10.Int
 │
 └ 2 = {2} @4
   ├ a => 1 / "1".IntStr
   └ b => 2 / "2".IntStr


Rather then listing all the elements after each other, you can ask for sets of
elements to be rendered in columnar layout and then after each other.

I<:flat((Array,5),>

 (3) @0
 ├ 0 = [10] @1
 │     0 = 1.Int 5 = 6.Int
 │     1 = 2.Int 6 = 7.Int
 │     2 = 3.Int 7 = 8.Int
 │     3 = 4.Int 8 = 9.Int
 │     4 = 5.Int 9 = 10.Int
 │
 ├ 1 = [11] @2
 │     0 = 1.Int 5 = 6.Int  10 = [10] @3
 │     1 = 2.Int 6 = 7.Int  ├ 0 = 1.Int
 │     2 = 3.Int 7 = 8.Int  ├ 1 = 2.Int
 │     3 = 4.Int 8 = 9.Int  ├ 2 = 3.Int
 │     4 = 5.Int 9 = 10.Int ├ 3 = 4.Int
 │                          ├ 4 = 5.Int
 │                          ├ 5 = 6.Int
 │                          ├ 6 = 7.Int
 │                          ├ 7 = 8.Int
 │                          ├ 8 = 9.Int
 │                          └ 9 = 10.Int
 │
 └ 2 = {2} @4
   ├ a => 1 / "1".IntStr
   └ b => 2 / "2".IntStr

=INTERFACE

=item :flat(...)

I<:flat> takes a list of conditions and options to allow you to control what
is flattened.

=head2 Conditions 

=item blocks: :flat({ $_ ~~ Array && $_.elems > 15 }, ...) 

You can pass Blocks to I<:flat>, they are called for each object in your data
structure,this lets you dynamically choose if you want the data in horizontal
, columns or vertical layout.

In the above example Arrays with more than 15 elements are flattened.

Inside your block:

=over 2

=item $_ is a reference to the data being rendered

=item $*d is the depth at which the data is

=back
 
=item integer: :flat(0) or :flat

Will flatten at the given level in your data structure.

=item object: :flat($object, $object2, ..)

If $object, $object2, ... are found in the data structure, they will be
flattened, this allows a selective flattening.

=item object type: :flat(Array, List, ...)

Will flatten any object in your data structure that matches one of the types
passed as a condition. Flattening Hashes looks particularly good.

=item other conditions are smart-matched 

=head2 Columns 

Splitting uses the same interface as the conditions but rather than pass a
condition, you pass a list consisting of a condition and split value.

	ddt $data, :flat(Array) ;

	ddt $data, :flat( (Array, 5) ) ;
	
I<Sub> conditions can dynamically return a split value.

	ddt $data, :flat( { $_ ~~ Array andthen True, 5} )


=AUTHOR

Nadim ibn hamouda el Khemir
https://github.com/nkh

=LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl6 itself.

=SEE-ALSO

Data::Dump::Tree

=end pod

sub match_target(@targets, $s, $depth)
{
my (Bool $matched, Int $rows) ;
	
for @targets -> $target is copy
	{
	($target, $rows) = $target if $target.^name eq 'List' ;  

	if $target ~~ Block 
		{
		my $*d = $depth ;
		my ($st, $ss) =  $target($s) ;
		
		if $st
			{
			$ss andthen $rows = $ss ;
			$matched = True ;
			last
			} 
		}

	# Int can only match depth
	if $target ~~ Int { $matched = $depth == $target ; last } 
	
	if $target ~~ (Array:D | Hash:D | List:D) && $s === $target
		 { $matched = True ; last }

	if $target ~~ none( Pair | Block | Hash:D | Array:D | List:D) && $s ~~ $target
		 { $matched = True ; last }
	
	$rows = Int ; # reset if no match 
	}
		
$matched, $rows
}

sub lay_horizontal(@targets) is export
{
return
	# a DDT sub elements filter
	sub ($d, $s, ($depth, $glyph, @renderings, $), @sub_elements)
	{
	my ($matched, $rows) = match_target(@targets, $s, $d.flat_depth + $depth) ;

	if $matched
		{
		my $total_width = $d.width - (($depth  + 2 ) * 3) ;

		@sub_elements = (
					(
					'',
					'',
					Data::Dump::Tree::Horizontal.new:
							:dumper($d.address_from // $d),
							:elements(@sub_elements),
							:$rows,
							:$total_width,
							:flat_depth($depth),
					),
				) ;
		}
	}
}



