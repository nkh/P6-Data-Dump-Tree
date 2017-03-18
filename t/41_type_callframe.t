#!/usr/bin/env perl6

use Test ;
plan 4 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;

my $d = Data::Dump::Tree.new ;

multi sub Stash_no_sub( Stash $s, ($depth, $glyph, @renderings), @sub_elements)
{
# remove subs from stash
@sub_elements = @sub_elements.grep: { $_[2] !~~ Sub} ;
}

multi sub compress_ddt(\r, Data::Dump::Tree $s, @r, (\k, \b, \v, \f, \final, \want_address))
{
final = DDT_FINAL ;
}

my $dump = $d.get_dump([callframe()], color => False, width => 75, elements_filters => (&Stash_no_sub,), header_filters =>(&compress_ddt,)) ;

is($dump.lines.elems, 35, 'lines of filtered callframedump') or diag $dump ;

like $dump, /CallFrame/, 'CallFrame' or diag $dump ;
like $dump, /'$.my'/, '$.my element' or diag $dump ;
like $dump, /'Data::Dump::Tree'/, 'Data::Dump::Tree element' or diag $dump ;

