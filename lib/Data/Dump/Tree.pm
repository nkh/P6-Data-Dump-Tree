
use Data::Dump::Tree::Colorizer ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::Ddt ;

class Data::Dump::Tree does DDTR::DescribeBaseObjects
{
has Colorizer $.colorizer ;

my %default_colors =
	<
	reset       reset

	ddt_address 25       perl_address yellow  link   22
	header      magenta  key         cyan     binder cyan 
	value       reset    wrap        yellow

	gl_0 242  gl_1 yellow  gl_2 green gl_3 red  gl_4 blue

	kb_0 178   kb_1 172   kb_2 33   kb_3 27   kb_4 175   kb_5 169      
	kb_6 34    kb_7 28    kb_8 160  kb_9 124 
	> ;

has @.title is rw ;
has $.indent = '' ;
has Bool $.nl is rw ; # add empty line to the rendering
has Bool $.caller is rw = False ;

has Bool $.color is rw = True ;
has %.colors ;

has $.color_glyphs ;
has @.glyph_colors ;
has @.glyph_colors_cycle ; 

has $.color_kbs ;
has @.kb_colors ;
has @.kb_colors_cycle ; 

has $.wrap_data is rw ;
has $.wrap_header ;
has $.wrap_footer ;

has @.header_filters ;
has @.elements_filters ;
has @.elements_post_filters ;
has @.footer_filters ;

has $.address_from ;

has $.address is rw ;
has %.rendered ;
has %.element_names ;

has DDT_Address_Display $.display_address is rw = DDT_Address_Display::DDT_DISPLAY_CONTAINER ;

has Bool $.display_info is rw = True ;
has Bool $.display_type is rw = True ;
has Bool $.display_perl_address is rw = False ; 

has %.paths ;
has Bool $.keep_paths is rw = False ;

has @.flat ;
has $.flat_depth = 0 ;
has $.width is rw ; 
has $.width_minus = 0 ; 

has $.max_depth is rw = -1 ;
has Bool $.max_depth_message is rw = True ;

has @!renderings ;
method get_renderings() { @!renderings }

method new(*%attributes)
{
my %colors = %attributes<colors> // (), %default_colors ;
 
my $object = self.bless(|%attributes);

for %attributes<does> // () -> $role { $object does $role }

$object does DDTR::DefaultGlyphs unless $object.can('get_glyphs') ;

unless $object.display_info 
	{
	$object.display_type = False ;
	$object.display_address = DDT_DISPLAY_NONE ;
	}

$object 
}

sub DDT(|args) is export { Data::Dump::Tree.new(|args.hash) }

sub ddt(|args) is export
{
if	args.hash<print> 		{ print get_dump(|args) }
elsif	args.hash<note> 		{ note get_dump(|args) }
elsif 	args.hash<get>			{ get_dump(|args) }
elsif	args.hash<get_lines>		{ get_dump_lines(|args) }
elsif	args.hash<get_lines_integrated>	{ get_dump_lines_integrated(|args) } 
elsif	args.hash<curses>		{ ddt_curses(|args) }
elsif	args.hash<remote>		{ ddt_remote( get_dump(|args), :remote_port(args.hash<remote_port>)) }
elsif	args.hash<remote_fold>		{ 'ddt :remote_fold not implemented.'.say } 
else					{ print get_dump(|args) }
}

sub dump(|args) is export { print get_dump(|args) }
sub get_dump(|args) is export { Data::Dump::Tree.new(|args.hash).get_dump(|args.list)}
sub get_dump_lines(|args) is export { Data::Dump::Tree.new(|args.hash).get_dump_lines(|args.list)}
sub get_dump_lines_integrated(|args) is export
{
Data::Dump::Tree.new(|args.hash).get_dump_lines(|args.list).map( { $_.map({ $_.join} ).join } ) ;
}

method ddt(|args)
{
if	args.hash<print> 		{ print self.get_dump(|args) }
elsif	args.hash<note> 		{ note self.get_dump(|args) }
elsif 	args.hash<get>			{ self.get_dump(|args) }
elsif	args.hash<get_lines>		{ self.get_dump_lines(|args) }
elsif	args.hash<get_lines_integrated>	{ self.get_dump_lines_integrated(|args) } 
elsif	args.hash<curses>		{ ddt_curses(|args, :ddt_is(self)) }
elsif	args.hash<remote>		{ ddt_remote( self.get_dump(|args), :remote_port(args.hash<remote_port>)) }
elsif	args.hash<remote_fold>		{ 'ddt :remote_fold not implemented.'.say } 
else					{ print self.get_dump(|args) }
}

method dump(|args) { print self.get_dump(|args) }
method get_dump(|args ) { self.get_dump_lines(|args).map( { $_.map({ $_.join} ).join ~ "\n" } ).join }
method get_dump_lines_integrated(|args) { self.get_dump_lines(|args).map( { $_.map({ $_.join} ).join } ) }

method get_dump_lines(|args)
{
# roles can be passed in new() or as options to dump
# make a clone so we do not pollute the object
my $clone = self.clone(|args.hash) ;

for args.hash<does> // () -> $role { $clone does $role } 

if args.hash<display_info> 
	{
	$clone.display_type = False ;
	$clone.display_address = DDT_DISPLAY_NONE ; 
	}

if $clone.flat && (try require Data::Dump::Tree::LayHorizontal <&lay_horizontal>) !=== Nil 
	{
	$clone.elements_post_filters = lay_horizontal($clone.flat)
	}
else
	{
	$clone.elements_post_filters = ()
	}

$!.note if $! ;


given args.list.elems
	{
	when 0 { return 'DDT called without arguments @ ' ~ callframe(2).file ~ ':' ~ callframe(2).line ~ ' ' }
	when 1 { $clone.render_root: args.list[0] }
	default 
		{
		$clone.reset ;
		$clone.nl = False ;

		@.title andthen $clone.render_root: Data::Dump::Tree::Type::Nothing.new ;

		for args.list
			{
			$clone.title = $_.VAR.?name !=== Nil ?? "{$_.VAR.name} =" !! '' ;
			$clone.render_root: $_, False ;
			}
		}
	}

$clone.wrap_data.defined
	?? ($clone.get_renderings(), $clone.wrap_data) 
	!! $clone.get_renderings() ;
}

method reset
{
$!address = 0 ;
@!renderings = () ;

%!rendered = () ;
%.paths = () ;

$!colorizer //= AnsiColorizer.new ;
$!colorizer.set_colors(%(|%default_colors, |$.colors), $.color) ;

if $.color_glyphs 
	{
	unless @.glyph_colors.elems
		{
		@.glyph_colors.append:  "gl_$_" for ^5 ;
		}
	}
else
	{
	@.glyph_colors = < gl_0 > ;
	}

@!glyph_colors_cycle = |@.glyph_colors xx  * ;

unless @.kb_colors.elems
	{
	@.kb_colors.append:  "kb_$_" for 0 ..10 ;
	}
@!kb_colors_cycle = |@.kb_colors xx  * ; 

$.width //= %+((qx[stty size] || '0 80') ~~ /\d+ \s+ (\d+)/)[0] ; 
$.width -= $.width_minus ; 
}

method render_root(Mu $s, $reset? = True)
{
$.reset if $reset ;

my %glyphs = $.get_level_glyphs(0, True) ; 
my $width = %glyphs<__width> ;
my ($, $, $final, $) = 	$s.WHAT =:= Mu ?? ('', '.Mu', DDT_FINAL ) !! self.get_element_header($s) ;

my $empty_glyph = ('', '', '') ;

self.render_element_structure(
	(self.get_title, '', $s, []),
	0,
	() , 
	($final ?? 0 !! $width, $empty_glyph, $empty_glyph, %glyphs<multi_line>, $empty_glyph, $empty_glyph),
	) ;
			
@!renderings.push: ('', $!indent, '') if $!nl ; 
}

method render_element_structure($element, $current_depth, @head_glyphs, @glyphs)
{
my ($final, $rendered, $s, $continuation_glyph, $wh_token) = 
	$.render_element($element, $current_depth, @head_glyphs, @glyphs) ;

self.render_non_final($s, $current_depth, (|@head_glyphs, $continuation_glyph), $element) unless ($final || $rendered) ;

@!footer_filters and $s.WHAT !=:= Mu and 
	$.filter_footer(self, $s, ($current_depth, (|@head_glyphs, $continuation_glyph), @!renderings))  ;
	
my $wf = $.wrap_footer ;
$wf.defined and $wf($.wrap_data, $s, $final, ($current_depth, (|@head_glyphs, $continuation_glyph), @!renderings), $wh_token)  ;
}

method render_non_final(Mu $s, $current_depth, @head_glyphs, $element)
{
my (@sub_elements, %glyphs) := $.get_sub_elements($s, $current_depth, @head_glyphs, $element) ;

for @sub_elements Z 0..* -> ($sub_element, $index)
	{
	self.render_element_structure(
		$sub_element,
		$current_depth + 1,
		@head_glyphs,
		self.get_element_glyphs(%glyphs, $index == @sub_elements.end),
		) ;
	}
}

method render_element($element, $current_depth, @head_glyphs_no_indent, @glyphs)
{
my @head_glyphs = ('', $.indent, ''), |@head_glyphs_no_indent ;

my ($k, $b, $s, $path) = $element ;
my ($glyph_width, $glyph, $continuation_glyph, $multi_line_glyph, $empty_glyph, $filter_glyph) = @glyphs ;

my $width = $!width - ($glyph_width * ($current_depth + 1)) ;

my ($v, $f, $final, $want_address) = 
	$s.WHAT =:= Mu
		?? ('', '.Mu', DDT_FINAL ) 
		!! self.get_element_header($s) ;

if $.display_type 
	{ 
	$f ~= ':U' unless $s.defined ;

	given '' ~ $s.REPR
		{
		when 'CArray' 
			{
			$f ~~ s/^'.CArray'// ;
			$f = ( $s.defined  ?? '[' ~ $s.elems ~ ']' !! '' ) ~ $f ~ ' <' ~ $_ ~ '>' ;
			}

		when 	'CPointer' | 'CStruct' | 'CUnion' 	{ $f ~= ' <' ~ $_ ~ '>' }
		when 	'VMArray'				{ $f ~= ' <array>' }
		#when 	'Uninstantiable' 			{ $f ~= ' <Uninstantiable>' }
		when 	'P6opaque' 				{}
		default 					{ $f ~= ' <' ~ $_ ~ '>' }

		}
	}
else
	{
	$f = '' ;
	}
 
@!header_filters and $s.WHAT !=:= Mu and  
	$.filter_header(
		self, my $s_replacement, $s,
		($current_depth, $path, (|@head_glyphs, $filter_glyph), @!renderings),
		($k, $b, $v, $f, $final, $want_address)) ;

$s_replacement ~~ Data::Dump::Tree::Type::Nothing and return(True, True, $s, $continuation_glyph) ;

$final //= DDT_NOT_FINAL ;

if $.display_address == DDT_DISPLAY_NONE | DDT_DISPLAY_ALL 
	{
	$want_address = True ;
	}
elsif $.display_address == DDT_DISPLAY_CONTAINER 
	{
	$want_address //= !$final ;
	}

my ($address, $rendered) =
	$s.WHAT !=:= Mu
		?? $want_address ?? self!get_address($s) !! (Nil, False)
		!! (Nil, True) ;

$address = Nil if $.display_address == DDT_DISPLAY_NONE ;

with $s_replacement
	{
	($v, $f, $final, $want_address) = 
		$s_replacement.WHAT =:= Mu
			?? ('', '.Mu', DDT_FINAL ) 
			!! self.get_element_header($s_replacement) ;

	$s := $s_replacement ;
	}

$multi_line_glyph = $empty_glyph if $final ;

# perl stringy $v if role is on
($v, $, $) = self.get_header($v) if $s !~~ Str ;

my ($ddt_address, $perl_address, $link) =
	($address // ('', '', '')).map: { $.superscribe_address($_) } 

my (@kvf, @ks, @vs, @fs) := self!split_entry(
				$current_depth, $width, $k, $b,
				$glyph_width, $v, $f,
				($ddt_address, $link, $perl_address) ) ;

my $render_lines = @!renderings.end ;

if @kvf # single line rendering
	{
	@!renderings.push: (|@head_glyphs, $glyph , |@kvf[0]) ;
	}
else
	{
 	+@ks and @!renderings.push: (|@head_glyphs, $glyph, |@ks[0]) ;

	if @ks > 1
		{
		for @ks[1..*-1] -> $ks
			{
			@!renderings.push: (|@head_glyphs, $continuation_glyph, |$ks) ; 
			} 
		}

	for @vs { @!renderings.push: (|@head_glyphs, $continuation_glyph, $multi_line_glyph, |$_) }

	if $.display_info  
		{

		for @fs { @!renderings.push: (|@head_glyphs, $continuation_glyph, $multi_line_glyph, |$_) }
		}
	}


my ($wh, $wh_token) = ($.wrap_header, ) ;
$wh.defined and $wh_token = $wh(
				$.wrap_data, (@!renderings.end - $render_lines),
				(@head_glyphs, $glyph, $continuation_glyph, $multi_line_glyph),
				(@kvf, @ks, @vs, @fs),
				$s,
				($current_depth, $path, $filter_glyph, @!renderings),
				($k, $b, $v, $f, ($ddt_address, $link, $perl_address), $final, $want_address),
				) ;

$final, $rendered, $s, $continuation_glyph, $wh_token
}

method get_sub_elements(Mu $s, $current_depth, @head_glyphs, $element)
{
my %glyphs = $.get_level_glyphs($current_depth) ; 

my @sub_elements ;

if $current_depth + 1 != $.max_depth 
	{
	@sub_elements = |(self!get_element_subs($s) // ()) ;
	}
else
	{
	if $.max_depth_message
		{
		@sub_elements =	((
				'',
				'',
				Data::Dump::Tree::Type::MaxDepth.new:
					:glyph(%glyphs<max_depth>[1]),
						:depth($.max_depth),
				),) ;
		}
	}

if $.keep_paths
	{
	for @sub_elements Z 0..* -> (($k, $b, $element), $index)
		{
		%.paths{$element.WHICH} = [|(%.paths{$s.WHICH}:v), [$s, $k]] ;

		@sub_elements[$index] = ($k, $b, $element, %.paths{$element.WHICH}) ;
		}
	}

(@!elements_filters || @!elements_post_filters) and $s.WHAT !=:= Mu and
	$.filter_sub_elements(self, $s, ($current_depth, (|@head_glyphs , %glyphs<filter>), @!renderings, $element), @sub_elements)  ;


@sub_elements, %glyphs 
}


method filter_header($self, \s_replacement, Mu $s, @rend, @ref)
{
for @.header_filters -> $filter
	{
	#$filter($self, s_replacement, $s, ($current_depth, $path, @glyphs, @renderings), (k, b, v, f, final, want_address)) ;
	$filter($self, s_replacement, $s, @rend, @ref) ;
	
	CATCH 
		{
		when X::Multi::NoMatch { } #no match
		default                { .rethrow }
		}
	}
}

method filter_sub_elements($self, Mu $s, ($current_depth, @glyphs, @renderings, $element), @sub_elements)
{
for |@.elements_filters, |@.elements_post_filters -> $filter
	{
	$filter($self, $s, ($current_depth, @glyphs, @renderings, $element), @sub_elements) ;
	
	CATCH 
		{
		when X::Multi::NoMatch { } #no match
		default                { .rethrow }
		}
	}
}

method filter_footer($self, Mu $s, ($current_depth, @glyphs, @renderings))
{
for @.footer_filters -> $filter
	{
	$filter($self, $s, ($current_depth, @glyphs, @renderings)) ;
	
	CATCH 
		{
		when X::Multi::NoMatch { } #no match
		default                { .rethrow }
		}
	}
}

method get_element_header(Mu $e) 
{
(self.can('get_header')[0].candidates.grep: {.signature.params[1].type ~~ $e.WHAT}) 
	?? $.get_header($e) #specific to $e
	!! $e.^name ~~ none(self.get_P6_internal()) && $e.can('ddt_get_header') 
		?? $e.ddt_get_header() # $e class provided
		!! $.get_header($e) ;  # generic handler
}	

method !get_element_subs(Mu $s)
{
(self.can('get_elements')[0].candidates.grep: {.signature.params[1].type ~~ $s.WHAT}) 
	?? $.get_elements($s) # self is  $s specific 
	!! $s.^name ~~ none(self.get_P6_internal()) && $s.can('ddt_get_elements')
		?? $s.ddt_get_elements() # $s class provided
		!! $.get_elements($s) ;  # generic handler
}

my regex ansi_color { \e \[ \d+ [\;\d+]* <?before [\;\d+]* > m } 

method !split_entry(
	Int $current_depth, Int $width, Cool $k, Cool $b,
	Int $glyph_width, Cool $v, $f is copy,
	($ddt_address is copy, $link, $perl_address))
{
my (@kvf, @ks, @vs, @fs) ;

# handle \t
my ($k2, $v2, $f2)  = ($k // '', $v // '', $f // '').map: { .subst(/\t/, ' ' x 8, :g) } ;

my $v2_width = (S:g/ <ansi_color> // given $v2).chars ;

if none($k2, $v2, $f2) ~~ /\n/	&& ($k2 ~ $b ~ $f2 ~ $ddt_address ~ $perl_address ~ $link).chars + $v2_width <= $width 
	{
	for
		($k2, 		$k2,				$.color_kbs ?? @.kb_colors_cycle[$current_depth] !! 'key'), 
		($b, 		$b,				$.color_kbs ?? @.kb_colors_cycle[$current_depth] !! 'binder'), 
		($v2, 		$v2,				'value'),
		($f2, 		$.superscribe_type($f2),	'header'),
		($ddt_address, 	' ' ~ $ddt_address,		'ddt_address'),
		($link, 	$link,				'link'), 
		($perl_address, ' ' ~ $perl_address,		'perl_address')
		->
		($entry,	$text, 				$color)
		{
		@kvf[0].push: $!colorizer.color($text, $color) if $entry ne '' ;
		}
	}
else
	{
	@ks = self.split_text($k2, $width + $glyph_width).map:
		{ ($!colorizer.color($_, $.color_kbs ?? @.kb_colors_cycle[$current_depth] !! 'key'), ) }

	# add binder to last key line
	if @ks { @ks[*-1] = (|@ks[*-1], $!colorizer.color($b, $.color_kbs ?? @.kb_colors_cycle[$current_depth] !! 'binder')) }

	@vs = $v2_width == $v2.chars # no color codes in $v2
		?? self.split_text($v2, $width).map: { ($!colorizer.color($_, 'value'), ) }
		!! self.split_colored_text($v2, $width).map: { ($!colorizer.color($_, 'value'), ) }

	# put the footer and addresses on a single line if there is room
	my $f2_ddt_link_perl_length = $f2.chars +  $ddt_address.chars +  $link.chars + $perl_address.chars ;

	if $f2_ddt_link_perl_length
		{
		if $f2 !~~ /\n/ && $f2_ddt_link_perl_length + 2 <= $width
			{
			@fs[0] = #single line
				(
					(
					($f2, 		$.superscribe_type($f2),	'header'),
					($ddt_address, 	' ' ~ $ddt_address,		'ddt_address'),
					($link, 	$link,				'link'), 
					($perl_address, ' ' ~ $perl_address,		'perl_address')
					).map: -> ($entry, $text, $color)
					{
					$!colorizer.color($text, $color) if $entry ne '' ;
					} 
				).List ;
			}
		else 
			{
			for self.split_text($.superscribe_type($f2), $width) Z 0..* -> ($e, $i)
				{
				my $l = $!colorizer.color($e, 'header') ;
				@fs[$i] =  ($l,).List  ;
				}

			if $ddt_address.chars +  $link.chars + $perl_address.chars + 2 <= $width
				{
				@fs.push: 
					(
						(
						($ddt_address, 	' ' ~ $ddt_address,		'ddt_address'),
						($link, 	$link,				'link'), 
						($perl_address, ' ' ~ $perl_address,		'perl_address')
						).map: -> ($entry, $text, $color)
						{
						$!colorizer.color($text, $color) if $entry ne '' ;
						}
					).List ;
				}
			else 
				{
				@fs.push: ( 
						(
						($ddt_address, 	' ' ~ $ddt_address,		'ddt_address'),
						($link, 	$link,				'link'), 
						).map: -> ($entry, $text, $color)
						{
						$!colorizer.color($text, $color) if $entry ne '' ;
						}
					).List ;

				if $.display_perl_address
					{
					@fs.push: $!colorizer.color($.split_text($perl_address, $width), 'perl_address').List ;
					}
				}
			}
		}
	}

@kvf, @ks, @vs, @fs 
}

multi method split_text(Cool:U $text, $width) { '' }

multi method split_text(Cool:D $text, $width)
{
# given a, possibly empty, string, split the string on \n and width

return $text if $width < 1 ;

# combing an empty line returns nothing but we still want a line
$text.lines.map: { (|.comb($width)) || '' } ;
}

multi method split_colored_text(Cool:D $text, $width)
{
# given a, possibly empty, string with ANSI color codes, split the string on \n and width

return $text if $width < 1 ;

my @lines ;
my $length = 0 ;

for $text.lines -> $line 
	{
	@lines.push: '' ;
	$length = 0 ;

	for $line.split: / <ansi_color> /, :v
		{
		given $_
			{
			when Match
				{
				@lines[*-1] ~= $_ ;
				}

			default
				{
				if $length + .chars >= $width 
					{
					@lines.push: '' ;
					$length = 0 ;
					}

				$length += .chars ;	
				@lines[*-1] ~= '' ~ $_ ;
				}
			}		
		}
	}

@lines
}

method superscribe($text) { $text }
method superscribe_type($text) { $text }
method superscribe_address($text) { $text }

method set_element_name(Mu $e, $name)
{
my $perl_address = $e.WHICH ;

if ! $e.defined 
	{
	$perl_address ~= ':DDT:TYPE_OBJECT' ;
	}
else
	{
	$perl_address ~= ':DDT:' ~ $e.WHICH unless $perl_address ~~ /\d ** 4/ ;
	%!element_names{$perl_address} = $name ;
	}
}

method !get_address(Mu $e) { ($.address_from // self)!get_global_address($e) }

method !get_global_address(Mu $e)
{
my $ddt_address = $!address++ ;
my $perl_address = $e.WHICH ;

if ! $e.defined 
	{
	$perl_address ~= ':DDT:TYPE_OBJECT' ;
	}
else
	{
	$perl_address ~= ':DDT:' ~ $e.WHICH unless $perl_address ~~ /\d ** 4/ ;
	}

my ($link, $rendered) = ('', False) ;

if $.rendered{$perl_address}:exists
	{
	$ddt_address = '' ;
	$rendered++ ;
	$link = ' §' ~ $.rendered{$perl_address} ;
	$link ~= ' ' ~ %!element_names{$perl_address} if %!element_names{$perl_address}:exists
	}
else
	{
	$.rendered{$perl_address} = $ddt_address ;
	$ddt_address = '@' ~ $ddt_address ;

	$ddt_address ~= ' ' ~ %!element_names{$perl_address} if %!element_names{$perl_address}:exists
	}

my $address = 
	$.display_address
	??	(
		$ddt_address,
		$.display_perl_address ?? '(' ~ $perl_address ~ ')' !! '',
		$link, 
		) 
	!!	('', '', '',) ;

$address, $rendered
}

method get_level_glyphs($level, Bool $root? = False)
{
my %glyphs = $.get_glyphs() ; 

my $glyph_width = %glyphs<empty>.chars ;
my $multi_line = %glyphs<multi_line> ;

%glyphs = $!colorizer.color(%glyphs, @!glyph_colors_cycle[$level]) ;
%glyphs<multi_line> = $!colorizer.color($multi_line, @!glyph_colors_cycle[$root ?? 0 !! $level + 1]) ;
%glyphs<__width> = $glyph_width ; # squirrel in the width

%glyphs	
}

method get_element_glyphs(%glyphs, Bool $is_last) # is: cached
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
sub get_class_and_parents (Any $a) is export 
{
return $a.^name if $a.REPR ~~ 'Uninstantiable' ;

(($a.^name, |get_Any_parents_list($a).grep({ ! $a.^name.match($_) })).map:
	{'.' ~ S:g/'NativeCall::Types::'// with $_}).join(' ') 
}
 
method !get_Any_parents_list(Any $a) { get_Any_parents_list($a) }
sub get_Any_parents_list(Any $a) is export 
{
return if $a.REPR ~~ 'Uninstantiable' ;

my @a = try { $a.^parents.map: { $_.^name } } 

$! ?? (('DDT exception', ': ', "$!"),)  !! @a ;
}

method !get_attributes (Any $a, @ignore?)
{
my @a = try { @a = get_attributes($a, @ignore) }  ;
$! ?? (('DDT exception', ': ', $!.message),)  !! @a ;
}

multi sub get_attributes (Any $a, @ignore?) is export 
{
my %types ;

if $a.defined && $a.REPR eq 'CArray'
	{
	return |$a.list.map: {$++, ' = ', $_} 
	}

if $a.defined && $a.REPR eq 'CStruct' | 'CUnion'
	{
	_get_attributes($a.WHAT).map:
		{
		my $type = S/':U'$// with $_[2].?type ;
		$type //= '.' ~ $_[2].^name ; 
		$type = S:g/'NativeCall::Types::'// with $type ; 
		
		%types{$_[0]} = $type  ; 
		}  
	}

_get_attributes($a, @ignore, %types) ; 
}

sub _get_attributes (Any $a, @ignore?, %types?) 
{
my @attributes ;

for $a.^attributes.grep({$_.^isa(Attribute)})
   #weeding out perl internal, thanks to moritz 
	{
	my $name = $_.name ;
	
	next if @ignore.first: -> $ignore { $name ~~ /$ignore$/ } ;

	$name ~~ s~^(.).~$0.~ if $_.has_accessor ;

	my $t = %types{$name} // '' ;

	my $value = $a.defined 	?? $_.get_value($a) // Data::Dump::Tree::Type::Nil.new !! $_.type ; 

	# display where attribute is coming from or nothing if base class
	my $p = $_.package.^name ~~ / ( '+' <- [^\+]> * ) $/ ?? " $0" !! '' ;
	my $rw = $_.readonly ?? '' !! ' is rw' ;

 	given  $value.HOW.^name
		{
   		#weeding out perl internal, thanks to jnth 
		when 'NQPClassHOW' 
			{
 			@attributes.push:
				(
				$name, ' = ',
				Data::Dump::Tree::Type::Final.new:
					:value($value.^name),
					:type<NQP>
				) 
			}

		when 'Perl6::Metamodel::NativeHOW' 
			{
 			@attributes.push: 
				(
				$name, ' = ',
				Data::Dump::Tree::Type::Final.new:
					:value($value),
					:type('.' ~ (S:g/'NativeCall::Types::'// with $value.^name) ~ ':U')
				) 
			}

		default
 			{
			@attributes.push: ( "$name$t$rw$p", ' = ', $value ) 
			}
		}
	}

@attributes ;
}

method get_title()
{
my Str $t = '' ;

if @.title
	{
	if $.caller // False { $t = (@.title.join(' ')) ~  ' @ ' ~ callframe(3).file ~ ':' ~ callframe(3).line ~ ' ' }
	else                 { $t = @.title.join(' ') }
	}
else
	{	
	if $.caller // False { $t = '@ ' ~ callframe(3).file ~ ':' ~ callframe(3).line ~ ' ' }
	else                 { $t = '' }
	}

$t ~= ' ' if $t ne '' ;

$t
}


#class
}

