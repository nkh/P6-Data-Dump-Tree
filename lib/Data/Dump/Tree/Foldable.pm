
=begin pod

=NAME Data::Dump::Tree::Foldable 

=SYNOPSIS

	use Data::Dump::Tree::Foldable ;

	my $f = Data::Dump::Tree::Foldable.new: $data_to_dump, :title<title> ;
	my $v = $f.get_view ; # default geometry

	$v.set: :top_line<1>, :page_size<10> ; # set geometry
	#get the lines to display
	my @lines = $v.get_lines ;
	 
	# move in the data structure rendering
	$v.line_down ;
	$v.page_down ;
	
	# select a line and fold it, or unfold it if it is already folded
	$v.set: :selected_line(7) ;
	$v.fold_flip_selected ;
	
	#get the lines to display
	@line = $v.get_lines ;

=DESCRIPTION

U<Data::Dump::Tree::Foldable> and U<Data::Dump::Tree::Foldable::View> implement
the base mechanisms needed to:

=item display a structured rendered by <Data::Dump::Tree> in a viewport

=item movement through the data structure in the viewport
 
=item folding the data structure.

A simple search functionality is also planned in future versions.


=head1 Data::Dump::Tree::Foldable

	my $f = Data::Dump::Tree::Foldable.new: $data_to_dump, :title<title> ;


A Foldable contains a U<Data:Dump::Tree> rendering. I takes the same arguments
as U<Data:Dump::Tree>. 

=head2 method get_view

	my $v = $f.get_view ;

Returns a view to the rendering. You can create multiple views from a single 
Foldable object. The views share the Foldable but each view has its own folds
and geometry.

=head1 Data::Dump::Tree::Foldable::View

A view renderer for a U<Data::Dump::Tree> rendering.

You can set the geometry of the view then navigate the data structure and fold
it too.

=head2 method set(:$page_size, :$top_line, :$selected_line)

Set the geometry of the view where:

=item :page_size is the height of the view

=item :top_line is the line of the rendering displayed at the top of the window

=item :selected_line is a line index in the view

You can call I<set> with a combination of named arguments, eg: you don't need
to set all of them.

=head2 method line_up()

Scrolls the view up showing previous lines of the rendering

=head2 method page_up()

Scrolls the view up, the height of a view

=head2 method line_down()

Scrolls the view down showing following lines of the rendering

=head2 method page_down()

Scrolls the view down, the height of a view

=head2 method fold_flip_selected()

Folds or unfolds the data under the selected_line, see I<set>.

=head2 method fold_all()

Folds all the data 

=head2 method unfold_all() 

Unfolds all the data

=head2 method get_lines()

Return all the lines visible in the view, may be less than the view height and
even zero lines in case of a view size equal to 0

=AUTHOR

Nadim ibn hamouda el Khemir
https://github.com/nkh

=LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl6 itself.

=SEE-ALSO

Data::Dump::Tree

=end pod


use Data::Dump::Tree ;
use Data::Dump::Tree::Colorizer ;

enum (SKIP => 0, 'FOLDED', 'PARENT_FOLDED') ;

class Data::Dump::Tree::Foldable::View {...}

class Data::Dump::Tree::Foldable 
{
has @.lines ;
has @.folds ;

method new($s, *%attributes)
{

my $dumper = Data::Dump::Tree.new: |%attributes ;

my ($lines, $wrap_data) 
	= $dumper.get_dump_lines:
			$s, 
			:wrap_header(&header_wrap),
			:wrap_footer(&footer_wrap),
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

self.bless: :lines(|$lines), :folds(|$wrap_data<folds>) ;
}

my sub header_wrap(
	\wd,
	(@head_glyphs, $glyph, $continuation_glyph, $multi_line_glyph),
	(@kvf, @ks, @vs, @fs),
	Mu $s,
	($depth, $path, $filter_glyph, @renderings),
	($k, $b, $v, $f, $, $final, $want_address),
	) 
{
wd<folds>.push: @renderings.elems ;
wd<folds>.elems - 1 ; # token passed to footer callback
}

my sub footer_wrap(\wd, Mu $s, $final, ($depth, @glyphs, @renderings), $header_wrap_token)
{
wd<folds>[$header_wrap_token] [R-]= @renderings.elems ;
}

method get_view(*%options)
{
Data::Dump::Tree::Foldable::View.new:
	:foldable(self),
	:folds($.folds.map: { [$_, 0, 0] }),
	|%options,
}


} # class


class Data::Dump::Tree::Foldable::View 
{
has Data::Dump::Tree::Foldable $.foldable ;

has Int $.top_line is readonly = 0;
has Int $.page_size is readonly = 25 ;
has Int $.selected_line is readonly = 0 ;
has @.folds ;

has Bool $.search_folds = True ;

method set(:$page_size, :$top_line, :$selected_line)
{ 
$page_size andthen $!page_size = max $page_size, 0 ;

$!top_line = max(min($top_line, @!folds - $!page_size), 0) with $top_line ;

with $selected_line 
	{
	my $current_line = $!top_line ;

	for ^max(min($selected_line, $!page_size), 0) 
		{
		$current_line += @!folds[$_][FOLDED] 
					?? @!folds[$_][SKIP] + 1
					!! 1 ;
		}

	$!selected_line = $current_line ;
	}
}

method line_up()
{
$!top_line-- ;

while @!folds[$!top_line][PARENT_FOLDED]
	{ $!top_line-- }

$!top_line max= 0 ;
}

method page_up() { $.line_up for ^$!page_size }

method line_down()
{
my $start_line = $!top_line ;

$!top_line++ ;
  
while @!folds[$!top_line][PARENT_FOLDED]
	{ $!top_line++ }

$!top_line = $start_line if $!top_line >= @!folds ;
}

method page_down() { $.line_down for ^$!page_size }

method fold_flip_selected()
{ 
return unless @!folds[$!selected_line][SKIP] ; # only fold foldable

my $state = @!folds[$!selected_line][FOLDED] +^= 1 ;

my @sub_elements = @!folds[ ($!selected_line + 1) .. ($!selected_line + @!folds[$!selected_line][SKIP]) ] ;

while @sub_elements
	{
 	$_ = @sub_elements.shift ;

	$_[PARENT_FOLDED] = $state ;

	if $_[FOLDED] {	@sub_elements.shift for ^$_[SKIP] }
	}
}

method fold_all()   { for @!folds { $_[PARENT_FOLDED] = 1 ; $_[FOLDED] = 1 if $_[SKIP] } ; @!folds[0][PARENT_FOLDED] = 0 }
method unfold_all() { for @!folds { $_[PARENT_FOLDED] = $_[FOLDED] = 0 } }

method get_lines()
{
my ($current_line, @lines) = ($!top_line, ) ;

while @lines < $!page_size and $current_line < $!foldable.lines  
	{
	@lines.push: $!foldable.lines[$current_line] ;

	$current_line += @!folds[$current_line][FOLDED] 
				?? @!folds[$current_line][SKIP] + 1
				!! 1 ;
	}

@lines
}

method search()
{
# search in folded? return command to unfold each match 
# search with regex
# handle colored dumps
# return list of matches to allow forward and backward searching
# return path where regex is matched
# search paths only
# hi-light matches
}

} # class


