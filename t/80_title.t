#!/usr/bin/env perl6

use Test ;
plan 14 ;

use Data::Dump::Tree ;

my $dump = dump(1) ;
unlike $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = dump(1, Nil) ;
unlike $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = dump(1, Nil, (caller => 1)) ;
unlike $dump, /one/, 'title' ;
like $dump, /\@/, 'address' ;

$dump = dump(1, Nil, (caller => 0)) ;
unlike $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = dump(1, 'one') ;
like $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = dump(1, 'one', (caller => 1)) ;
like $dump, /one/, 'title' ;
like $dump, /\@/, 'address' ;

$dump = dump(1, 'one', (caller => 0)) ;
like $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

