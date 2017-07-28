
use Data::Dump::Tree::Horizontal ;

unit module Data::Dump::Tree::LayHorizontal ;

=begin pod

=NAME
Date::Dump::Tree::LayHorizontal - render data parts in horizontal layout

=SYNOPSIS
	use Data::Dump::Tree ;
	
	ddt $some_complex_data, :flat(0) ; 
		
See I<examples/flat.pl> in the distribution for multiple examples

=DESCRIPTION

Renders data elements matching conditions in horizontal layout, the sub
elements are rendered vertically (except if they are flattened too).

This allows you to mix vertical and horizontal layout  in the same rendering.

 Vertical mode:

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

 dd's output:

 $($[[1, [2, [3, 4]]], ([6, [3]],), [1, [2, [3, 4]]]], [[1, [2, [3, 4]]], [1, [2, [3
 , 4]]]], $[[1, 2], ([1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [
 3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1
 , [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]]).Seq], [[1, [2, [3, 4]]], [1, [2
 , [3, 4]]], [1, 2], [1, 2, 3], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]]
 , [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]]], $[[1, 2], ([1, [2, [3, 4]]
 ], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, 
 [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [
 1, [2, [3, 4]]]).Seq], "12345678")

 Rendered with :flat(0)

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



	 
=INTERFACE

=item :flat( conditions and options )

I<:flat> takes a list of conditions and options to allow you to control what
is flattened.

=head2 Conditions 

=item integer: :flat(0)

Will flatten at the given level in your data structure. flat(0) is what you
will use most of the time. depending on your data structure you may want to
flatten at a different level.

=item object type: :flat(Array, List)

Will flatten any object in your data structure that matches one of the types
passed as a condition. Flattening Hashes looks particularly good.

=item object: :flat($object, $object2, ..)

If $object, $object2, ... are found in the data structure, they will be
flattened, this allows a selective flattening.

=item subs: :flat(sub($s, $d){ $s ~~ Array && $s.elems > 15 }, ...) 

You can pass subs to I<:flat>, they are called for each object in your dara
structure, you can dynamically choose if you want the data flattened or not.

In the above example Arrays with more than 15 elements are flattened.

=head2 Options 

=item TBD

=item TBD

=AUTHOR

Nadim ibn hamouda el Khemir
https://github.com/nkh

=LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl6 itself.

=SEE-ALSO

Data::Dump::Tree

=end pod

sub lay_horizontal(@targets) is export
{
return
	# a DDT sub elements filter
	sub ($d, $s, ($depth, $glyph, @renderings, $), @sub_elements)
	{
	if
		$depth ~~ any( @targets.grep: { $_ ~~ Int })
		|| $s ~~ any( @targets.grep: { $_ ~~ none(Pair | Int | Hash:D | Sub) })
		|| @targets.grep(Sub).first( { $_($s, $d) } )
		|| @targets.grep(Hash:D).first( { $_ === $s } ) # comparing hashes, P6 bug
		
		{
		my $total_width = $d.width - (($depth  + 2 ) * 3) ;

		@sub_elements = (
					(
					'',
					'',
					Data::Dump::Tree::Horizontal.new(
						:dumper($d),
						:elements(@sub_elements),
						:$total_width)
					),
				) ;
		}
	}
}



