
use Data::Dump::Tree::Enums ;

role DDTR::DescribeBaseObjects
{
method get_P6_internal { ('!UNIT_MARKER', 'GLOBAL', 'EXPORT') }

# get_headers: "final" objects returnf their value and type
multi method get_header (IntStr $i) { $i.Int ~ ' / "' ~ $i.Str ~ '"',  '.' ~ $i.^name, DDT_FINAL }
multi method get_header (Int $i) { $i,  '.' ~ $i.^name, DDT_FINAL }
multi method get_header (Str:U $s) { 'type object', '.' ~ $s.^name, DDT_FINAL }
multi method get_header (Str:D $s) { $s, '.' ~ $s.^name, DDT_FINAL } 
multi method get_header (Rat $r) { $r  ~ ' (' ~ $r.numerator ~ '/' ~ $r.denominator ~ ')', '.' ~ $r.^name, DDT_FINAL }
multi method get_header (Match $m) { '[' ~ $m.from ~ '..' ~ $m.to ~ '|', '.' ~ $m.^name, DDT_FINAL } 
multi method get_header (Grammar $g) { $g.perl ~ ' ',  '.' ~ $g.^name, DDT_FINAL, } 
multi method get_header (Regex $r) { $r.perl.substr(6) ,  '.' ~ $r.^name, DDT_FINAL, } 

# Block must be declare or it groaks when passed a Sub
#TODO: report to P6P
multi method get_header (Block $b) { $b.perl, '.' ~ $b.^name, DDT_FINAL }
multi method get_header (Routine $r) { '' , '.' ~ $r.^name, DDT_FINAL }
multi method get_header (Sub $s) { ( $s.name || '<anon>'), '.' ~ $s.^name, DDT_FINAL }

# get_headers: containers return some information and their type
multi method get_header (Any $a) 
{
#$a.^name.say ;
#$.get_P6_internal().say ;

given $a.^name 
	{
	when 'any' { ( '', '.' ~ $a.^name, DDT_FINAL ) }
	when any(self.get_P6_internal()) { ( '', '.' ~ $a.^name, DDT_FINAL ) }
	default { ( '', self!get_class_and_parents($a) ) } # some object 
	}
}
multi method get_elements (Any $a) { self!get_Any_attributes($a) } 

multi method get_header (List $l) { '', '(' ~ $l.elems ~ ')' }
multi method get_elements (List $l) { my $i = 0 ; $l.list.map: -> $v {$i++, ' = ', $v} }

multi method get_header (Array $a) { '', '[' ~ $a.elems ~ ']' }

multi method get_header (Hash $h) { '', '{' ~ $h.elems ~ '}' }
multi method get_elements (Hash $h) { $h.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} }

multi method get_header (Stash $s) { '', '.' ~ $s.^name ~ ' {' ~ ($s.keys.flat.elems) ~ '}' }
multi method get_elements (Stash $s) { $s.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} }

multi method get_header (Map $m) { '', '.' ~ $m.^name } 
multi method get_elements (Map $m) { $m.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} }

}

role DDTR::MatchDetails 
{

multi method get_header (Match:U $m) { 'type object', '.' ~ $m.^name, DDT_FINAL }
multi method get_header (Match:D $m) 
{
$m.caps.elems
	?? ( Q/'/ ~ $m ~ Q/'/  ~ ' [' ~ $m.from ~ '..' ~ $m.to ~ '| ', '.' ~ $m.^name ) 
	!! ( Q/'/ ~ $m ~ Q/'/  ~ ' [' ~ $m.from ~ '..' ~ $m.to ~ '| ', '.' ~ $m.^name , DDT_FINAL, DDT_HAS_ADDRESS ) 
}

multi method get_elements (Match $m)
{
$m.caps.map: -> $p
	{
	my ($k, $v) = $p.kv ;
	( $k, ' => ', $v )
	} 
}



#role MatchDetails
}

role DDTR::QuotedString 
{
multi method get_header (Str:D $s) { "'$s'", '.' ~ $s.^name, DDT_FINAL } 
}

role DDTR::PerlString 
{
multi method get_header (Str:D $s) { $s.perl, '.' ~ $s.^name, DDT_FINAL } 
}

role DDTR::PerlSub
{
multi method get_header (Routine $r) { $r.perl, '.' ~ $r.^name, DDT_FINAL }
multi method get_header (Sub $s) { $s.perl, '.' ~ $s.^name, DDT_FINAL }
}

class Data::Dump::Tree::Type::Nothing
{
multi method ddt_get_header { '', '', DDT_FINAL }
}

role DDTR::UnicodeGlyphs
{

multi method get_glyphs
{
	{ 
	last => '└', not_last => '├', last_continuation => ' ', not_last_continuation => '│',
	multi_line => '│', empty => ' ', max_depth => ' …',
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
	multi_line => '|  ', empty => '   ', max_depth => '   ...',
	filter => '|  ', # not last continuation 
	}
}

#role
}

role DDTR::AnsiGlyphs
{

multi method get_glyphs
{
	{
	last => "\x1b(0\x6d \x1b(B", not_last => "\x1b(0\x74 \x1b(B",
	last_continuation => '  ', not_last_continuation => "\x1b(0\x78 \x1b(B",
	multi_line => "\x1b(0\x78 \x1b(B", empty => '  ', max_depth => '  ...', 
	filter => "\x1b(0\x78 \x1b(B" , # not last continuation
	}
}

#role
}


