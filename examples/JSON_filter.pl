
use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::ExtraRoles ;

# use json parser
use JSON::Tiny ;

# The Json that needs parsing
my $JSON =
Q<<{
  "glossary": {
    "title": "example glossary",
    "GlossDiv": {
      "integer": 1,
      "title": "S",
      "GlossList": {
        "GlossEntry": {
          "ID": "SGML",
          "SortAs": "SGML",
          "GlossTerm": "Standard Generalized Markup Language",
          "Acronym": "SGML",
          "Abbrev": "ISO 8879:1986",
          "GlossDef": {
            "para": "A meta-markup language, used to create markup languages such as DocBook.",
            "GlossSeeAlso": [
              "GML",
              "XML"
            ]
          },
          "GlossSee": "markup"
        }
      }
    }
  }
}>> ;

# dump with DDT
my $d = Data::Dump::Tree.new:
		:title<JSON:>,
		:display_address(DDT_DISPLAY_NONE) ;

say q:to/EOC/ ;
Say we have a many small json glossaries to display. We could diplay
them in json or we could mangle them a bit to make them a bit more
easy on the eye.
EOC
$JSON.say ;
''.say ;

say q:to/EOC/ ;
First render it with Data::Dump::Tree default settings.
EOC
$d.ddt: from-json($JSON), :nl ;

say q:to/EOC/ ;
For small renderings of an entry type we know, removing the types reduces
the noise.
EOC
$d.ddt: from-json($JSON), :nl, :!display_type ;


say q:to/EOC/ ;
There is a significant difference between the json rendering and DDT
rendering; the json was hand written and the author wrote it as clearly
as possible, she wrote terminal entries (ints, strings, ...) before she
wrote sub elements (hashes, arrays). DDT sorts the keys so that fine
tunning is lost.

We can render the json with a filter that would put the non terminal
entries first.
EOC
$d.ddt: from-json($JSON), :nl, :!display_type, :elements_filters[&final_first] ;

say q:to/EOC/ ;
Better but we can reduce the noise a bit, we can remove the binders for
non-terminal elements with a filter, like this:
EOC
$d.ddt: from-json($JSON), :nl, :!display_type, :elements_filters[&final_first, &non_final_no_binder] ;

say q:to/EOC/ ;
Even better. I like aligned values, I think it is more redable.
EOC
$d.ddt: from-json($JSON), :nl, :!display_type, :elements_filters[&final_first, &non_final_no_binder, &align_keys] ;


say q:to/EOC/ ;
We can get the glossary entry out of the json container.
EOC
$d.ddt: from-json($JSON)<glossary>,
	:title<Glossary>
	:nl,
	:!display_type,
	:elements_filters[&final_first, &non_final_no_binder, &align_keys] ;


say q:to/EOC/ ;
We can remove the tree and throw in some color.
EOC
$d does DDTR::FixedGlyphs('  ') ;
$d.ddt: from-json($JSON)<glossary>,
	:title<Glossary>
	:nl,
	:!display_type,
	:color_kbs,
	:elements_filters[&final_first, &non_final_no_binder, &align_keys] ;

say q:to/EOC/ ;
And finally the hand craft json again for comparison. The json
rendering is 25 lines long, mangled rendering is 18 lines long.
EOC
$JSON.say ;

sub final_first($dumper, $, $, @sub_elements)
{
@sub_elements = @sub_elements.sort: { $dumper.get_element_header($^a[2])[2] !~~ DDT_FINAL }
}

sub non_final_no_binder ($dumper, $, $, @sub_elements)
{
for @sub_elements -> @e
	{
	if $dumper.get_element_header(@e[2])[2] !~~ DDT_FINAL 
		{
		@e[1] = '' ; 
		}
	}
}

sub align_keys ($dumper, $, $, @sub_elements)
{
my $max_kb = ( my @cache = @sub_elements.map: { (.[0] ~ .[1]).chars }).max  ;

for @sub_elements Z @cache -> (@e, $l) { @e[0] ~= ' ' x $max_kb - $l }
}

