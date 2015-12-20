
use Data::Dump::Tree::AnsiColor ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::DescribeBaseObjects ;

class Data::Dump::Tree does DescribeBaseObjects 
{
has $!colorizer = AnsiColor.new() ;

has $.title is rw = '' ;
has $.caller is rw = False ;
has %!glyphs ;

has $.color is rw = True ;
has %.colors =
	<
	title yellow   glyph reset    perl_address yellow    ddt_address blue
	link  green    key   cyan     value        reset     header      magenta 
	wrap  cyan 
	> ;

has $!address = 0 ;
has $.display_address is rw = True ;
has $.display_perl_address is rw = False ; 

has $.width is rw = 79 ; 

has $!current_depth = 0 ;
has $.max_depth is rw = -1 ;

method new(:@does, *%attributes)
{
my $object = self.bless(|%attributes);
for @does // () -> $role { $object does $role }
$object 
}

sub dump($s, *%options) is export { say get_dump($s, %options) }
sub get_dump($s, *%options) is export {Data::Dump::Tree.new(|%options).get_dump($s)}

method dump($s, *%options) { say self.get_dump($s, %options) }

method get_dump($s, *%options)
{
# roles can be passed in new() or as options
# make a clone so we do not pollute the object

my $clone = self.clone(|%options) ;

for %options<does> // () -> $role { $clone does $role } 

$clone!_get_dump($s)
}

method !_get_dump($s)
{
$!colorizer.set_colors(%.colors, $.color) ;
%!glyphs = $.get_glyphs() ; #colors must be set before (for ANSI checking)

$!address = 0 ;
$.width //= %+(qx[stty size] ~~ /\d+ \s+ (\d+)/)[0] ; 
$.width -= %!glyphs<last_continuation>.chars ;

$!current_depth = 0 ;

my $glyphs = ('', '', %!glyphs<not_last_continuation>) ; # root's glyphs 

self!render_element((self!get_title, $s), $glyphs).join("\n") ~ "\n"
}

method !render($s)
{
return ( %!glyphs<empty> ~ %!glyphs<max_depth> ~ " max depth($.max_depth)")
	if $!current_depth + 1 == $.max_depth ;

$!current_depth++ ;
$!width -= %!glyphs<last_continuation>.chars ; # for mutiline text

my $elements = 
	self!has_dumper_method('get_elements', $s.WHAT)
	?? $.get_elements($s) # self is  $s specific 
	!! $s.can('ddt_get_elements')
		?? $s.ddt_get_elements() # $s class provided
		!! $.get_elements($s) ;  # generic handler

my @renderings ;

for $elements Z 0 .. * -> ($e, $index)
	{
	my $glyphs = self!get_level_glyphs($index == $elements.end), # replace by multi or  lookup table

	@renderings.append: self!render_element($e, $glyphs) ;
	}

$!width += %!glyphs<last_continuation>.chars ; # for mutiline text
$!current_depth-- ;

@renderings
}

method !render_element($element, $glyphs)
{

my ($k, $e) = $element ;

my ($glyph, $continuation_glyph, $multi_line_glyph) = $glyphs ;

my @renderings ;

my ($v, $f, $final, $wants_address) = self!get_vf($e) ;
$final //= DDT_NOT_FINAL ;

$final = DDT_FINAL if $e.^name eq 'Any' ; # Any is final 

$wants_address //= $final ?? False !! True ;

my ($address, $rendered) = self!get_address($e) ;
$f ~= $wants_address ?? $address !! '' ;

if $final 
	{
	$multi_line_glyph = %!glyphs<last_continuation> ;
	}

# perl stringy $v if role is on
($v, $, $) = self.get_header($v) if $v ~~ Str ;

my ($kvf, @ks, @vs, @fs) := self!split_entry($k, $v, $f) ;

if $kvf.defined
	{
	@renderings.append: $glyph ~ $kvf ;
	}
else
	{
	#@renderings.append: 'final: ' ~ $final ~ ' wants_addr: ' ~ $wants_address ~ ' rendered: ' ~ $rendered ;

	@renderings.append: $glyph ~ (@ks.shift if @ks) ; 
	@renderings.append: @ks.map: { $continuation_glyph ~ $_} ; 
	@renderings.append: @vs.map: { $continuation_glyph ~ $multi_line_glyph ~ $_} ; 
	@renderings.append: @fs.map: { $continuation_glyph ~ $multi_line_glyph ~ $_} ; 
	}

if ! $final && ! $rendered
	{
	@renderings.append: self!render($e).map: { $continuation_glyph ~ $_} 
	}

return @renderings ;
}

method !has_dumper_method($method_name, $type --> Bool) #TODO:is cached
{
so self.can($method_name)[0].candidates.grep: {.signature.params[1].type ~~ $type} ;
}

method !get_vf($e) # :is cached
{
self!has_dumper_method('get_header', $e.WHAT) 
	?? $.get_header($e) #specific to $e
	!! $e.can('ddt_get_header') 
		?? $e.ddt_get_header() # $e class provided
		!! $.get_header($e) ;  # generic handler
}


method !split_entry(Cool $k, Cool $v, Cool $f)
{
my @ks = self!split_text($k) ;
my @vs = self!split_text($v) ; 
my @fs = self!split_text($f) ;

my $kvf = @ks.join('') ~ @vs.join('') ~ @fs.join('') ;

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

method !split_text(Cool $e)
{
return ('type object') unless $e.defined ;

return $e if $!width < 1 ;

# given a, possibly empty, string, split the string on \n and width

my ($index, @lines) ;
for $e.lines -> $line
	{
	my $index = 0 ;
	
	my $line2 = $line.subst(/\t/, '' x 8, :g) ;
	
	while $index < $line2.chars 
		{

		my $chunk = $line2.substr($index, $!width) ;
		$index += $!width ;
		
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

method !get_address($v)
{
state %rendered ;

my $ddt_address = $!address++ ;
my $perl_address = $v.WHERE ;

my ($link, $rendered) = ('', 0) ;

if defined %rendered{$perl_address}
	{
	$rendered++ ;
	$link = ' -> @' ~ %rendered{$perl_address} ;
	}
else
	{
	%rendered{$perl_address} = $ddt_address ;
	}

$perl_address = $.display_perl_address ?? ' ' ~ $perl_address !! '' ;

my $address = $.display_address 
	?? $!colorizer.color(' @' ~ $ddt_address, 'ddt_address') 
		~ $!colorizer.color($perl_address, 'perl_address') 
		~ $!colorizer.color($link, 'link') 
	!! '' ;

$address, $rendered
}

method !get_level_glyphs(Bool $is_last)
{
$!colorizer.color(
	$is_last
		?? (%!glyphs<last>, %!glyphs<last_continuation>, %!glyphs<not_last_continuation>)
		!! (%!glyphs<not_last>, %!glyphs<not_last_continuation>, %!glyphs<not_last_continuation>)
	, 'glyph'
	) ;
}

method !get_class_and_parents ($a) { get_class_and_parents($a) }
sub get_class_and_parents (Any $a) is export { (($a.^name, |get_Any_parents_list($a)).map: {'.' ~ $_}).join(' ') }
 
method !get_Any_parents_list(Any $a) { get_Any_parents_list($a) }
sub get_Any_parents_list(Any $a) is export { $a.^parents.map({ $_.^name }) }

method !get_Any_attributes (Any $a)
{
my @a = try { @a = get_Any_attributes($a) }  ;
$! ?? (('DDT exception: ', "$!"),)  !! @a ;
}

multi sub get_Any_attributes (Any $a) is export 
{
$a.^attributes.grep({$_.^isa(Attribute)}).map:   #weeding out perl internal, thanks to moritz 
	{
	my $name = $_.name ;
	$name ~~ s~^(.).~$0.~ if $_.has-accessor ;

	my $value = $a.defined 
		?? $_.get_value($a) // 'Nil'
		!! 'type object' ; 

	#my $type = $_.type.^name ;

	("$name = ", $value)
	}
}

method !get_title()
{
my Str $t = '' ;

if $.title.defined
	{
	if $.caller.defined and $.caller { $t = $.title ~  ' @ ' ~ callframe(3).file ~ ':' ~ callframe(3).line ~ ' ' }
	else                             { $t = $.title ~ ' ' }
	}
else
	{	
	if $.caller.defined and $.caller { $t = '@ ' ~ callframe(3).file ~ ':' ~ callframe(3).line ~ ' ' }
	else                             { $t = '' }
	}

$!colorizer.color($t, 'title') ;
}

method is_ansi { $!colorizer.is_ansi }

multi method get_glyphs
{
self.is_ansi
	?? { last => "\x1b(0\x6d \x1b(B", not_last => "\x1b(0\x74 \x1b(B",
		last_continuation => '  ', not_last_continuation => "\x1b(0\x78 \x1b(B",
		empty => '  ', max_depth => '...', }
	!! { last => "`- ", not_last => '|- ', last_continuation => '   ', not_last_continuation => '|  ',
		empty => '   ', max_depth => '...', }
}

#class
}


