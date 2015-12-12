#!/usr/bin/env perl6

use Test ;
use Data::Dump::Tree ;

plan 1 ;

class C  { has $.in_object = 'in_object' }
like dump( C.new, Nil, {color => 0}), /in_object/, 'access via sub' ;

