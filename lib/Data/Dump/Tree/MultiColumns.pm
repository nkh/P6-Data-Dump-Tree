

=begin pod

=NAME
Date::Dump::Tree::MultiColums - Tabulates lists of text

=SYNOPSIS
	use Data::Dump::Tree::Horizontal ;
	
	display_columns <1 2 3>, my_get_lines(), :named_option, ... 
		
See I<examples/two_colums> in the distribution for multiple examples

=DESCRIPTION

Given a list of string lists, return a tabulated version of the input lists.

	use Data::Dump::Tree ;
	use Data::Dump::Tree::MultiColumns ;

	display_columns <line other_line>, get_dump_lines_integrated([6..12]), 1..6, :width(20) ;

	Output:

	line                 [7] @0               1
	other_line           ├ 0 = 6.Int          2
			     ├ 1 = 7.Int          3
			     ├ 2 = 8.Int          4
			     ├ 3 = 9.Int          5
			     ├ 4 = 10.Int         6
			     ├ 5 = 11.Int
			     └ 6 = 12.Int

	 
=INTERFACE

=item sub display_columns($text_list, $text_list, ... , Int :total_width, Int :width, Bool :compact --> Str)

'say's the rendered text

=item sub get_columns($text_list, $text_list, ... , Int :total_width, Int :width, Bool :compact --> Str)

Returns the rendered text

=head2 Arguments 

=item list of text lists

Both subs take a variable number of string lists

=item :total_width 

The maximim width of the output, multiple rows of columns will be generated if necessary

=item :width

The minimum width of each colum

=item :compact

Set the width of each column to fit the column's content. It will override I<:width>

=AUTHOR

Nadim ibn hamouda el Khemir
https://github.com/nkh

=LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl6 itself.

=SEE-ALSO

Data::Dump::Tree

=end pod

sub display_columns(**@rs, Int :$total_width, Int :$width, Bool :$compact) is export
{
print get_columns(|@rs, :$total_width, :$width, :$compact) ;
}

my regex COLOR { \[ \d+ [\;\d+]* <?before [\;\d+]* > m } 

my role MaxLines { has $.max_lines is rw = 0 } 

sub get_columns(**@rs, Int :$total_width, Int :$width, Bool :$compact --> Str) is export
{
return '' unless @rs ;

my $current_length = 0 ;
my $current_block = [] but MaxLines ;
my $current_block_max_length = 0 ;
my @blocks = $current_block ;

for |@rs
	{
	my @lines_width ;
	my $elements = $_.elems ; 

	# compute width without ANSI escape codes
	my $r_max_width = (.map: { my $w = S:g/ \e <COLOR> //.chars ; @lines_width.push: $w ; $w }).max ;

	my $r_width = $compact ?? $r_max_width !! max $width // 0, $r_max_width ;

	if $total_width.defined && $current_length + $r_width >= $total_width 
		{
		$current_length = 0 ;
		$current_block = [] but MaxLines ;
		@blocks.push: $current_block ; 
		}

	$current_block.max_lines max= $elements ; 
	$current_length += $r_width + 1 ; # joined with a single space later
	$current_block.push: $r_width, @lines_width, $_ ;
	}

my $o ;

for @blocks -> @block
	{
	for ^@block.max_lines -> $index
		{
		my $string ; 

		for @block -> $width, $width_lines, $lines 
			{
			$string ~= $index < $lines.elems
					?? $lines[$index] ~ (' ' x $width - $width_lines[$index]) ~ ' '
					!! ' ' x $width ~ ' ' ;
			}

		$o ~= $string ~ "\n" ;
		}
	}

$o ;
} 


DOC INIT { use Pod::To::Text ; pod2text($=pod) }

