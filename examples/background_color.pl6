
use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::ExtraRoles ;

use Terminal::ANSIColor ;
use JSON::Tiny ;

my $main_glossary =
Q<<
    "Gloss 2": {
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
>> ;

my $JSON_ONE_GLOSSARY =
Q<<{
  "glossary": {
    "title": "example glossary",
>> 
~ "$main_glossary" ~
Q<<
  }
}>> ;

my $JSON =
Q<<{
  "glossary": {
    "title": "example glossary",
    "Gloss 1": {
      "integer": 1
    },
>> 
~ "$main_glossary," ~
Q<<
    "Gloss 3": {
      "integer": 1
    }
  }
}>> ;

my @colors = < on_22 on_17 on_20 on_52 on_56 on_92 on_127> ;

my $d = Data::Dump::Tree.new:
		:title<JSON:>,
		:!color,
		:display_information(DDT_DISPLAY_NONE),
		:width(Inf) ;

my $color_filter_type ;

for 1 -> $type
	{
	$color_filter_type = $type ;
	$d.ddt: from-json($JSON_ONE_GLOSSARY),
		:does[DDTR::FixedGlyphs],
		:color_filters[&color_background],
		:nl ;

	$d.ddt: from-json($JSON_ONE_GLOSSARY),
		:does[DDTR::FixedGlyphs],
		:color_filters[&color_background],
		:elements_filters[&final_first, &non_final_no_binder, &align_keys],
		:nl ;
	}

for 1..3 -> $type
	{
	$color_filter_type = $type ;
	$d.ddt: from-json($JSON),
		:does[DDTR::FixedGlyphs],
		:color_filters[&color_background],
		:nl ;

	$d.ddt: from-json($JSON),
		:does[DDTR::FixedGlyphs],
		:color_filters[&color_background],
		:elements_filters[&final_first, &non_final_no_binder, &align_keys],
		:nl ;
	}

$color_filter_type = 3 ;
$d.ddt: from-json($JSON), :color, :color_filters[&color_background], :nl ;

$d.ddt: from-json($JSON),
	:color,
	:color_filters[&color_background],
	:!display_type,
	:elements_filters[&final_first, &non_final_no_binder, &align_keys] ;

multi sub color_background($dumper, $s, $depth, $path, $key, @glyphs, \override_color,  @reset_color)
{
my $color = '' ;

if $color_filter_type == 1
	{
	$color = color(@colors[$depth % @colors.elems]) ;
	}
elsif $color_filter_type == 2
	{
	# level colored as previous level
	if $depth != 2 | 3 | 5 
		{
		$color = color(@colors[$depth % @colors.elems]) ;
		}
	}
else
	{
	if $depth == 2 || $depth > 5 
		{
		$color = color(@colors[$depth % @colors.elems]) ;
		}	
	else
		{
		$color = color('reset') ;
		}	
	}

@reset_color.push: (color('reset'), '' , '') ;

my ($glyph_width, $glyph, $continuation_glyph, $multi_line_glyph, $empty_glyph, $filter_glyph) = @glyphs ;

$glyph              = ($color, |$glyph[1..2]) ;
$continuation_glyph = ($color, |$continuation_glyph[1..2]) ;
$multi_line_glyph   = ($color, |$multi_line_glyph[1..2]) ;
$empty_glyph        = ($color, |$empty_glyph[1..2]) ;
$filter_glyph       = ($color, |$filter_glyph[1..2]) ;

@glyphs = ($glyph_width, $glyph, $continuation_glyph, $multi_line_glyph, $empty_glyph, $filter_glyph) ;
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


