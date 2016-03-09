
use Data::Dump::Tree::AnsiColor ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::DescribeBaseObjects ;

class Data::Dump::Tree does DDTR::DescribeBaseObjects
{
has $.colorizer = AnsiColor.new() ;
method is_ansi { $!colorizer.is_ansi }

has $.title ;
has $.caller is rw = False ;

has $.color is rw = True ;
has %.colors =
	<
	ddt_address blue     perl_address yellow     link  green
	header      magenta  key         cyan        value reset
	wrap        yellow

	glyph_0 yellow   glyph_1 reset   glyph_2 green   glyph_3 red
	> ;

has @.glyph_colors = < glyph_1> ;
has @.glyph_colors_cycle ; 

has @.filters ;

has %!rendered ;
has $!address ;
has $.display_info is rw = True ;
has $.display_type is rw = True ;
has $.display_address is rw = True ;
has $.display_perl_address is rw = False ; 

has $.width is rw ; 

has $!current_depth ;
has $.max_depth is rw = -1 ;
has $.max_depth_message is rw = True ;

method new(:@does, *%attributes)
{
my $object = self.bless(|%attributes);

if $object.is_ansi 
	{ $object does DDTR::AnsiGlyphs } 
else
	{ $object does DDTR::AsciiGlyphs}

for @does // () -> $role { $object does $role }

if $object.display_info == False { $object.display_type = $object.display_address = False ; };

$object 
}

sub dump($s, *%options) is export { say get_dump($s, |%options) }
sub get_dump($s, *%options) is export { Data::Dump::Tree.new(|%options).get_dump($s)}
sub get_dump_lines($s, *%options) is export { Data::Dump::Tree.new(|%options).get_dump_lines($s)}

method dump($s, *%options) { say self.get_dump($s, |%options) }

method get_dump($s, *%options)
{
self.get_dump_lines($s, |%options).join("\n") ~ "\n"
}

method get_dump_lines($s, *%options)
{
# roles can be passed in new() or as options to dump
# make a clone so we do not pollute the object

my $clone = self.clone(|%options) ;

for %options<does> // () -> $role { $clone does $role } 

if %options<display_info>.defined && %options<display_info> == False { $clone.display_type = $clone.display_address = False ; };

$clone!render_root($s)
}

method !render_root($s)
{
$!address = 0 ;
$!current_depth = 0 ;
%!rendered = () ;

$!colorizer.set_colors(%.colors, $.color) ;
@!glyph_colors_cycle = |@.glyph_colors xx  * ; 

my ($, $glyph_width) := $.get_level_glyphs($!current_depth) ; 

$.width //= %+(qx[stty size] ~~ /\d+ \s+ (\d+)/)[0] ; 
$.width -= $glyph_width ;

my @renderings ;

self!render_element((self!get_title, '', $s), (0, '', '', '', '', ''), @renderings, '') ;

@renderings
}

method !render_element($element, @glyphs, @renderings, $head_glyph)
{
my ($k, $b, $s) = $element ;

my ($glyph_width, $glyph, $continuation_glyph, $multi_line_glyph, $empty_glyph, $filter_glyph) = @glyphs ;
($glyph, $continuation_glyph, $filter_glyph).map: { $_ = $head_glyph ~ $_ } ; 

my ($v, $f, $final, $want_address) ;

($v, $f, $final, $want_address) = 
	$s.WHAT =:= Mu
		?? ('', '.Mu', DDT_FINAL ) 
		!! self.get_element_header($s) ;

$f = '' unless $.display_type ; 

$final //= DDT_NOT_FINAL ;
$want_address //= $final ?? False !! True ;

my ($address, $rendered) =
	$s.WHAT !=:= Mu
		?? $want_address ?? self!get_address($s) !! (Nil, True)
		!! (('', '', ''), True) ;

my $s_replacement ;

@!filters and $s.WHAT !=:= Mu and  
	$.filter_header($s_replacement, $s, ($filter_glyph, @renderings), ($k, $b, $v, $f, $final, $want_address)) ;

$s_replacement ~~ Data::Dump::Tree::Type::Nothing and return ;
$s = $s_replacement.defined ?? $s_replacement !! $s ;

if $final { $multi_line_glyph = $empty_glyph }

# perl stringy $v if role is on
($v, $, $) = self.get_header($v) if $s !~~ Str ;

my ($kvf, @ks, @vs, @fs) := self!split_entry($k~$b, $glyph_width, $v, $f, $address) ;

if $kvf.defined
	{
	@renderings.append: $glyph ~ $kvf ;
	}
else
	{
	@renderings.append: $glyph ~ (@ks.shift if @ks) ; 
	@renderings.append: @ks.map: { $continuation_glyph ~ $_} ; 
	@renderings.append: @vs.map: { $continuation_glyph ~ $multi_line_glyph ~ $_} ; 
	@renderings.append: @fs.map: { $continuation_glyph ~ $multi_line_glyph ~ $_} ; 
	}

if ! $final && ! $rendered
	{
	self!render_non_final($s, @renderings, $continuation_glyph) ;
	}

@!filters and $s.WHAT !=:= Mu and 
	$.filter_footer($s, ($continuation_glyph, @renderings))  ;
}

method !render_non_final($s, @renderings, $continuation_glyph)
{
$!current_depth++ ;

my (%glyphs, $glyph_width) := $.get_level_glyphs($!current_depth) ; 

$!width -= $glyph_width ; # account for mutiline text shifted for readability

if $!current_depth == $.max_depth 
	{
	if $.max_depth_message
		{
		@renderings.append: $continuation_glyph ~ %glyphs<max_depth> ~ " max depth($.max_depth)" ;
		}
	}
else
	{
	my @sub_elements = |(self!get_sub_elements($s) // ()) ;

	@!filters and $s.WHAT !=:= Mu and
		$.filter_sub_elements($s, (%glyphs<filter>, @renderings), (@sub_elements,))  ;

	for @sub_elements Z 0 .. * -> ($sub_element, $index)
		{
		self!render_element(
			$sub_element,
			self!get_element_glyphs(%glyphs, $index == @sub_elements.end),
			@renderings,
			$continuation_glyph,
			) ;
		}
	}

$!width += $glyph_width ;
$!current_depth-- ;
}

method filter_header(\s_replacement, $s, ($glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
for @.filters -> $filter
	{
	$filter(s_replacement, $s, DDT_HEADER, ($!current_depth, $glyph, @renderings), (k, b, v, f, final, want_address)) ;
	
	CATCH 
		{
		when X::Multi::NoMatch { } #no match
		default                { .rethrow }
		}
	}
}

method filter_sub_elements($s, ($glyph, @renderings), (@sub_elements))
{
for @.filters -> $filter
	{
	$filter($s, DDT_SUB_ELEMENTS, ($!current_depth, $glyph, @renderings), (@sub_elements,)) ;
	
	CATCH 
		{
		when X::Multi::NoMatch { } #no match
		default                { .rethrow }
		}
	}
}

method filter_footer($s, ($glyph, @renderings))
{
for @.filters -> $filter
	{
	$filter($s, DDT_FOOTER, ($!current_depth, $glyph, @renderings)) ;
	
	CATCH 
		{
		when X::Multi::NoMatch { } #no match
		default                { .rethrow }
		}
	}
}

multi method get_element_header($e) 
{
(self.can('get_header')[0].candidates.grep: {.signature.params[1].type ~~ $e.WHAT}) 
	?? $.get_header($e) #specific to $e
	!! $e.^name ~~ none(self.get_P6_internal()) && $e.can('ddt_get_header') 
		?? $e.ddt_get_header() # $e class provided
		!! $.get_header($e) ;  # generic handler
}

method !get_sub_elements($s)
{
(self.can('get_elements')[0].candidates.grep: {.signature.params[1].type ~~ $s.WHAT}) 
	?? $.get_elements($s) # self is  $s specific 
	!! $s.^name ~~ none(self.get_P6_internal()) && $s.can('ddt_get_elements')
		?? $s.ddt_get_elements() # $s class provided
		!! $.get_elements($s) ;  # generic handler
}

method !split_entry(Cool $k, Int $glyph_width, Cool $v, Cool $f is copy, $address)
{
my @ks = self.split_text($k, $.width + $glyph_width) ; # $k has a bit extra space
my @vs = self.split_text($v, $.width) ; 
my @fs = self.split_text($.superscribe_type($f), $.width) ;

my ($ddt_address, $perl_address, $link) =
	$address.defined
		?? $address.list.map: { $.superscribe_address($_) } 
		!! ('', '', '') ;

my $kvf ;

if +@ks < 2 && +@vs < 2 && +@fs < 2
	&& (@ks.join ~ @vs.join ~ @fs.join ~ $ddt_address ~ $perl_address ~ $link).chars <= $!width 
	{
	$kvf = $!colorizer.color(@ks.join, 'key') 
		~ $!colorizer.color(@vs.join, 'value') 
		~ $!colorizer.color(@fs.join, 'header')
		~ $!colorizer.color($ddt_address, 'ddt_address')
		~ $!colorizer.color($perl_address, 'perl_address')
		~ $!colorizer.color($link, 'link') ;
	}
else
	{
	@ks = $!colorizer.color(@ks, 'key') ; 
	@vs = $!colorizer.color(@vs, 'value') ; 
	
	if (@fs.join ~ $ddt_address ~ $perl_address ~ $link).chars <= $!width 
		{
		@fs[*-1] ~= $!colorizer.color($ddt_address, 'ddt_address')
				~ $!colorizer.color($perl_address, 'perl_address')
				~ $!colorizer.color($link, 'link') ;
		}
	else
		{
		@fs.append: 
			$!colorizer.color($ddt_address, 'ddt_address')
			~ $!colorizer.color($perl_address, 'perl_address')
			~ $!colorizer.color($link, 'link') ;
		}

	@fs = $!colorizer.color(@fs, 'header') ;
	}

$kvf, @ks, @vs, @fs 
}

multi method split_text(Cool:U $text, $width) { 'type object' }

multi method split_text(Cool:D $text, $width)
{
# given a, possibly empty, string, split the string on \n and width, handle \t
# colorize last letter of wrapped lines

return $text if $width < 1 ;

$text.subst(/\t/, ' ' x 8, :g).lines.flatmap:
	{
	$_.comb($width).map: 
		{	
		$_.chars == $width
			?? $_.substr(0, *-1) ~ $!colorizer.color($_.substr(*-1), 'wrap') 
			!! $_ ;
		} ;
	}
}

method superscribe($text) { $text }
method superscribe_type($text) { $text }
method superscribe_address($text) { $text }

method !get_address($e)
{
my $ddt_address = $!address++ ;
my $perl_address = $e.WHERE ;

my ($link, $rendered) = ('', False) ;

if %!rendered{$perl_address}:exists
	{
	$rendered++ ;
	$link = ' = @' ~ %!rendered{$perl_address} ;
	}
else
	{
	%!rendered{$perl_address} = $ddt_address ;
	}

my $address = 
	$.display_address
	??	(
		' @' ~ $ddt_address,
		$.display_perl_address ?? ' (' ~ $perl_address ~ ')' !! '',
		$link, 
		) 
	!!	('', '', '',) ;


$address, $rendered
}

method get_level_glyphs($level)
{
my %glyphs = $.get_glyphs() ; 
my $glyph_width = %glyphs<empty>.chars ;

# multiline glyph is on the next level, color accordingly
my $multi_line = %glyphs<multi_line> ;

my %colored_glyphs = $!colorizer.color(%glyphs, @!glyph_colors_cycle[$level]) ;
%colored_glyphs<multi_line> = $!colorizer.color($multi_line, @!glyph_colors_cycle[$level + 1]) ;

%colored_glyphs<__width> = $glyph_width ; #squirel in the width

%colored_glyphs, $glyph_width
}

method !get_element_glyphs(%glyphs, Bool $is_last) # is: cached
{
# returns:
# glyph introducing the element
# glyph displayed while sub elements are added
# glyph multi line text
# glyph for multiline DDT_FINAL
# glyph to display in front of comment in filters

$is_last
	?? %glyphs<__width last     last_continuation     multi_line empty filter>
	!! %glyphs<__width not_last not_last_continuation multi_line empty filter> ;
}

method !get_class_and_parents ($a) { get_class_and_parents($a) }
sub get_class_and_parents (Any $a) is export { (($a.^name, |get_Any_parents_list($a)).map: {'.' ~ $_}).join(' ') }
 
method !get_Any_parents_list(Any $a) { get_Any_parents_list($a) }
sub get_Any_parents_list(Any $a) is export 
{
my @a = try { @a = $a.^parents.map({ $_.^name }) }  ;
$! ?? (('DDT exception', ': ', "$!"),)  !! @a ;
}

method !get_Any_attributes (Any $a)
{
my @a = try { @a = get_Any_attributes($a) }  ;
$! ?? (('DDT exception', ': ', "$!"),)  !! @a ;
}

multi sub get_Any_attributes (Any $a) is export 
{
$a.^attributes.grep({$_.^isa(Attribute)}).map:   #weeding out perl internal, thanks to moritz 
	{
	my $name = $_.name ;
	$name ~~ s~^(.).~$0.~ if $_.has_accessor ;

	my $value = $a.defined 
		?? $_.get_value($a) // 'Nil'
		!! 'type object' ; 

	#my $type = $_.type.^name ;

	($name, ' = ', $value)
	}
}

method !get_title()
{
my Str $t = '' ;

if $.title // False
	{
	if $.caller // False { $t = $.title ~  ' @ ' ~ callframe(3).file ~ ':' ~ callframe(3).line ~ ' ' }
	else                 { $t = $.title ~ ' ' }
	}
else
	{	
	if $.caller // False { $t = '@ ' ~ callframe(3).file ~ ':' ~ callframe(3).line ~ ' ' }
	else                 { $t = '' }
	}

$t
}


#class
}


