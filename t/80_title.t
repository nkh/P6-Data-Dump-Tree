#!/usr/bin/env perl6

use Test ;
plan 14 ;

use Data::Dump::Tree ;

my $dump = get_dump(1) ;
unlike $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = get_dump(1) ;
unlike $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = get_dump(1, caller => True) ;
unlike $dump, /one/, 'title' ;
like $dump, /\@/, 'address' ;

$dump = get_dump(1, caller => False) ;
unlike $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = get_dump(1, title => 'one') ;
like $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = get_dump(1, title => 'one', caller => True) ;
like $dump, /one/, 'title' ;
like $dump, /\@/, 'address' ;

$dump = get_dump(1, title => 'one', caller => False) ;
like $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

