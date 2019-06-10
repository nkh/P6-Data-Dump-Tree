
role DataSource is export
{

use Data::Dump::Tree::ExtraRoles ;

method custom_setup
{
self does DDTR::FixedGlyphs('') ;
self.width = Inf ;
self.tab_size = 0 ;
self.keep_paths = True ;

multi sub path_and_tab($, $, $, ($, $path, $, $), (\k, \b, \v, \f, $, $))
{
k = $path.map({.[1]}).join('%') ~ "\t" ~ k ;
*~= "\t" for k, b, v, f ;
}

$.header_filters.push: &path_and_tab ;
} 

} #role

