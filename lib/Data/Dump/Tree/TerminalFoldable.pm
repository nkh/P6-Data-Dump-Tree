
unit module Data::Dump::Tree::TerminalPrint ; 

=begin pod

=NAME Data::Dump::Tree::TerminalPrint 

=SYNOPSIS

	use Data::Dump::Tree::TerminalPrint ;

	display_foldable([ [ [ 1 ] ], ], :debug, :title<first>) ;

=DESCRIPTION

Display a rendered data structure in a Terminal::Print window.

You cam navigate the structure and fold it's elements.

=head1 display_foldable($data, :$debug, :$debug_column, *%options) ;

=AUTHOR

Nadim ibn hamouda el Khemir
https://github.com/nkh

=LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl6 itself.

=SEE-ALSO

Terminal::Print 

=end pod

use Data::Dump::Tree ;
use Data::Dump::Tree::Foldable ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::Colorizer ;

use Terminal::Print ;


sub get_foldable ($s, *%options) is export
{ 
Data::Dump::Tree::Foldable.new: 
	$s,
	|%options,
	:width_minus(5) ;
}

multi sub display_foldable ($s, :$page_size is copy, :$debug, :$debug_column, *%options) is export
{
display_foldable(get_foldable ($s, |%options), :$page_size, :$debug, :$debug_column, |%options) ;
}

multi sub display_foldable (Data::Dump::Tree::Foldable $f, :$page_size is copy, :$debug, :$debug_column, *%options) is export
{
my $screen = Terminal::Print.new ;

$screen.initialize-screen ;

$page_size //= %+((qx[stty size] || '0 80') ~~ /(\d+) \s+ \d+/)[0] ; 

my $g = $f.get_view ; $g.set: :$page_size ;

my Bool $refresh = True ; 

loop
	{
	if $refresh
		{
		display($screen, $g) ;
		debug($screen, $g, :$debug_column) if $debug ;
		}

	my $command = 'u'.ord ;

	given $command 
		{
		when $_.chr eq 'q' { last }
		}
	}
}

# ---------------------------------------------------------------------------------

sub display($screen, $g)
{
my $fold_column = 1 ;
my $fold_state_column = 3 ;
my $start_column = 5 ;

my $t0 = now ;
for $g.get_lines Z 0..* -> ($line, $index)
	{
	$screen.print-string: $fold_state_column, $index, $line[1] ?? '*' !! ' ' ;
	#$screen.print-string: 0, $index, $line[2].join('') ;

	my $text = '' ;

	for $line[2].Array 
		{
		$text ~= $_[0] ~ $_[1] ;
		}

	$screen.print-string: $start_column, $index, $text ;
	}
	
$screen.print-string: $g.selected_line, $fold_column, '>' ;
}

# ---------------------------------------------------------------------------------

sub debug ($screen, $geometry, :$debug_column)
{
my @lines = get_dump_lines $geometry,
		:title<Geometry>, :!color, :!display_info, :does(DDTR::AsciiGlyphs,), 
		:header_filters(
			 sub ($dumper, \r, $s, ($, $path, @glyphs, @renderings), (\k, \b, \v, \f, \final, \want_address))
				{
				# remove foldable object 
				r = Data::Dump::Tree::Type::Nothing if k ~~ /'$.foldable'/ ;

				# tabulate the folds data 
				if k ~~ /'@.folds'/ 
					{
					try 
						{
						require Text::Table::Simple <&lol2table> ;

						r = lol2table(
							< top index next start lines folds folded parent >,
							($s.List Z 0..*).map: -> ($d, $i) 
								{
								[ $geometry.top_line == $i ?? '*' !! '', $i, |$d]
								},
							).join("\n") ;
						}

					@renderings.push: "$!" if $! ;
					}
				}) ;

for @lines Z 0..* -> ($line, $index)
	{
	$screen.print-string: $debug_column // 30, $index, $line.map( {$_.join} ).join ;
	}
}

