
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

enum (NEXT => 0, 'START', 'LINES', 'FOLDS', 'FOLDED', 'PARENT_FOLDED') ;

class Data::Dump::Tree::Foldable::View {...}

class Data::Dump::Tree::Foldable 
{
has @.lines ;
has @.folds ;

method new($s, *%attributes)
{

my $dumper = %attributes<ddt_is> // Data::Dump::Tree.new ;

my ($lines, $wrap_data) = $dumper.get_dump_lines:
					$s,
					|%attributes, 
					:wrap_header(&header_wrap),
					:wrap_footer(&footer_wrap) ;

self.bless: :lines(|$lines), :folds(|$wrap_data<folds>) ;
}

my sub header_wrap(
	\wd, $rendered_lines,
	(@head_glyphs, $glyph, $continuation_glyph, $multi_line_glyph),
	(@kvf, @ks, @vs, @fs),
	Mu $s,
	($depth, $path, $filter_glyph, @renderings),
	($k, $b, $v, $f, $, $final, $want_address),
	) 
{
wd<folds>.push: [@renderings.elems, @renderings.elems - $rendered_lines, $rendered_lines] ;

return wd<folds>.end ; # token passed to footer callback
}

my sub footer_wrap(\wd, Mu $s, $final, ($depth, @glyphs, @renderings), $header_wrap_token)
{
wd<folds>[$header_wrap_token][NEXT] = wd<folds>.elems ;
wd<folds>[$header_wrap_token][FOLDS] = wd<folds>.elems != $header_wrap_token + 1 ;
}

method get_view(*%options)
{
Data::Dump::Tree::Foldable::View.new:
	:foldable(self),
	:folds($.folds.map: { [|$_, 0, 0] }),
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

method set(:$page_size, :$top_line, :$selected_line --> Bool)
{ 
$page_size andthen $!page_size = max $page_size, 0 ;

$top_line andthen $!top_line = max(min($top_line, @!folds - $!page_size), 0) ;

$selected_line andthen $!selected_line = $selected_line ;
	
True
}

method line_up(--> Bool)
{
my $line = $!top_line ;

$!top_line-- ;

while @!folds[$!top_line][PARENT_FOLDED]
	{ $!top_line-- }

$!top_line max= 0 ;

$!top_line != $line 
}

method line_down(-->Bool)
{
my $line = $!top_line ;

$!top_line = @!folds[$!top_line][FOLDED] ?? @!folds[$!top_line][NEXT] !! $!top_line + 1 ;

$!top_line = $line if $!top_line > @!folds.end ;

$!top_line != $line 
}

method page_up(--> Bool) { my Bool $refresh ;  $refresh++ if $.line_up for ^$!page_size ; $refresh }
method page_down(--> Bool) { my Bool $refresh ; $refresh++ if $.line_down for ^$!page_size ; $refresh }

method home(--> Bool) { my Bool $refresh ; $refresh++ if $.line_up for ^(@!folds - $!top_line) ; $refresh }
method end(--> Bool) { my Bool $refresh ; $refresh++ if  $.line_down for ^(@!folds - $!top_line) ; $refresh }

method selected_line_up(--> Bool)
{
return False if $!selected_line == 0 ;

$!selected_line-- ;

True
}

method selected_line_down(--> Bool)
{
return False if $!selected_line == @!folds.end - $!top_line ;

$!selected_line++ ;

True
}

method fold_flip_selected(--> Bool)
{ 
my @lines := $.get_lines ;
my $line = @lines[$!selected_line][0] ; 

return False unless @!folds[$line][FOLDS] ; # only fold foldable

my $state = @!folds[$line][FOLDED] +^= 1 ;

my @sub_elements =  @!folds[ ($line + 1) .. @!folds[$line][NEXT] - 1 ] ;

while @sub_elements
	{
	$_ = @sub_elements.shift ;

	$_[PARENT_FOLDED] = $state ;

	if $_[FOLDED] { @sub_elements.shift if @sub_elements for ^$_[NEXT] }
	}

True
}

method fold_all(--> Bool)
{
for @!folds -> $fold
	{
	$fold[PARENT_FOLDED] = 1 ;
	$fold[FOLDED] = 1 if $fold[FOLDS] ;
	}

@!folds[0][PARENT_FOLDED] = 0 ;
$!top_line = 0 ;

True
}

method unfold_all(--> Bool) { for @!folds { $_[PARENT_FOLDED] = $_[FOLDED] = 0 } ; True}

method get_lines()
{
my ($fold_line, @lines) = ($!top_line, ) ;

while @lines < $!page_size and $fold_line < @!folds
	{
	my $display_line = $.folds[$fold_line][START] ;

	for ^$.folds[$fold_line][LINES]
		{
		@lines.push: [ +$fold_line, so $.folds[$fold_line][FOLDED], $!foldable.lines[$display_line + $_] ] ;

		last if @lines >= $!page_size ;
		}

	$fold_line = @!folds[$fold_line][FOLDED] ?? @!folds[$fold_line][NEXT] !! $fold_line + 1 ;
	}

$!selected_line max= 0 ;
$!selected_line min= @lines.end ;

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

method search_fold
{
# find entries based on text and type and fold/unfold them
# so far type is not part of fold information, nor is path information
}


} # class


