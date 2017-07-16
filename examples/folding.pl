
use Data::Dump::Tree ;
use Data::Dump::Tree::Foldable ;
use Data::Dump::Tree::DescribeBaseObjects ;

use NCurses;

sub MAIN(Bool :$debug)
{
my $win = initscr() or die "Failed to initialize ncurses\n";
keypad($win, TRUE) ;
noecho ;
raw ;
start_color ;

LEAVE 
	{
	delwin($win) if $win;
	endwin;
	}

if has_colors() && COLOR_PAIRS() >= 13
	{
	init_pair(1,  COLOR_WHITE,	COLOR_BLACK) ; # reset

	init_pair(2,  COLOR_BLUE,	COLOR_BLACK) ; # ddt_address
	init_pair(3,  COLOR_GREEN,	COLOR_BLACK) ; # link
	init_pair(4,  COLOR_YELLOW,	COLOR_BLACK) ; # perl_address
	init_pair(5,  COLOR_WHITE,	COLOR_BLACK) ; # header
	init_pair(6,  COLOR_CYAN,	COLOR_BLACK) ; # key
	init_pair(7,  COLOR_CYAN,	COLOR_BLACK) ; # binder
	init_pair(8,  COLOR_WHITE,	COLOR_BLACK) ; # value
	init_pair(9,  COLOR_BLACK,	COLOR_BLACK) ; # wrap

	init_pair(10, COLOR_WHITE,	COLOR_BLACK) ; # gl_0 
	init_pair(11, COLOR_GREEN,	COLOR_BLACK) ; # gl_1
	init_pair(12, COLOR_CYAN,	COLOR_BLACK) ; # gl_2
	init_pair(13, COLOR_BLACK,	COLOR_BLACK) ; # gl_3
}

my $f = Data::Dump::Tree::Foldable.new: get_s(), :title<title>, :does(DDTR::AsciiGlyphs,) ;
my $g = $f.get_view ; $g.set: :page_size<10> ;

loop
	{
	clear ;
	display($g.get_lines) ;
	debug($g) if $debug ;
	nc_refresh ;

	my $command = getch ;

	given $command 
		{
		when $_.chr eq 'q' { last }
		when $_.chr eq 'r' { $g = $f.get_view ; $g.set: :page_size<10> }
		when $_.chr eq 'a' { $g.fold_all }
		when $_.chr eq 'u' { $g.unfold_all }

		when $_ eq KEY_UP    { $g.line_up }
		when $_ eq KEY_DOWN  { $g.line_down }
		when $_ eq KEY_PPAGE { $g.page_up }
		when $_ eq KEY_NPAGE { $g.page_down }

		when KEY_LEFT { $g.set: :selected_line(0) ; $g.fold_flip_selected }
		when KEY_RIGHT { }

		when KEY_HOME { $g.set: :top_line(0) }
		when KEY_END { $g.page_down for ^5 }
		}
	}

} # MAIN

# ---------------------------------------------------------------------------------

sub display(@lines)
{
for @lines Z 0..* -> ($line, $index)
	{
	my $pos = 0 ;

	for $line.Array 
		{
		color_set($_[0].Int, 0);
		mvaddstr($index, 5 + $pos, $_[1]) ;
		$pos += $_[1].chars ;
		}

	color_set(0, 0);
	}
}

# ---------------------------------------------------------------------------------

sub debug ($geometry)
{
my @lines = get_dump_lines $geometry,
		:title<Geometry>, :!color, :!display_info, :does(DDTR::AsciiGlyphs,), 
		:header_filters(
			 sub (\r, $s, ($, $path, @glyphs, @renderings), (\k, \b, \v, \f, \final, \want_address))
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
							< index skip folded parent >,
							($s.List Z 0..*).map: -> ($d, $i) { [$i, |$d] },
							).join("\n") ;
						}

					@renderings.push: "$!" if $! ;
					}
				}) ;

for @lines Z 0..* -> ($line, $index)
	{
	mvaddstr($index, 45, $line.map( {$_.join} ).join ) ;
	}
}

# ---------------------------------------------------------------------------------

sub get_s
{
my class Tomatoe{ has $.color ;}

        [
        Tomatoe,
        [ [ [ Tomatoe, ] ], ],
	(^5).list,
        123,
	(^5).list,
        Tomatoe.new( color => 'green'),
	(^5).list,
        ] ;
}

