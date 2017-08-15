#!/usr/bin/env perl6

use Test ;
use Data::Dump::Tree ;

plan 1 ;

class C  { has $.in_object = 'in_object' }
like (ddt :get, C.new, color => False), /in_object/, 'access via sub' ;

