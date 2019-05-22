#!/usr/bin/env perl6

unit module XYZ ;

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;

ddt_backtrace ;
my $ddt = Data::Dump::Tree.new ;

dd callframe() ;
ddt callframe() ;

role NoForeignCode 
{
multi method get_header (ForeignCode $fc)
	{
	'',  '.' ~ $fc.^name, DDT_FINAL 
	}
}

ddt Backtrace.new.list, :title<Backtrace>, :does[NoForeignCode] ;

