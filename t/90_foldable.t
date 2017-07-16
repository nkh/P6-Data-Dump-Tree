#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::Foldable ;

use Test ;
plan 26 ;

# DDT filter to show the folding internal data in a better way 
sub filter(\r, $s, ($, $path, @glyphs, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
r = Data::Dump::Tree::Type::Nothing if k ~~ /'$.foldable'/ ;

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
}

my $f = Data::Dump::Tree::Foldable.new: (^20).List, :title<title>, :!color ;
my $g = $f.get_view ;
	my @dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 21, '21 lines' or diag @dump.join("\n") ;
	like @dump[0], /title/, 'top is title' or diag @dump.join("\n") ;


$g.set: :top_line<1>, :page_size<10> ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 10, '10 lines' or diag @dump.join("\n") ;
	like @dump[0], /0/, 'top line changed' or diag @dump.join("\n") ;
 
$g.set: :page_size<-10> ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 0, '0 lines' or diag @dump.join("\n") ;

$g.set: :page_size<10> ;
$g.line_down ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 10, '10 lines' or diag @dump.join("\n") ;
	like @dump[0], /1/, 'line down' or diag @dump.join("\n") ;

$g.line_down for ^20;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 1, '1 line' or diag @dump.join("\n") ;
	like @dump[0], /19/, 'last line' or diag @dump.join("\n") ;

$g.page_down ;
	#diag get_dump $g, header_filters => (&filter,) ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	like @dump[0], /19/, 'page down, last line' or diag @dump.join("\n") ;

$g.page_up ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	like @dump[0], /9/, 'page up' or diag @dump.join("\n") ;

$g.page_up for ^15;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	like @dump[0], /title/, 'max page up' or diag @dump.join("\n") ;

$g.line_up ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	like @dump[0], /title/, 'max line up' or diag @dump.join("\n") ;


class Tomatoe{ has $.color ;}
my $s =
        [
        Tomatoe,
        [ [ [ Tomatoe, ] ], ],
        123,
        Tomatoe.new( color => 'green'),
	(^5).list,
        ] ;

$f = Data::Dump::Tree::Foldable.new($s, :title<title>, :!color) ;
$g = $f.get_view ;
	#diag get_dump ($f => $g) ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 15, '15 lines' or diag @dump.join("\n") ;

$g.fold_flip_selected ;
	#diag get_dump $g, header_filters => (&filter,) ;
	@dump = $g.get_lines ;
	is @dump.elems, 1, '1 line fold' or diag @dump.join("\n") ;

$g.fold_all ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 1, '1 line fold' or diag @dump.join("\n") ;

$g.unfold_all ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 15, '15 lines' or diag @dump.join("\n") ;

$g.set: :selected_line(3) ;
$g.fold_flip_selected ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 13, '13 lines, 1 fold' or diag @dump.join("\n") ;

$g.set: :selected_line(7) ;
$g.fold_flip_selected ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 8, '8 lines, 2 folds' or diag @dump.join("\n") ;

$g.line_down for ^3 ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 5, '5 lines, 2 folds' or diag @dump.join("\n") ;
	like @dump[0], /1/, 'at index 1' or diag @dump.join("\n") ;

$g.line_down  ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 4, '4 lines, 2 folds' or diag @dump.join("\n") ;
	like @dump[0], /2/, 'at index 2' or diag @dump.join("\n") ;

$g.line_up ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 5, '5 lines, 2 folds' or diag @dump.join("\n") ;
	like @dump[0], /1/, 'at index 1' or diag @dump.join("\n") ;

$g.line_up for ^3 ;
	@dump = $g.get_lines.map( { $_.map( {$_.join} ).join } ) ;
	is @dump.elems, 8, '8 lines, 2 folds' or diag @dump.join("\n") ;

