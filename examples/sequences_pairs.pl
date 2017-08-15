#!/usr/bin/env perl6

#use Test ;
#plan 8 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::Diff ;

my $d = Data::Dump::Tree.new(:compact_width) does DDTR::Diff ;

$d.dump_synched: (0...*), Seq(2, 3, 'x', 'y') ;

$d.dump_synched: (0...*), Seq(2, 3, 'x', 'y'), :compact_width  ;
$d.dump_synched: (0...^15), Seq(2, 3, 'x', 'y'), :compact_width  ;
$d.dump_synched: (0...^10), Seq(2, 3, 'x', 'y'), :compact_width  ;
$d.dump_synched: Seq(2, 3, 'x', 'y'), (0...^15), :compact_width  ;

say '' ; say '-' x 30 ; say '' ;

dd Seq(1, 2, 'x') ;
say (Seq(1, 2, 'x')).gist ;
$d.ddt: Seq(1, 2, 'x') ;

say '' ; say '-' x 30 ; say '' ;

dd (1...*) ;
say (1...*).gist ;
$d.ddt: (1...*) ;

say '' ; say '-' x 30 ; say '' ;

say (1...10_000).gist ;
$d.ddt: (1...10_000) ;

class C {has Int $.x = 3} ;
my @a = 1, 2, 3, C.new ;
my @b = <a b c d>;
my \c = @a Z=> @b;

say '' ; say '-' x 30 ; say '' ;

my $s = Seq.from-loop(&body, &cond) ;
dd  $s ;
say $s.gist ;

$d.consume_seq<vertical> = False ;
$d.ddt: $s ;

say '' ; say '-' x 30 ; say '' ;

$d.consume_seq<vertical> = True ;
$d.ddt: (0...1000)  ;
$d.ddt: (0...3)  ;

$d.ddt: (1...*) ;

$d.consume_seq<consume_lazy> = True ;
$d.ddt: (1...*) ;

$d.consume_seq<vertical> = False ;
$d.ddt: (1...*) ;

say '' ; say '-' x 30 ; say '' ;

# lazy Seq builder
my $x = 0 ;
sub body { state $x = 0.5 ; return $x++ }
sub cond { state $x = 0 ; return False if $x >= 120 ; $x++ ; return True}

# NQP and much better output from dd even though it consumes the sequence
$d.consume_seq<vertical> = True ;
$d.ddt( c ) ;

$d.consume_seq<vertical> = False ;
$d.ddt: c  ;
dd c ;
say c.gist ;

my $p = Pair.new(1, 'a') ;
ddt 1 => 'a' ;

ddt ($p, $p, $p, $p, a => (|< a b c >, ($p,$p))) ;



