#!/usr/bin/env perl6

# transform strings into objects that render in a bit better way

# .Seq(3) @0
# ├ 0 = Scalar: 1(0).Str
# ├ 1 = Scalar: 10000(5747).Str
# └ 2 = Int: 4238(0).Str

use Data::Dump::Tree ;

use Data::Dump::Tree::Enums ;
use Terminal::ANSIColor ;

class S { has $.a; has $.b ; method ddt_get_header() { $.a ~ '(' ~ $.b ~ ')', '.Scalar', DDT_FINAL } }
sub s ($a, $b) { S.new: :$a, :$b }

class I { has $.a; has $.b ; method ddt_get_header() { $.a ~ '(' ~ $.b ~ ')', '.Int', DDT_FINAL } }

multi sub f($dumper, \r, Str $s, ($depth, $path, $glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
# can replace ourselves with something else, do not forget to update k, b, v, accordingly
# r = < abc def > ;

if $s ~~ 'parsed'
	{
	#@renderings.push: (|$glyph, 'Parsed below') ;

	#k = '<my Int> ' ;
	#b = '<my b>' ;
	v = '123(1)' ;
	f = color('bold white on_yellow') ~ '.Parsed' ~  color('reset') ;
	final = DDT_FINAL ;
	#want_address = True ;
	}
}

ddt :header_filters[&f], (s(5, 6), S.new(:0a, :0b), I.new(:0a, :7b), 'string', 'parsed').Seq ;

