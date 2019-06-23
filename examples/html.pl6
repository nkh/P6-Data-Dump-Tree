
use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::ColorBlobLevel ;

use LWP::Simple;
use DOM::Tiny ;

my $t0 = now ;
#my $html = DOM::Tiny.parse(LWP::Simple.get("http://www.google.com"));
my $html = DOM::Tiny.parse('<div><p id="a" x="3">Test</p><p id="b">123</p></div>');
"parsing: {now - $t0} s".say ;

$t0 = now ;
#ddt $html ;
"rendering: {now - $t0} s".say ;

my $d = Data::Dump::Tree.new:
	:string_type(''),
	:string_quote('"'),
	:does[DDTR::ColorBlobLevel],
	:color_kbs,
	:header_filters[&header],
	:elements_filters[&final_first, &elements],
	:nl ;

$t0 = now ;
$d.ddt: $html ;
"rendering: {now - $t0} s".say ;

multi sub header($, \r, DOM::Tiny::HTML::Tag $s, @, (\k, \b, \v, \f, \final, \want_address))
{
#Make tag nodes look like html a bit

k = '<' ~ $s.tag ~ ' ' ~ $s.attr.kv.map(-> $k, $v {"$k=$v"}).join(' ') ~ '>' ;
b = ' ' ;

if $s.children.elems == 1 && $s.children[0] ~~ DOM::Tiny::HTML::Text
	{
	v = $s.children[0].text ; 
	final = True ;
	}
else
	{
	v = Data::Dump::Tree::Type::Nothing ;
	}

f = '' ;
want_address = False ;
}

multi sub elements($, $s, @, @sub_elements)
{
# remove DOM::Tiny attributes we do not want to see
@sub_elements = @sub_elements.grep:
			{
			$_[0] !~~ 
				'%.attr is rw' |
				'$.parent is rw' |
				'$.tag is rw' |
				'$.rcdata is rw'
			}  ;

# if it's a tag element display @children directly under element
if $s ~~ DOM::Tiny::HTML::Tag
	{
	my @new_elements ;

	for @sub_elements.grep({ $_[0] ~~ '@.children is rw' }) -> $e
		{
		my ($k, $b, $v, $p) = $e ;
		for $v.List 
			{
			@new_elements.push: $_ ~~ DOM::Tiny::HTML::Text | DOM::Tiny::HTML::Raw 
						?? ('', '', $_.text)
						!! ('', '', $_) ;
			}
		}

	@sub_elements = @new_elements ;
	}
}

multi sub final_first($dumper, $, $, @sub_elements)
{
@sub_elements = @sub_elements.sort: { $dumper.get_element_header($^a[2])[2] !~~ DDT_FINAL }
}

