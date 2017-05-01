
use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;

use Terminal::ANSIColor ;

# -------------------------------------------------
# highlight some entries via a  user defined filter
# -------------------------------------------------

dump [1..4], header_filters => (&my_filter,) ;


# HEADER FILTER
multi sub my_filter(\r, Int $s, ($depth, $path, $glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
if $s == 1 { @renderings.append: $glyph ~ color('bold white on_yellow') ~ ' add line in the graph '  ~ color('reset')}

if $s == 2 { k = k ~ color('bold white on_yellow') ~ '*' }

if $s == 3 { k = color('bold white on_yellow') ~ k }

if $s == 4 { f = f ~ ' ' ~ color('bold white on_yellow') ~ 'an Int' }
}

