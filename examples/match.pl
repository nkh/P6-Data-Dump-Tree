
use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::Enums ;

# content to be matched
my $contents = q:to/EOI/;
    [passwords]
        jack=password1
        joy=muchmoresecure123
    [quotas]
        jack=123
        joy=42
EOI

# define some regexp structure
my regex header      { \s* ('[' \w+ ']') \h* \n+ }
my regex identifier  { \w+ }
my regex kvpair      { \s* <key=identifier> '=' <value=identifier> \n+ }
my regex section     { <header> <kvpair>* }

# create a match object to dump
my $m = $contents ~~ /<section>*/ ;

# dump with different roles
my $d = Data::Dump::Tree.new :title<Match> ;

$d.ddt: $m ;

$d does DDTR::MatchDetails ;
$d does DDTR::SuperscribeType ;
$d does DDTR::SuperscribeAddress ;

$d.ddt: :title('Match (MatchDetails)'), $m ;

$d does DDTR::PerlString ;
$d.ddt: :title<Match (MatchDetails, PerlString)>, $m ;

$d.match_string_limit = 40 ;
$d.ddt: :title<Match (MatchDetails, PerlString+max length)>, $m ;

$d.ddt: :title<Match (MatchDetails, PerlString+ml, FixedGlyphs, custom colors, no address)>,
	$m,
	:does(DDTR::FixedGlyphs,),
	:display_address(DDT_DISPLAY_NONE),
	:colors(<
		ddt_address 17  perl_address 58  link   23
		key         32  binder       32  value  246  header 53
		wrap        23
		>) ;

$d.ddt: :title<Match (MatchDetails, PerlString+ml, FixedGlyphs, custom colors2, no address)>,
	$m ,
	:does(DDTR::FixedGlyphs,),
	:display_address(DDT_DISPLAY_NONE),
	:color_kbs ;

sub header_filter($dumper, \r, $s, ($depth, $path, $glyph, @renderings), (\k, \b, \v, \f, \final, \want_address))
{
# add text in the rendering
#@renderings.push: (|$glyph, ('***', "HEADER filter", '***')) ;

# <header> replaced by its match
if k eq "<header>"
	{
	my %caps = $s.caps ;

	v = "%caps<0>" ;
	f = %caps<0>.from ~ '..' ~ (%caps<0>.pos - 1) ;
	final = DDT_FINAL ;
	}

# <section> have not text but a range
if k eq "<section>" { v = '' ; }

# <kvpair> has neither text nor range
if k eq "<kvpair>"  { v = '' ; f = '' ; }
}

sub elements_filter($dumper, $s, ($depth, $glyph, @renderings, $element), @sub_elements)
{
my ($k, $b) = $element ;

@sub_elements = @sub_elements.grep({$_[0] ne '<identifier>' }) if $k eq "<kvpair>" ;
}

sub ls(Str $s, $limit)
{
$limit.defined && $s.chars > $limit
	?? $s.substr(0, $limit) ~ '(+' ~ $s.chars - $limit ~ ')'
	!! $s
}

#$d.ddt: :title<Match (MatchDetails, PerlString+ml, FixedGlyphs, custom colors2, no address)>,
$d.ddt:	$m ,
	:does(DDTR::FixedGlyphs,),
	:display_address(DDT_DISPLAY_NONE),
	:header_filters(&header_filter,),
	:elements_filters(&elements_filter,),
 	:color_kbs ;


