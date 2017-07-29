
use Data::Dump::Tree::Enums ;

class Data::Dump::Tree::Type::Nothing {...}

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

# get_headers: "final" objects return their value and type
multi method get_header (IntStr $i) { $i.Int ~ ' / "' ~ $i.Str ~ '"',  '.' ~ $i.^name, DDT_FINAL }
multi method get_header (Int $i) { $i,  '.' ~ $i.^name, DDT_FINAL }
multi method get_header (Str:U $s) { '', '.' ~ $s.^name, DDT_FINAL }
multi method get_header (Str:D $s) { $s, '.' ~ $s.^name, DDT_FINAL } 
multi method get_header (Rat $r) { $r  ~ ' (' ~ $r.numerator ~ '/' ~ $r.denominator ~ ')', '.' ~ $r.^name, DDT_FINAL }
multi method get_header (Range $r) { $r.gist , '.' ~ $r.^name, DDT_FINAL }
multi method get_header (Seq $s) { '', '.' ~ $s.^name ~ ( $s.is-lazy ?? '(*)' !! ''), DDT_FINAL }
multi method get_header (Bool $b) { ( $b, '.' ~ $b.^name, DDT_FINAL ) }
multi method get_header (Regex $r) { $r.perl.substr(6) ,  '.' ~ $r.^name, DDT_FINAL, } 

multi method get_header (Pair $p) 
	{
	if $p.key ~~ Str | Int && $p.value ~~ Str | Int 
		{
		'(' ~ $p.key ~ ', ' ~ $p.value ~ ')', '.' ~ $p.^name, DDT_FINAL
		}
	else
		{
		'', '.' ~ $p.^name
		}
	}

multi method get_elements (Pair $p)
	{
	if $p.key ~~ Str | Int 
		{
		( ('k:' ~ $p.key ~ ", v:", '', $p.value), )
		}
	else
		{
		( ('key', ': ', $p.key), ('value', ' = ', $p.value), )
		}
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
multi method get_header (Sub $s) { ( $s.name || '<anon>'), '.' ~ $s.^name, DDT_FINAL }

# get_headers: containers return some information and their type
multi method get_header (Any $a) 
{
given $a.^name 
	{
	when 'any' { '', '.' ~ $a.^name, DDT_FINAL }
	when any(self.get_P6_internal()) { '', '.' ~ $a.^name, DDT_FINAL }
	default { '', self!get_class_and_parents($a) } # some object 
	}
}
multi method get_elements (Any $a) { self!get_Any_attributes($a) } 

multi method get_header (List:U $l) { '', '()', DDT_FINAL }
multi method get_header (List:D $l) { '', '(' ~ $l.elems ~ ')' }
multi method get_elements (List $l) { $l.list.map: {$++, ' = ', $_} }

multi method get_header (Array:U $a) { '', '[]', DDT_FINAL }
multi method get_header (Array:D $a) { '', '[' ~ $a.elems ~ ']' ~ $a.^name.subst(/^.**5/, '') }
multi method get_elements (Array $a) 
{ 
if $a.^name eq 'Array'	{ $a.list.map: {$++, ' = ', $_} }
	else 
	{
	my @a = self!get_Array_attributes($a) ;
	@a.push: |$a.list.map({$++, ' = ', $_}) ;

	@a
	}
}

method !get_Array_attributes(Array $a)
{
my @attributes ;
for $a.^attributes.grep({$_.^isa(Attribute)})
   #weeding out perl internal, thanks to moritz 
	{
	my $name = $_.name ;
	next if $name ~~ / (descriptor|reified|todo) $/ ;

	$name ~~ s~^(.).~$0.~ if $_.has_accessor ;

	my $value = $a.defined 	?? $_.get_value($a) // 'Nil' !! $_.type ; 

	my $p = $_.package.^name ~~ / ( '+' <- [^\+]> * ) $/ ?? " $0" !! '' ;
	my $rw = $_.readonly ?? '' !! ' is rw' ;

	@attributes.push: ("$name$rw$p", ' = ', $value) ; 
	}

@attributes
}

multi method get_header (Hash:U $h) { '', '{}', DDT_FINAL }
multi method get_header (Hash:D $h) { '', '{' ~ $h.elems ~ '}' }
multi method get_elements (Hash:D $h) { $h.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} }

multi method get_header (Stash $s) { '', '.' ~ $s.^name ~ ' {' ~ ($s.keys.flat.elems) ~ '}' }
multi method get_elements (Stash $s) { $s.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} }

multi method get_header (Map $m) { '', '.' ~ $m.^name } 
multi method get_elements (Map $m) { $m.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} }

multi method get_header (Set:D $s) { '', '.' ~ $s.^name ~ '(' ~ $s.elems ~ ')'  }
multi method get_elements (Set $s) { $s.keys.map: {$++, ' = ', $_} }

} #role

role DDTR::StringLimiter
{

method limit_string(Str $s, $limit)
{
if $limit.defined && $s.chars > $limit
	{
	$s.substr(0, $limit) ~ '(+' ~ $s.chars - $limit ~ ')'
	}
else
	{
	$s 
	}	
}


} #role


role DDTR::QuotedString 
{
multi method get_header (IntStr $i) { $i.Int ~ ' / "' ~ $i.Str ~ '"',  '.' ~ $i.^name, DDT_FINAL }
multi method get_header (Str:D $s) { "'$s'", '.' ~ $s.^name, DDT_FINAL } 
}

role DDTR::PerlString 
{
multi method get_header (IntStr $i) { $i.Int ~ ' / "' ~ $i.Str ~ '"',  '.' ~ $i.^name, DDT_FINAL }
multi method get_header (Str:D $s) { $_ = $s.perl ; S:g/^\"(.*)\"$/$0/, '.' ~ $s.^name, DDT_FINAL } 
}

role DDTR::PerlSub
{
multi method get_header (Routine $r) { $r.perl, '.' ~ $r.^name, DDT_FINAL }
multi method get_header (Sub $s) { $s.perl, '.' ~ $s.^name, DDT_FINAL }
}

class Data::Dump::Tree::Type::NQP
{
has $.class ;

multi method ddt_get_header { $.class, ' ** NQP **', DDT_FINAL }
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


