#!/usr/bin/env perl6

use Test ;
plan 14 ;

use Data::Dump::Tree ;

my $dump = ddt :get,1, :!color ;
unlike $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = ddt :get,1, :!color ;
unlike $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = ddt :get,1, :!color, caller => True ;
unlike $dump, /one/, 'title' ;
like $dump, /\@/, 'address' ;

$dump = ddt :get,1, :!color, caller => False ;
unlike $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = ddt :get,1, :!color, title => 'one' ;
like $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

$dump = ddt :get,1, :!color, title => 'one', caller => True ;
like $dump, /one/, 'title' ;
like $dump, /\@/, 'address' ;

$dump = get_dump(1, :!color, title => 'one', caller => False) ;
like $dump, /one/, 'title' ;
unlike $dump, /\@/, 'address' ;

