#!/usr/bin/env perl6

use Test ;
plan 17 ;

use Data::Dump::Tree ;

my $d = Data::Dump::Tree.new ;

my $dump = $d.ddt: :get, 1 => 'a', :!color ;

like $dump.lines[0], /'(1, a).Pair'/, 'class name' or diag $dump ;
is($dump.lines.elems, 1, '1 dump lines') or diag $dump ;


$dump = $d.ddt: :get, (a => (< a >,)), :!color ;
like $dump.lines[0], /^'.Pair'/, 'class name' or diag $dump ;
is($dump.lines.elems, 4, '4 dump lines') or diag $dump ;


for (Array, List) -> \typ {
    subtest typ.gist, {
        $dump = $d.ddt: :get, typ.new((a => (a => 1))), :!color ;
        like $dump.lines[1], /' .Pair'/, 'class name' or diag $dump ;
        is($dump.lines.elems, 4, '4 dump lines') or diag $dump ;
    }
}

$dump = $d.ddt: :get, Array.new((a => (a => 1))).Seq, :!color ;
like $dump.lines[1], /'.Pair'/, 'class name' or diag $dump ;
is($dump.lines.elems, 4, '4 dump lines') or diag $dump ;

for (Hash, Map, Stash) -> \typ {
    subtest typ.gist, {
        $dump = $d.ddt: :get, typ.new("a", (a => 1)), :!color ;
        like $dump.lines[1], /'.Pair'/, 'class name' or diag $dump ;
        is($dump.lines.elems, 2, '2 dump lines') or diag $dump ;
    }
    subtest typ.gist ~ ".Seq", {
        $dump = $d.ddt: :get, typ.new("a", (a => 1)).Seq, :!color ;
        like $dump.lines[1], /' .Pair'/, 'class name' or diag $dump ;
        is($dump.lines.elems, 4, '4 dump lines') or diag $dump ;
    }
}

$dump = $d.ddt: :get, [a => (a => 1)], :!color ;
like $dump.lines[1], /' .Pair'/, 'class name' or diag $dump ;
is($dump.lines.elems, 4, '4 dump lines') or diag $dump ;

my Any %silly_stuff{Any};

%silly_stuff{((innerkey => True) => "key's_value")} = (innervalue => True) => "values_value";
%silly_stuff{((innerkey => (innerinnerkey => True)) => "deep_keys_value")} = (innervalue => (innerinnervalue => True)) => "deep_values_value";

$dump = $d.ddt: :get, %silly_stuff, :!color, :width(75) ;
is $dump.lines.elems, 10, '10 lines of dump for Object Hash with nested pairs as keys and pairs as values' or diag $dump ;
