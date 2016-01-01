
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
has $.display_address is rw = True ;
has $.display_perl_address is rw = False ; 

has $.width is rw ; 

has $!current_depth ;
has $.max_depth is rw = -1 ;

method new(:@does, *%attributes)
{
my $object = self.bless(|%attributes);

if $object.is_ansi 
	{ $object does DDTR::AnsiGlyphs } 
else
	{ $object does DDTR::AsciiGlyphs}

for @does // () -> $role { $object does $role }

$object 
}

sub dump($s, *%options) is export { say get_dump($s, |%options) }
sub get_dump($s, *%options) is export { Data::Dump::Tree.new(|%options).get_dump($s)}

method dump($s, *%options) { say self.get_dump($s, |%options) }

method get_dump($s, *%options)
{
# roles can be passed in new() or as options to dump
# make a clone so we do not pollute the object

my $clone = self.clone(|%options) ;

for %options<does> // () -> $role { $clone does $role } 

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

my @renderings = self!render_element((self!get_title, '', $s), (0, '', '', '', '', '')) ;

@renderings.join("\n") ~ "\n"
}

method !render_element($element, @glyphs)
{
my ($k, $b, $s) = $element ;
my ($glyph_width, $glyph, $continuation_glyph, $multi_line_glyph, $empty_glyph, $filter_glyph) = @glyphs ;

my @renderings ;

my ($v, $f, $final, $want_address) = self!get_element_header($s) ;
$final //= DDT_NOT_FINAL ;
$want_address //= $final ?? False !! True ;

my $s_replacement ;

@!filters and $.filter_header($s_replacement, $s, ($filter_glyph, @renderings), ($k, $b, $v, $f, $final, $want_address))  ;

$s_replacement ~~ Data::Dump::Tree::Type::Nothing and return @renderings ;
$s = $s_replacement.defined ?? $s_replacement !! $s ;

if $final { $multi_line_glyph = $empty_glyph }

my ($address, $rendered) = self!get_address($s) ;
$address = Nil unless $want_address ;

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
	@renderings.append: self!render_non_final($s).map: { $continuation_glyph ~ $_} 
	}

@!filters and $.filter_footer($s, ($continuation_glyph, @renderings))  ;

@renderings
}

method !render_non_final($s)
{
$!current_depth++ ;

my (%glyphs, $glyph_width) := $.get_level_glyphs($!current_depth) ; 

$!width -= $glyph_width ; # account for mutiline text shifted for readability

my @renderings ;

if $!current_depth == $.max_depth 
	{
	@renderings.append: %glyphs<max_depth> ~ " max depth($.max_depth)" ;
	}
else
	{
	my @sub_elements = |(self!get_sub_elements($s) // ()) ;

	@!filters and $.filter_sub_elements($s, (%glyphs<filter>, @renderings), (@sub_elements,))  ;

	my $last_index = @sub_elements.end ;
	for @sub_elements Z 0 .. * -> ($sub_element, $index)
		{
		@renderings.append: 
			self!render_element(
				$sub_element,
				self!get_element_glyphs(%glyphs, $index == $last_index)
				) ;
		}
	}

$!width += $glyph_width ;
$!current_depth-- ;

@renderings
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

method !has_method($method_name, $type --> Bool) #TODO:is cached
{
so self.can($method_name)[0].candidates.grep: {.signature.params[1].type ~~ $type} ;
}

method !get_element_header($e) # :is cached
{
self!has_method('get_header', $e.WHAT) 
	?? $.get_header($e) #specific to $e
	!! $e.can('ddt_get_header') 
		?? $e.ddt_get_header() # $e class provided
		!! $.get_header($e) ;  # generic handler
}

method !get_sub_elements($s)
{
self!has_method('get_elements', $s.WHAT)
	?? $.get_elements($s) # self is  $s specific 
	!! $s.can('ddt_get_elements')
		?? $s.ddt_get_elements() # $s class provided
		!! $.get_elements($s) ;  # generic handler
}

method !split_entry(Cool $k, Int $glyph_width, Cool $v, Cool $f is copy, $address)
{
$f = $.superscribe_type($f) ;

my @ks = self!split_text($k, $.width + $glyph_width) ; # $k has a bit extra space
my @vs = self!split_text($v, $.width) ; 
my @fs = self!split_text($f, $.width) ;

my $kvf = @ks.join ~ @vs.join ~ @fs.join ;

if $address.defined
	{
	# must manually handle chars as we are interested in the address char count
	# and we have an adress with color codes

	$kvf ~= $address.join ;

	@fs = '' unless @fs ;

	my $container := @fs[*-1] ;
	my $chars = $container.chars ;

	for $address.list Z ('ddt_address', 'perl_address', 'link') -> ($ae is copy, $ac)
		{
		$ae = $.superscribe_address($ae) ;

		if $chars + $ae.chars < $.width
			{
			$container ~= $!colorizer.color($ae, $ac) ; 
			$chars += $ae.chars
			}
		else
			{
			@fs.push: $!colorizer.color($ae, $ac) ; 
			$container := @fs[*-1] ;
			$chars = $ae.chars
			}
		}
	}

@ks = $!colorizer.color(@ks, 'key') ; 
@vs = $!colorizer.color(@vs, 'value') ; 
@fs = $!colorizer.color(@fs, 'header') ;

if +@ks > 1 || +@vs >1 || +@fs > 1
	{
	$kvf = Nil ;
	}
else
	{
	$kvf = $kvf.chars <= $!width
		?? @ks.join('') ~ @vs.join('') ~ @fs.join('')
		!! Nil ;
	}

$kvf, @ks, @vs, @fs 
}

method !split_text(Cool $t, $width)
{
return ('type object') unless $t.defined ;

return $t if $width < 1 ;

# given a, possibly empty, string, split the string on \n and width, handle \t

my ($index, @lines) ;
for $t.lines -> $line
	{
	my $index = 0 ;

	my $line2 = $line.subst(/\t/, ' ' x 8, :g) ;
	
	while $index < $line2.chars 
		{

		my $chunk = $line2.substr($index, $width) ;
		$index += $width ;
		
		if $index < $line2.chars && self.is_ansi
			{
			# colorize last letter of wrapped lines
			$chunk = $chunk.substr(0, *-1) ~ $!colorizer.color($chunk.substr(*-1), 'wrap') ;
			}

		@lines.push: $chunk ;
		}
	}

@lines 
}

method superscribe($text) { $text }
method superscribe_type($text) { $text }
method superscribe_address($text) { $text }

method !get_address($e)
{
my $ddt_address = $!address++ ;
my $perl_address = $e.WHERE ;

my ($link, $rendered) = ('', 0) ;

if %!rendered{$perl_address}:exists
	{
	$rendered++ ;
	$link = ' = @' ~ %!rendered{$perl_address} ;
	}
else
	{
	%!rendered{$perl_address} = $ddt_address ;
	}

$perl_address = $.display_perl_address ?? ' (' ~ $perl_address ~ ')' !! '' ;

my $address = $.display_address 
	?? (' @' ~ $ddt_address, $perl_address, $link,) 
	!! ('', '', '',) ;

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
sub get_Any_parents_list(Any $a) is export { $a.^parents.map({ $_.^name }) }

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


