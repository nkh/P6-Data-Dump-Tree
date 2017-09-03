
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

use Terminal::Print ;
use Terminal::Print::DecodedInput;


sub get_foldable ($s, *%options) is export
{ 
Data::Dump::Tree::Foldable.new: 
	$s,
	|%options,
	:width_minus(5) ;
}

multi sub display_foldable ($s, :$page_height is copy, :$debug, :$debug_column, *%options) is export
{
display_foldable(get_foldable $s, |%options, :$page_height, :$debug, :$debug_column) ;
}

multi sub display_foldable (Data::Dump::Tree::Foldable $f, :$page_height is copy, :$debug, :$debug_column, *%options) is export
{

my ($ph, $page_width)  = ((qx[stty size] || '0 80') ~~ /(\d+) \s+ (\d+)/).List ;

$page_height //= +$ph ;
$page_height max= +$ph ;

my $g = $f.get_view ; $g.set: :page_size($page_height) ;

my Bool $refresh = True ; 

class Tick { }
my $timer     = Supply.interval(2).map: { Tick } ;
my $in-supply = decoded-input-supply;

my $supplies  = Supply.merge($in-supply, $timer) ;

my $screen = Terminal::Print.new ;
$screen.initialize-screen ;

my sub refresh
{
if $refresh
	{
	display($screen, $g, :$page_height, :$page_width) ;
	debug($screen, $g, :$debug_column) if $debug ;
	}
}

refresh ;

react 
	{
	whenever $supplies
		{
		when Tick { ; }  # Timer Tick

		when 'q' { done }  # Quit

		when 'r'         { $g = $f.get_view ; $g.set: :page_size($page_height) ; $refresh++ ; refresh ; }
		when 'a'         { $refresh = $g.fold_all ; refresh ; }
		when 'u'         { $refresh = $g.unfold_all ; refresh ; }

		when 'e'         { $refresh = $g.selected_line_up ; refresh ; }
		when 'd'         { $refresh = $g.selected_line_down ; refresh ; }

		when CursorUp    { $refresh = $g.line_up ; refresh ; }
		when CursorDown  { $refresh = $g.line_down ; refresh ; }
		when PageUp      { $refresh = $g.page_up ; refresh ; }
		when PageDown    { $refresh = $g.page_down ; refresh ; }

		when CursorLeft  { $refresh = $g.fold_flip_selected ; refresh ; }
		when CursorRight { $refresh = $g.fold_flip_selected ; refresh ;}

		when Home        { $refresh = $g.home ; refresh ; }
		when End         { $refresh = $g.end ; refresh ; }
		}
	}

$screen.shutdown-screen ;
}

# ---------------------------------------------------------------------------------

sub display($screen, $g, :$page_height, :$page_width)
{
my @lines = $g.get_lines ;

for @lines Z 0..* -> ($line, $index)
	{
	my ($text, $length) = ($line[2], $line[3]) ;
 
	print $screen.cell-string(0, $index) 
		~ ($g.selected_line == $index ?? '> ' !! '  ')
		~ ($line[1] ?? '* ' !! '  ')
		~ $text  
		~ (' ' x ($page_width - ($length + 5)) ) ;
	}
	
my $blank = ' ' x ($page_width - 1) ;
for @lines.elems..($page_height - 1)
	{
	print $screen.cell-string(0, $_) ~ $blank ;
	}
	
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

