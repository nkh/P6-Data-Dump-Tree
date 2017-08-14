
unit module Data::Dump::Tree::CursesFoldable ; 

=begin pod

=NAME Data::Dump::Tree::CursesFoldable 

=SYNOPSIS

	use Data::Dump::Tree::CursesFoldable ;

	display_foldable([ [ [ 1 ] ], ], :debug, :title<first>) ;

=DESCRIPTION

Display a rendered data structure in a NCurses window.

You cam navigate the structure and fold it's elements.

=head1 display_foldable($data, :$debug, :$debug_column, *%options) ;

=AUTHOR

Nadim ibn hamouda el Khemir
https://github.com/nkh

=LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl6 itself.

=SEE-ALSO

NCurses

=end pod

use Data::Dump::Tree ;
use Data::Dump::Tree::Foldable ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::Colorizer ;

use NCurses;

sub display_foldable ($s, :$page_size is copy, :$debug, :$debug_column, *%options) is export
{
my $f = Data::Dump::Tree::Foldable.new: 
			$s,
			|%options,
			:does[DDTR::AsciiGlyphs, (|%options<does> if %options<does>)],
			:width_minus(5),
			:colors<
				reset 1

				ddt_address 2  link   3    perl_address 4  
				header      5  key    6    binder 7 
				value       8  wrap   9

				gl_0 10 gl_1 11  gl_2 12 gl_3 13  gl_4 14

				kb_0 20   kb_1 21 
				kb_2 22   kb_3 23 
				kb_4 24   kb_5 25      
				kb_6 26   kb_7 27
				kb_8 28   kb_9 29 
				>,
			:colorizer(CursesColorizer.new) ;

my $win = initscr() or die "Failed to initialize ncurses\n";
keypad($win, TRUE) ;
noecho ;
raw ;
start_color ;

if has_colors() && COLOR_PAIRS() >= 13
	{
	init_pair(1,  COLOR_WHITE,	COLOR_BLACK) ; # reset

	init_pair(2,  COLOR_BLUE,	COLOR_BLACK) ; # ddt_address
	init_pair(3,  COLOR_GREEN,	COLOR_BLACK) ; # link
	init_pair(4,  COLOR_YELLOW,	COLOR_BLACK) ; # perl_address
	init_pair(5,  COLOR_MAGENTA,	COLOR_BLACK) ; # header
	init_pair(6,  COLOR_CYAN,	COLOR_BLACK) ; # key
	init_pair(7,  COLOR_CYAN,	COLOR_BLACK) ; # binder
	init_pair(8,  COLOR_WHITE,	COLOR_BLACK) ; # value
	init_pair(9,  COLOR_BLACK,	COLOR_BLACK) ; # wrap

	init_pair(10, COLOR_WHITE,	COLOR_BLACK) ; # gl_0 
	init_pair(11, COLOR_GREEN,	COLOR_BLACK) ; # gl_1
	init_pair(12, COLOR_CYAN,	COLOR_BLACK) ; # gl_2
	init_pair(13, COLOR_BLACK,	COLOR_BLACK) ; # gl_3
	
	init_pair(13, COLOR_BLACK,	COLOR_YELLOW) ; # highlight
	}

$page_size //= %+((qx[stty size] || '0 80') ~~ /(\d+) \s+ \d+/)[0] ; 

my $g = $f.get_view ; $g.set: :$page_size ;

my Bool $refresh = True ; 

loop
	{
	if $refresh
		{
		clear ;
		display($g) ;
		debug($g, :$debug_column) if $debug ;
		nc_refresh ;
		}

	my $command = getch ;

	given $command 
		{
		when $_.chr eq 'q' { last }
		when $_.chr eq 'r' { $g = $f.get_view ; $g.set: :$page_size ; $refresh++ }
		when $_.chr eq 'a' { $refresh = $g.fold_all }
		when $_.chr eq 'u' { $refresh = $g.unfold_all }

		# ctl+up and ctl+down
		when $_ eq 65  { $refresh = $g.selected_line_up }
		when $_ eq 66  { $refresh = $g.selected_line_down }
		when $_.chr eq 'e'  { $refresh = $g.selected_line_up }
		when $_.chr eq 'd'  { $refresh = $g.selected_line_down }

		when $_ eq KEY_UP    { $refresh = $g.line_up }
		when $_ eq KEY_DOWN  { $refresh = $g.line_down }
		when $_ eq KEY_PPAGE { $refresh = $g.page_up }
		when $_ eq KEY_NPAGE { $refresh = $g.page_down }

		when KEY_LEFT { $refresh = $g.fold_flip_selected }
		when KEY_RIGHT { $refresh = $g.fold_flip_selected }

		when KEY_HOME { $refresh = $g.home }
		when KEY_END { $refresh = $g.end }
		}
	}

#delwin($win) if $win ;
endwin ;
}

# ---------------------------------------------------------------------------------

sub display($g)
{
my $fold_column = 1 ;
my $fold_state_column = 3 ;
my $start_column = 5 ;

for $g.get_lines Z 0..* -> ($line, $index)
	{
	mvaddstr($index, $fold_state_column, $line[1] ?? '*' !! ' ') ;

	my $pos = 0 ;

	for $line[2].Array 
		{
		(my $text = $_[1]) ~~ s:g/'§'/*/ ;

		if 0 # $g.selected_line == $index #highlig
			{ color_set(13, 0) }
		else
			{ color_set($_[0].Int, 0) }

		mvaddstr($index, $start_column + $pos, $text) ;
		$pos += $_[1].chars ;
		}

	color_set(0, 0);
	}
	
mvaddstr($g.selected_line, $fold_column, '>') ;
}

# ---------------------------------------------------------------------------------

sub debug ($geometry, :$debug_column)
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
	mvaddstr($index, $debug_column // 30, $line.map( {$_.join} ).join ) ;
	}
}

