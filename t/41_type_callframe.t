#!/usr/bin/env perl6

use Test ;
plan 6 ;

use Data::Dump::Tree ;

my $d = Data::Dump::Tree.new ;

multi sub Stash_no_sub( Stash $s, ($depth, $glyph, @renderings), @sub_elements)
{
# simply show that we were called
#@renderings.append: $glyph ~ "SUB ELEMENTS " ~ $s.^name ;

@sub_elements = @sub_elements.grep: { $_[2] !~~ Sub } ;
#@sub_elements = @sub_elements.grep: { $_[2] !~~ Data::Dump::Tree } ;
}

multi sub compress_ddt(\r, Data::Dump::Tree $s, @r, (\k, \b, \v, \f, \final, \want_address))
{
final = DDT_FINAL ;
}

my $dump = $d.get_dump([callframe()], color => False, width => 75, elements_filters => (&Stash_no_sub,), header_filters =>(&compress_ddt,)) ;
is($dump.lines.elems, 20, '20 lines of filtered callframedump ') or diag $dump ;

like $dump, /CallFrame/, 'CallFrame' or diag $dump ;
like $dump, /'level = 2.Int'/, 'level' or diag $dump ;
like $dump, /'%.my'/, '%.my element' or diag $dump ;
like $dump, /Mu/, 'Mu element' or diag $dump ;
like $dump, /'Data::Dump::Tree'/, 'Data::Dump::Tree element' or diag $dump ;

# └ 0 = .CallFrame @1
#   ├ $.level = 2.Int
#   ├ %.annotations = {2} @3
#   │ ├ file => t/41_type_callframe.t.Str
#   │ └ line => 24.Str
#   └ %.my = .Stash {50} @6
#     ├ !UNIT_MARKER => .!UNIT_MARKER
#     ├ $! => .Any @8
#     ├ $/ => .Any @9 = @8
#     ├ $=finish => .Mu
#     ├ $=pod => [0] @10
#     ├ $?PACKAGE => .GLOBAL
#     ├ $_ => .Any @12 = @8
#     ├ $d => .Data::Dump::Tree+{DDTR::AnsiGlyphs} .Data::Dump::Tree @13
#     ├ $dump => .Any @14 = @8
#     ├ $¢ => .Any @15 = @8
#     ├ ::?PACKAGE => .GLOBAL
#     ├ EXPORT => .EXPORT
#     └ GLOBALish => .GLOBAL

