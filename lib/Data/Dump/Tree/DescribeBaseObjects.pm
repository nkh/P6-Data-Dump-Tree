
use Data::Dump::Tree::Enums ;

role Data::Dump::Tree::Role::DescribeBaseObjects
{
# get_headers: "final" objects returnf their value and type
multi method get_header (Int $i) { ($i,  '.' ~ $i.^name, DDT_FINAL) }
multi method get_header (Str:U $s) { ('type object', '.' ~ $s.^name, DDT_FINAL) }
multi method get_header (Str:D $s) { ($s, '.' ~ $s.^name, DDT_FINAL) } 
multi method get_header (Rat $r) { ('den: ' ~ $r.denominator ~ ' num: ' ~ $r.numerator, '.' ~ $r.^name, DDT_FINAL) }

# Block must be declare or it groaks when passed a Sub
#TODO: report to P6P
multi method get_header (Block $b) { ($b.perl, '.' ~ $b.^name, DDT_FINAL) }
multi method get_header (Routine $r) { ('', '.' ~ $r.^name, DDT_FINAL) }
multi method get_header (Sub $s) { ($s.perl, '.' ~ $s.^name, DDT_FINAL) }

# get_headers: containers return some information and their type
multi method get_header (Any $a) 
{
$a.^name eq 'Any' 
	?? ('', '.' ~ $a.^name, DDT_FINAL) # real Any
	!! ('', self!get_class_and_parents($a)) # some object
}

multi method get_elements (Any $a) { [ self!get_Any_attributes($a)] } 

multi method get_header (Match $a) { ('[' ~ $a.from ~ '..' ~ $a.to ~ '|', '.' ~ $a.^name, DDT_FINAL) } 

multi method get_header (Grammar $a) { ($a.perl ~ ' ', '.Grammar', DDT_FINAL,) } 

multi method get_header (List $l) { ('', '(' ~ $l.elems ~ ')') }
multi method get_elements (List $l) { [ ($l Z 0 .. *).map: -> ($v, $i) {"$i = ", $v} ] }

multi method get_header (Array $a) { ('', '[' ~ $a.elems ~ ']') }

multi method get_header (Hash $h) { ('', '{' ~ $h.elems ~ '}') }
multi method get_elements (Hash $h) { [ $h.sort(*.key)>>.kv.map: -> ($k, $v) {"$k => ", $v} ] }

}

role DDTR::DescribeBaseObjects does Data::Dump::Tree::Role::DescribeBaseObjects {} 

role Data::Dump::Tree::Role::MatchDetails 
{

multi method get_header (Match:U $m) { ( 'type object', '.' ~ $m.^name, DDT_FINAL) }
multi method get_header (Match:D $m) 
{
$m.hash.elems
	?? ( $m ~ ' '  ~ ' [' ~ $m.from ~ '..' ~ $m.to ~ '| ', '.' ~ $m.^name) 
	!! ( $m ~ ' ', '.' ~ $m.^name, DDT_FINAL, DDT_HAS_ADDRESS) #final with address
}

multi method get_elements (Match $m)
{

[
($m.hash.keys.sort: { ($m{$^a}.from // 0) <=> ($m{$^b}.from // 0)} )
	.map: 
		{
		( $_ ~ ' [' ~ ($m{$_}.from // '?') ~ '..' ~ ($m{$_}.to // '?') ~ '|: ', $m{$_})
		} 
]

}

#role MatchDetails
}

role DDTR::MatchDetails does Data::Dump::Tree::Role::MatchDetails {} 


role Data::Dump::Tree::Role::PerlString 
{
multi method get_header (Str:D $s) { ($s.perl, '.' ~ $s.^name, DDT_FINAL) } 
}
role DDTR::PerlString does Data::Dump::Tree::Role::PerlString {}

role Data::Dump::Tree::Role::SilentSub
{
multi method get_header (Routine $r) { ('', '.' ~ $r.^name, DDT_FINAL) }
multi method get_header (Sub $r) { ('', '.' ~ $r.^name, DDT_FINAL) }
}
role DDTR::SilentSub does Data::Dump::Tree::Role::SilentSub {} 

class Data::Dump::Tree::Type::Nothing
{
multi method ddt_get_header { ('', '', DDT_FINAL) }
}

role Data::Dump::Tree::Role::UnicodeGlyphs
{

multi method get_glyphs
{
	{ 
	last => '└', not_last => '├', last_continuation => ' ', not_last_continuation => '│',
	multi_line => '│', empty => ' ', max_depth => '…'
	}
}

#role
}

role DDTR::UnicodeGlyphs does Data::Dump::Tree::Role::UnicodeGlyphs {} 


role Data::Dump::Tree::Role::AsciiGlyphs
{

multi method get_glyphs
{
	{
	last => "`- ", not_last => '|- ', last_continuation => '   ', not_last_continuation => '|  ',
	multi_line => '|  ', empty => '   ', max_depth => '...'
	}
}

#role
}

role DDTR::AsciiGlyphs does Data::Dump::Tree::Role::AsciiGlyphs {} 

role Data::Dump::Tree::Role::AnsiGlyphs
{

multi method get_glyphs
{
	{
	last => "\x1b(0\x6d \x1b(B", not_last => "\x1b(0\x74 \x1b(B",
	last_continuation => '  ', not_last_continuation => "\x1b(0\x78 \x1b(B",
	multi_line => "\x1b(0\x78 \x1b(B", empty => '  ', max_depth => '...', 
	}
}

#role
}

role DDTR::AnsiGlyphs does Data::Dump::Tree::Role::AnsiGlyphs {} 

role Data::Dump::Tree::Role::FixedGlyphs
{
has $.fixed_glyph ;

multi method get_glyphs
{
	{
	last => $.fixed_glyph, not_last => $.fixed_glyph,
	last_continuation => $.fixed_glyph, not_last_continuation => $.fixed_glyph,
	multi_line => $.fixed_glyph, empty => ' ' x $.fixed_glyph.chars, max_depth => '...', 
	}
}

#role
}

role DDTR::FixedGlyphs does Data::Dump::Tree::Role::FixedGlyphs {} 


