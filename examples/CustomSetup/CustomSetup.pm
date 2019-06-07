
use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::Enums ;

role CustomSetup is export
{

method custom_setup
{
self does DDTR::FixedGlyphs ;
self does DDTR::MatchDetails ;
self does DDTR::SuperscribeType ;
self does DDTR::SuperscribeAddress ;
self does DDTR::PerlString ;

$.color_kbs = True ;
$.display_address = DDT_DISPLAY_NONE ;
$.elements_filters.push: &elements_filter ;
} 

sub elements_filter($dumper, $s, ($, $, $, $element), @sub_elements)
{
my ($k, $b) = $element ;
@sub_elements = @sub_elements.grep({$_[0] ne '<identifier>' }) if $k eq "<kvpair>" ;
}

} #role

