#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::ExtraRoles ;

use JSON::Tiny ;

sub MAIN($file_name, Bool :$keep_lines = False) 
{
my $json = from-json($file_name.IO.slurp) ;

my $d = Data::Dump::Tree.new ;

require ($*PROGRAM.parent(1).absolute ~ "/CustomSetup/DataSource.pm6")  <DataSource> ;
my regex { 1 }

$d.ddt: $json, 
	:title("$file_name:"),
	:!display_type,
	:color_kbs,
	:elements_filters[&final_first] ;

$d.ddt: $json, 
	:title("$file_name:"),
	:!display_type,
	:color_kbs,
	:does[DataSource],
	:elements_filters[&final_first] ;
}

sub final_first($dumper, $, $, @sub_elements)
{
@sub_elements = @sub_elements.sort: { $dumper.get_element_header($^a[2])[2] !~~ DDT_FINAL }
}

