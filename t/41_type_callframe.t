#!/usr/bin/env perl6

use Test ;
plan 4 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;

my $d = Data::Dump::Tree.new ;

multi sub Stash_no_sub($dumper,  Stash $s, ($depth, $glyph, @renderings, $), @sub_elements)
{
# remove subs from stash
@sub_elements = @sub_elements.grep: { $_[2] !~~ Sub} ;
}

multi sub compress_ddt($dumper, \r, Data::Dump::Tree $s, @r, (\k, \b, \v, \f, \final, \want_address))
{
final = DDT_FINAL ;
}

my $dump = $d.ddt: :get, [callframe()], :!color, :width(75), :elements_filters[&Stash_no_sub], :header_filters[&compress_ddt] ;

# Earlier rakudo versions had 35 lines, newer rakudo versions have 36 lines
# because a new entry has come into the stash we're looking at here.
is($dump.lines.elems, (35 | 36), 'lines of filtered callframedump') or diag $dump ;

like $dump, /CallFrame/, 'CallFrame' or diag $dump ;
like $dump, /'$.my'/, '$.my element' or diag $dump ;
like $dump, /'Data::Dump::Tree'/, 'Data::Dump::Tree element' or diag $dump ;

