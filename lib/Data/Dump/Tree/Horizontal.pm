
use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::MultiColumns ;

class Data::Dump::Tree::Horizontal
{

=begin pod

=NAME
Date::Dump::Tree::Horizontal - wrap an object to render it horizontally

=SYNOPSIS
	
	# sub elements filter
	sub ($d, $s, ($depth, $glyph, @renderings, $), @sub_elements)
	{
	if $depth == 2  
		{
		my $total_width = $d.width - (($depth  + 2 ) * 3) ;

		@sub_elements = 
			(
				(
				'',
				'',
				# render the current element's data horizontally
				Data::Dump::Tree::Horizontal.new(:dumper($d), :elements(@elements)),
				),
			)
		}
	}

See I<examples/horizontal> in the distribution for multiple examples

=DESCRIPTION

Data::Dump::Tree::Horizontal renders the sub elements of the element it wraps
separately, and aligns them horizontally.


	# normal rendering of a List
	(3) @0
	├ 0 = 1.Int
	├ 1 = 3.Int
	└ 2 = 4.Int

	# rendering wrapped in Data::Dump::Tree::Horizontal
	(3) @0
	    0 = 1.Int 1 = 3.Int 2 = 4.Int


	# normal rendering of a longer List
	(4) @0
	├ 0 = [2] @1
	│ ├ 0 = [2] @2
	│ │ ├ 0 = 1.Int
	│ │ └ 1 = [2] @3
	│ │   ├ 0 = 2.Int
	│ │   └ 1 = [2] @4
	│ │     ├ 0 = 3.Int
	│ │     └ 1 = 4.Int
	│ └ 1 = [2] §2
	├ 1 = [2] @6
	│ ├ 0 = [3] @7
	│ │ ├ 0 = 1.Int
	│ │ ├ 1 = 2.Int
	│ │ └ 2 = .Pair @8
	│ │   └ k:3, v:[2] @9
	│ │     ├ 0 = 4.Int
	│ │     └ 1 = 5.Int
	│ └ 1 = .Seq(11) @10
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
	├ 2 = 12345678.Str
	└ 3 = [2] §6

	# rendering wrapped in Data::Dump::Tree::Horizontal
	(4) @0
	    0 = [2] @1        1 = [2] @6          2 = 12345678.Str 3 = [2] §6
	    ├ 0 = [2] @2      ├ 0 = [3] @7
	    │ ├ 0 = 1.Int     │ ├ 0 = 1.Int
	    │ └ 1 = [2] @3    │ ├ 1 = 2.Int
	    │   ├ 0 = 2.Int   │ └ 2 = .Pair @8
	    │   └ 1 = [2] @4  │   └ k:3, v:[2] @9
	    │     ├ 0 = 3.Int │     ├ 0 = 4.Int
	    │     └ 1 = 4.Int │     └ 1 = 5.Int
	    └ 1 = [2] §2      └ 1 = .Seq(11) @10
				├ 0 = [2] §2
				├ 1 = [2] §2
				├ 2 = [2] §2
				├ 3 = [2] §2
				├ 4 = [2] §2
				├ 5 = [2] §2
				├ 6 = [2] §2
				├ 7 = [2] §2
				├ 8 = [2] §2
				├ 9 = [2] §2
				└ ...


=INTERFACE

=item method new: :element($s), [ :other_named_arguments, ...]

=head2 Arguments

=item :elements

The elements to wrap,they will be rendered horizontally, in columns

=item :title

Title to be displayed over the sub elements renderings

=item :total_width

The maximum width the horizontal rendering can take, the rendering will be
wrapped into multiple rows

=item :dumper

The dumper to be used to render the sub elements, Passing a dumper allows the
referenced to match between columns. You want to pass the dumper of the top
container for the best results. A new dumper is created if this is not set.

=item :dumper_options

Options to pass to the dumper rendering the sub elements

=AUTHOR

Nadim ibn hamouda el Khemir
https://github.com/nkh

=LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl6 itself.

=SEE-ALSO

Data::Dump::Tree

DDT::MultiColumns

=end pod

has Str $.title = '' ;
has Int $.total_width ;
has Data::Dump::Tree $.dumper ;
has %.dumper_options ;
has @.elements ;

method ddt_get_header
{ 
my $columns = get_columns :$.total_width,
				|(@.elements.map(
					{
					my ($k, $b, $sub_element) = $_ ;
					my $title = $k ~ $b ;

					if %!dumper_options
						{
						get_dump_lines_integrated(
							$sub_element,
							:$title,
							:address_from($!dumper),
							|%!dumper_options,
							)
						}
					else
						{
						get_dump_lines_integrated(
							$sub_element,
							:$title,
							:address_from($!dumper),
							)
						}
					})) ;

($!title ne '' ?? "$!title\n" !! '') ~ $columns, '', DDT_FINAL 
}

} #class

DOC INIT {use Pod::To::Text ; pod2text($=pod) ; }


