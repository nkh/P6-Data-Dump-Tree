
use Data::Dump::Tree::Enums ;

class Data::Dump::Tree::Type::Nothing {...}

my sub is_final($element, $name) { $element.^name eq $name ??  (DDT_FINAL,) !! (DDT_NOT_FINAL, DDT_HAS_NO_ADDRESS) }

role DDTR::DescribeBaseObjects
{
method get_P6_internal { ('!UNIT_MARKER', 'GLOBAL', 'EXPORT', 'Data', 'Test') }

# ConsumeSeq 
has %.consume_seq is rw = (:!consume_lazy, :vertical, :max_element_vertical<10>, :max_element_horizontal<100>) ;

multi method get_header (Seq $s) 
	{
	%.consume_seq<consume_lazy vertical max_element_vertical max_element_horizontal> [Z//]= False, True, 10, 100 ;

	if $s.is-lazy
		{
		if ! %.consume_seq<consume_lazy>
			{
			( '', '.' ~ $s.^name ~ '(*)', DDT_FINAL )
			}
		else
			{
			if %.consume_seq<vertical> 
				{ 
				( '', '.' ~ $s.^name ~ '(*)' )
				}
			else
				{ 
				my @elements = ($s)[0..^%.consume_seq<max_element_horizontal>].map({.gist}) ;
				@elements.push: '...*' ;

				( '(' ~ @elements.join(', ') ~ ')', '.' ~ $s.^name ~ '(*)', DDT_FINAL )
				}
			}
		}
	else
		{
		if %.consume_seq<vertical> 
			{ 
			( '', '.' ~ $s.^name ~ '(' ~ $s.elems ~ ')' )
			}
		else
			{ 
			my @elements = ($s)[0..^%.consume_seq<max_element_horizontal>].grep({.defined}).map({.gist})  ;
			@elements.push: '...' if ($s)[%.consume_seq<max_element_horizontal>].defined ;

			( '(' ~ @elements.join(', ') ~ ')', '.' ~ $s.^name ~ '(' ~ $s.elems ~ ')', DDT_FINAL )
			}
		}
	}

multi method get_elements (Seq $s)
	{
	my @cache = $s.cache ;
	my @elements = @cache[0..^%.consume_seq<max_element_vertical>].grep({.defined}).map: {$++, ' = ', $_} ;

	@elements.push: ('...' ~ ($s.is-lazy ?? '*' !! ''), '', Data::Dump::Tree::Type::Nothing.new)
		if @cache[%.consume_seq<max_element_vertical>].defined ;

	@elements
	} 

multi method get_header (IntStr $i) 
{
~$i.Int eq $i.Str 
	?? ( $i.Int ,  '.' ~ $i.^name, |is_final($i, 'IntStr') )
	!! ( $i.Int ~ ' / "' ~ $i.Str ~ '"',  '.' ~ $i.^name, |is_final($i, 'IntStr') )
}
multi method get_elements (IntStr $e) { self!get_attributes($e) }
 
multi method get_header (Int:U $i) { '',  'Int', DDT_FINAL }
multi method get_header (Int:D $i) { $i,  $i.^name eq 'Int' ?? '   ' !! '.' ~ $i.^name, |is_final($i, 'Int') }
multi method get_elements (Int $e) { self!get_attributes($e) }

multi method get_header (Str:U $s) { '', '.' ~ $s.^name, DDT_FINAL }
multi method get_header (Str:D $s) { $s, '.' ~ $s.^name, |is_final($s, 'Str') } 
multi method get_elements (Str $e) { self!get_attributes($e) }

multi method get_header (Num:D $n) { $n, '.' ~ $n.^name, |is_final($n, 'Num') } 
multi method get_header (Rat $r) { $r  ~ ' (' ~ $r.numerator ~ '/' ~ $r.denominator ~ ')', '.' ~ $r.^name, |is_final($r, 'Rat') }
multi method get_elements (Rat $e) { self!get_attributes($e, <numerator denominator>) }

multi method get_header (Range $r) { $r.gist , '.' ~ $r.^name, |is_final($r, 'Range') }
multi method get_elements (Range $e) { self!get_attributes($e, <is-int min max excludes-min excludes-max infinite>) }

multi method get_header (Bool $b) { ( $b, '.' ~ $b.^name, |is_final($b, 'Bool') ) }
multi method get_elements (Bool $e) { self!get_attributes($e, <key value>) }

multi method get_header (Regex $r) { $r.perl.substr(6) ,  '.' ~ $r.^name, DDT_FINAL } 

multi method get_header (Pair $p) 
	{
	$p.key ~~ Str | Int && $p.value ~~ Str | Int 
		?? ( '(' ~ $p.key ~ ', ' ~ $p.value ~ ')', '.' ~ $p.^name, |is_final($p, 'Pair') )
		!! ('', '.' ~ $p.^name )
	}

multi method get_elements (Pair $p)
	{
	|self!get_attributes($p, <key value>,),

	$p.key ~~ Str | Int 
		?? ('k:' ~ $p.key ~ ", v:", '', $p.value) 
		!! (('key', ': ', $p.key), ('value', ' = ', $p.value))
	} 

multi method get_header (Junction $j) { $j.gist, '.' ~ $j.^name, DDT_FINAL }

multi method get_header (Match $m) 
	{
	 $m.from == $m.to - 1 
		 ?? (~$m, Q/[/ ~ $m.from ~ Q/]/ , DDT_FINAL)
		 !! (~$m, Q/[/ ~ $m.from ~ '..' ~ $m.to - 1 ~ ']', DDT_FINAL) 
	}

# Block must be declare or it groaks when passed a Sub
multi method get_header (Block $b) { $b.perl, '.' ~ $b.^name, DDT_FINAL }
multi method get_header (Routine $r) { '' , '.' ~ $r.^name, DDT_FINAL }
multi method get_header (Sub $s) 
{
	($s.name || '<anon>') ~ ' ' ~ $s.signature.gist,
	$s.^name  ~~ /NativeCall/ ?? '.Sub <NativeCall>' !! '.Sub',
	DDT_FINAL
}

multi method get_header (Any $a) 
{
given $a.^name 
	{
	when 'any' { '', '.' ~ $a.^name, DDT_FINAL }
	when any(self.get_P6_internal()) { '', '.' ~ $a.^name, DDT_FINAL }
	default { '', self!get_class_and_parents($a) } # some object 
	}
}
multi method get_elements (Any $a) { self!get_attributes($a) } 

multi method get_header (List:U $l) { '', '()', DDT_FINAL }
multi method get_header (List:D $l) { '', '(' ~ $l.elems ~ ')' }
multi method get_elements (List $l) {
	|self!get_attributes($l, <reified todo>),
	|$l.list.map: {$++, ' = ', $_} }

multi method get_header (Array:U $a) { '', '[]', DDT_FINAL }
multi method get_header (Array:D $a) { '', '[' ~ $a.elems ~ ']' ~ $a.^name.substr(5) }
multi method get_elements (Array $a) { 
	|self!get_attributes($a, <descriptor reified todo>),
	|$a.list.map: {$++, ' = ', $_} }

# native array
multi method get_header (array $a) { '', '[' ~ $a.elems ~ ']' ~ $a.^name.substr(5)}
multi method get_elements (array $a) { |$a.list.map: {$++, ' = ', $_} }

multi method get_header (Hash:U $h) { '', '{}', DDT_FINAL }
multi method get_header (Hash:D $h) { '', '{' ~ $h.elems ~ '}' ~ $h.^name.substr(4) }
multi method get_elements (Hash:D $h) {
	|self!get_attributes($h, <descriptor storage>),
	|($h.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v}) }

multi method get_header (Stash $s) { '', '.' ~ $s.^name ~ ' {' ~ ($s.keys.flat.elems) ~ '}' }
multi method get_elements (Stash $s) { $s.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} }

multi method get_header (Map $m) { '', '.' ~ $m.^name } 
multi method get_elements (Map $m) {
	|self!get_attributes($m, (<storage>,)),
	|$m.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} }

multi method get_header (Set:D $s) { '', '.' ~ $s.^name ~ '(' ~ $s.elems ~ ')'  }
multi method get_elements (Set $s) {
	|self!get_attributes($s, <WHICH elems>),
	|$s.keys.map: {$++, ' = ', $_} }

multi method get_header (Enumeration $e) { '', '.' ~ $e.^name, DDT_FINAL } 

} #role

class Data::Dump::Tree::Type::Nil
{
method ddt_get_header { 'Nil', '', DDT_FINAL }
}

class Data::Dump::Tree::Type::ValueOnly
{
has $.v = '' ;

method new ($v) { self.bless: :v($v) }
multi method ddt_get_header { "$.v", '', DDT_FINAL }

sub DVO($v) is export { Data::Dump::Tree::Type::ValueOnly.new($v) }
}

role DDTR::StringLimiter
{

method limit_string(Str $s, $limit)
{
$limit.defined && $s.chars > $limit
	?? $s.substr(0, $limit) ~ '(+' ~ $s.chars - $limit ~ ')'
	!! $s 
}


} #role


role DDTR::QuotedString 
{
multi method get_header (IntStr $i) { $i.Int ~ ' / "' ~ $i.Str ~ '"',  '.' ~ $i.^name, DDT_FINAL }
multi method get_header (Str:D $s) { "'$s'", '.' ~ $s.^name, |is_final($s, 'Str') } 
}

role DDTR::PerlString
{
multi method get_header (IntStr $i) { $i.Int ~ ' / "' ~ $i.Str ~ '"',  '.' ~ $i.^name, DDT_FINAL }
multi method get_header (Str:D $s) { $_ = $s.perl ; S:g/^\"(.*)\"$/$0/, '.' ~ $s.^name, |is_final($s, 'Str') } 
}

class Data::Dump::Tree::Type::MaxDepth
{
has $.glyph ;
has $.depth ;

multi method ddt_get_header { $.glyph ~ " max depth($.depth)", '', DDT_FINAL }
}

class Data::Dump::Tree::Type::Nothing
{
multi method ddt_get_header { '', '', DDT_FINAL }
}

class Data::Dump::Tree::Type::Final
{
has $.value = '' ;
has $.type = '' ;

multi method ddt_get_header { $.value, $.type, DDT_FINAL }
}

role DDTR::CompactUnicodeGlyphs
{

multi method get_glyphs
{
	{ 
	last => '└', not_last => '├', last_continuation => ' ', not_last_continuation => '│',
	multi_line => '│', empty => ' ', max_depth => '…',
	filter => '│', # not last continuation
	}
}

#role
}

role DDTR::AsciiGlyphs
{

multi method get_glyphs
{
	{
	last => "`- ", not_last => '|- ', last_continuation => '   ', not_last_continuation => '|  ',
	multi_line => '|  ', empty => '   ', max_depth => '...',
	filter => '|  ', # not last continuation 
	}
}

#role
}

role DDTR::DefaultGlyphs # unicode + space
{

multi method get_glyphs
{
	{ 
	last => '└ ', not_last => '├ ', last_continuation => '  ', not_last_continuation => '│ ',
	multi_line => '│ ', empty => '  ', max_depth => '…',
	filter => '│ ', # not last continuation
	}
}

#role
}


