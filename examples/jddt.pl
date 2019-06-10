#!/usr/bin/env perl6

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::ExtraRoles ;
use JSON::Tiny ;

sub MAIN($file_name, Bool :$keep_lines = False) 
{
my $json = from-json($file_name.IO.slurp) ;

my $d = Data::Dump::Tree.new does DDTR::FixedGlyphs('  ') ;


$d.ddt: $json, 
	:title("$file_name:"),
	:nl,
	:!display_type,
	:display_address(DDT_DISPLAY_NONE),
	:color_kbs,
	:elements_filters[&json_filter] ;
	#:elements_filters[&final_first, &non_final_no_binder, &align_keys] ;
}

sub final_first($dumper, $, $, @sub_elements)
{
@sub_elements = @sub_elements.sort: { $dumper.get_element_header($^a[2])[2] !~~ DDT_FINAL }
}

sub non_final_no_binder ($dumper, $, $, @sub_elements)
{
for @sub_elements -> ($k, $binder is rw, $value, $)
	{
	$binder = '' if $dumper.get_element_header($value)[2] !~~ DDT_FINAL ;
	}
}

sub align_keys ($dumper, $, $, @sub_elements)
{
my $max_kb = ( my @cache = @sub_elements.map: { (.[0] ~ .[1]).chars }).max  ;

for @sub_elements Z @cache -> (@e, $l) { @e[0] ~= ' ' x $max_kb - $l }
}

sub json_filter($dumper, $, $, @sub_elements)
{
my (@finals, @non_finals) ;

my $max_kb = ( my @cache = @sub_elements.map: { (.[0] ~ .[1]).chars }).max  ;

for (@sub_elements Z @cache) -> (@e, $l)
	{
	my $padded = @e[0] ~ ' ' x $max_kb - $l ;

	if $dumper.get_element_header(@e[2])[2] ~~ DDT_FINAL
		{
		@finals.push: ($padded, |@e[1..*]) ;
		}
	else
		{
		@non_finals.push: ($padded, '', |@e[2..*]) ;
		}
	}

@sub_elements = |@finals, |@non_finals ;
}

