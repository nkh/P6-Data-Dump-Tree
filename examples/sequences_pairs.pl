#!/usr/bin/env perl6

#use Test ;
#plan 8 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Data::Dump::Tree::Diff ;

my $d = Data::Dump::Tree.new(:compact_width) does DDTR::Diff ;

$d.dump_synched: (0...*), Seq(2, 3, 'x', 'y') ;

$d.dump_synched: (0...*), Seq(2, 3, 'x', 'y'), :compact_width, :does(DDTR::ConsumeSeq,)  ;
$d.dump_synched: (0...^15), Seq(2, 3, 'x', 'y'), :compact_width, :does(DDTR::ConsumeSeq,)  ;
$d.dump_synched: (0...^10), Seq(2, 3, 'x', 'y'), :compact_width, :does(DDTR::ConsumeSeq,)  ;
$d.dump_synched: Seq(2, 3, 'x', 'y'), (0...^15), :compact_width, :does(DDTR::ConsumeSeq,)  ;

say '' ; say '-' x 30 ; say '' ;

dd Seq(1, 2, 'x') ;
say (Seq(1, 2, 'x')).gist ;
$d.dump: Seq(1, 2, 'x') ;

say '' ; say '-' x 30 ; say '' ;

dd (1...*) ;
say (1...*).gist ;
$d.dump: (1...*) ;

say '' ; say '-' x 30 ; say '' ;

say (1...10_000).gist ;
$d.dump: (1...10_000) ;

class C {has Int $.x = 3} ;
my @a = 1, 2, 3, C.new ;
my @b = <a b c d>;
my \c = @a Z=> @b;

say '' ; say '-' x 30 ; say '' ;

my $s = Seq.from-loop(&body, &cond) ;
dd  $s ;
say $s.gist ;

$d does DDTR::ConsumeSeq(%(vertical => False)) ;
$d.dump: $s ;

say '' ; say '-' x 30 ; say '' ;

$d.consume_seq<vertical> = True ;
$d.dump: (0...1000)  ;
$d.dump: (0...3)  ;

$d.dump: (1...*) ;

$d.consume_seq<consume_lazy> = True ;
$d.dump: (1...*) ;

$d.consume_seq<vertical> = False ;
$d.dump: (1...*) ;

say '' ; say '-' x 30 ; say '' ;

# lazy Seq builder
my $x = 0 ;
sub body { state $x = 0.5 ; return $x++ }
sub cond { state $x = 0 ; return False if $x >= 120 ; $x++ ; return True}

# NQP and much better output from dd even though it consumes the sequence
$d.consume_seq<vertical> = True ;
$d.dump( c ) ;

$d.consume_seq<vertical> = False ;
$d.dump: c  ;
dd c ;
say c.gist ;

my $p = Pair.new(1, 'a') ;
dump(1 => 'a') ;

dump(($p, $p, $p, $p, a => (|< a b c >, ($p,$p)))) ;



