# Data::Dump::Tree

[![Build Status](https://travis-ci.org/nkh/P6-Data-Dump-Tree.svg?branch=release)](https://travis-ci.org/nkh/P6-Data-Dump-Tree)

## For perl6

Data::Dump::Tree - Renders data structures in a tree fashion with colors

Some blog entries you may want to look at:

http://blogs.perl.org/users/nadim_khemir/2017/08/perl-6-datadumptree-version-15.html

http://blogs.perl.org/users/nadim_khemir/2017/08/take-a-walk-on-the-c-side.html

https://perl6advent.wordpress.com/2016/12/21/show-me-the-data/

![Imgur](http://i.imgur.com/P7eRSwl.png?1)

*Warning*: This module is developed and tested with the latest rakudo. It may not work or install properly with your version of rakudo, there is a test suite run to check its fitness.

NAME
====

Data::Dump::Tree - Renders data structures as a tree 

SYNOPSIS
========

    use Data::Dump::Tree ;

    ddt @your_data ;

    my $d = Data::Dump::Tree.new(...) ;
    $d.ddt: @your_data ;

    $d does role { ... } ;
    $d.ddt: @your_data ;

DESCRIPTION
===========

Data::Dump::Tree renders your data structures as a tree for legibility.

It also can:

  * colors the output if you install Term::ANSIColor (highly recommended)

  * display two data structures side by side (DDTR::MultiColumns)

  * display the difference between two data structures (DDTR::Diff)

  * generate DHTML output (DDTR::DHTML)

  * display an interactive folding data structure (DDTR::Folding)

  * display parts of the data structure Horizontally (see :flat)

  * show NativeCall data types and representations (see int32 in examples/)

  * be used to "visit" a data structure and call callbacks you define

INTERFACE
=========

sub ddt $data_to_dump, [$data_to_dump2, ...] :adverb, :named_argument, ...
--------------------------------------------------------------------------

Renders $data_to_dump

This interface accepts the following adverbs:

  * **:print** prints the rendered data, the default befhavior without adverb

  * **:note** 'note's the rendered data

  * **:get** returns the rendered data as a single string

  * **:get_lines** returns the rendering in its native format

  * **:get_lines_integrated** returns a list of rendered lines

  * **:fold** opens a Terminal::Print interface, module must be installed

  * **:remote** sends a rendering the to a listener

See examples/ddt.pl and ddt_receive.pl

  * **:remote_fold** sends a foldable rendering to a listener

See *examples/remote/ddt_fold_send.pl* and *ddt_fold_receive.pl*.

method ddt: $data_to_dump, [$data_to_dump2, ...], :adverb, :named_argument, ...
-------------------------------------------------------------------------------

Renders $data_to_dump, see above for a list of adverbs.

USAGE
=====

    use Data::Dump::Tree ;

    class MyClass { has Int $.size ; has Str $.name }

    my $s = [
	    'text',
	    Rat.new(31, 10),
	    {
		    a => 1,
		    b => 'string',
	    },
	    MyClass.new(:size(6), :name<P6 class>),
	    'aaa' ~~ m:g/(a)/,
	    ] ;

    ddt $s, :title<A complex structure> ;

    ddt $s, :!color ;

Output
------

    A complex structure [5] @0
    ├ 0 = text.Str
    ├ 1 = 3.1 (31/10).Rat
    ├ 2 = {2} @1
    │ ├ a => 1
    │ └ b => string.Str
    ├ 3 = .MyClass @2
    │ ├ $.size = 6
    │ └ $.name = P6 class.Str
    └ 4 = (3) @3
      ├ 0 = a[0]
      ├ 1 = a[1]
      └ 2 = a[2]

**:caller** and **method ddt_backtrace: $backtrace = True**
-----------------------------------------------------------

if **:caller** is given as an argument, the call site is added to the title

if you call **ddt_backtrace**, all the calls to method **ddt**, or sub **ddt**, will display a call stack.

Rendering
=========

Each line of output consists 6 elements.

Data::Dump::Tree (DDT) has a default render mode for all data types but you can greatly influence what and how things are rendered.

Rendering elements
------------------

    tree   binder  type     address 
    |      |       |        |
    v      v       v        v

    |- key = value .MyClass @2

### tree (glyphs)

The tree shows the relationship between the data elements. Data is indented under its container.

DDT default tree rendering makes it easy to see relationship between the elements of your data structure but you can influence its rendering.

### key

The key is the name of the element being displayed; in the examples above the container is an array; Data:Dump::Tree uses the index of the element as the key its key. IE: '0', '1', '2', ...

### binder

The string displayed between the key and the value.

### value

The element's value; Data::Dump::Tree renders "terminal" variables, eg: Str, Int, Rat. Container have no value, but a content.

### Type

The element's type with a '.' prepended. IE: '.Str', '.MyClass'

Data::Dump::Tree will render some types specifically:

  * Ints, and Bools, the type is not displayes to reduce noise

  * Hashes as **{n}** where n is the number of element of the hash

  * Arrays as **[n]**

  * Lists as **(n)**

  * Sets as **.Set(n)**

  * Sequences as **.Seq(n)** or **.Seq(*)** when lazy. 

You control if sequences are rendered vertically or horizontally, how much of the sequence is rendered and if lazy sequences are rendered (and how many elements for lazy sequences).

Check *examples/sequences.pl* as well as the implementation in *lib/Data/Dump/Tree/DescribeBaseObjects.pm*.

  * Matches as **[x..y]** where x..y is the match range

See *Match objects* in the roles section below for configuration of the Match objects rendering.

### address

The Data::Dump::Tree address is added to every container in the form of a '@' and an index that is incremented for each container. If a container is found multiple times in the output, it will be rendered as *@address* once then as a reference as *§address*

Containers can be named using *set_element_name* prior to rendering.

    my $d = Data::Dump::Tree.new ;

    $d.set_element_name: $s[5], 'some list' ;
    $d.set_element_name: @a, 'some array' ;

    $d.ddt: $s ;

A container's name will be displayed next to his address. 

Configuration and Overrides
---------------------------

There are multiple ways to configure the Dumper. You can pass a configuration to the ddt() or create a dumper object with your configuration.

    # subroutine interface
    ddt $s, :titlei<text>, :width(115), :!color  ;

    # basic object
    my $dumper = Data::Dump::Tree.new ;

    # pass you configuration at every call
    $dumper.ddt: $s, :width(115), :!color ;

    # configure object at creation time
    my $dumper = Data::Dump::Tree.new: :width(79) ;

    # use as configured
    $dumper.ddt: $s ;

    # or with a call time configuration override
    $dumper.ddt: $s, :width(115), :max_depth(3) ;


    # see roles for roles configuration

The example directory contain a lot of examples. Read and run the examples to learn how to use DDT.

### colors

#### $color = True

Coloring is on if Term::ANSIColor is installed.

Setting this option to False forces the output to be monochrome.

    ddt $s, :!color ;

#### %colors

You can pass your own colors. The default are:

    %.colors =
	    <
	    ddt_address blue     perl_address yellow  link   green
	    header      magenta  key         cyan     binder cyan
	    value       reset

	    gl_0 yellow   gl_1 reset   gl_2 green   gl_3 red
	    > ;

Where colors are ANSI colors. *reset* means the default color.

By default the tree will not be colored and the key and binder use colors 'key' and 'binder'. For renderings with many and very long continuation lines, having colored glyphs and key-binder colored per level helps greatly.

#### $color_glyphs

Will set a default glyph color cycle.

    # colored glyphs, will cycle
    ddt @data, :color_glyphs ; # uses < gl_0 gl_1 gl_2 gl_3 >

#### @glyph_colors

You can also define your own color cycle with **@glyph_colors**:

    # colored glyphs
    ddt @data, :color_glyphs, glyph_colors => < gl_0 gl_1 > ;

#### $color_kbs

Will set a default key and binding color cycle.

    # used color 'kb_0', 'kb_1' ... and cycles
    ddt @data, :color_kbs ; #uses < kb_0 kb_1 ...  kb_10 >

#### @kb_colors

You can also define your own cycle with **@kb_colors**:

    # colored glyphs, will cycle
    ddt @data, :color_kbs, kb_colors => < kb_0 kb_1 > ;

### $width = terminal width

Note that the glyps' width is subtracted from the width you pass,

    ddt $s, :width(40) ;

DDT uses the whole terminal width if no width is given.

### $width_minus = Int

Reduces the width, you can use it to reduce the computed width.

### $indent = Str

The string is prepended to each line of the rendering

### $nl = Bool

Add an empty line after the last line of the rendering

### $die = Bool

Dies after displaying the data

### $max_depth = Int

Limit the depth of a dump. Default is: no limit.

### $max_depth_message = True

Display a message telling that you have reached the $max_depth limit, setting this flag to false disable the message.

### $max_lines = Int

Limit the number of lines in the rendering, an approximation as *ddt* does not end rendering in the middle of a multi line. There is no limit by default.

### $display_info = True

When set to false, neither the type nor the address are displayed.

### $display_type = True

By default this option is set.

### $display_address = DDT_DISPLAY_ALL

By default this option is set, to change it use:

    use Data::Dump::Tree;
    use Data::Dump::Tree::Enums;

    my $ddt = Data::Dump::Tree.new( :display_address(DDT_DISPLAY_NONE) );

### $display_perl_address = False

Display the internal address of the objects. Default is False.

### Tree rendering

The tree is drawn by default with Unicode characters (glyphs) + one space.

You can influence the rendering of the tree in multiple ways:

  * using glyphs or simple indenting

See role *DDTR::FixedGlyphs*.

  * rendering caracter set and spacing

See role *AsciiGlyphs* and *CompactUnicodeGlyphs*.

You can also create a role that defines the glyphs to use.

  * the color of the tree

See *$color_glyphs* above.

  * "color blob mode"

See <Color Blob mode> for a way to gain control over the tree rendering at every node rendering.

### Horizontal layout

You can use *:flat( conditions ...)* to render parts of your data horizontally. Horizontal layout is documented in the *LayoutHorizontal.pm* module and you can find examples in *examples/flat.pm*.

You can chose which elements, which type of element, even dynamically, to flatten, EG: Arrays with more than 15 elements.

    dd's example output:

    $($[[1, [2, [3, 4]]], ([6, [3]],), [1, [2, [3, 4]]]], [[1, [2, [3, 4]]],
    [1, [2, [3, 4]]]], $[[1, 2], ([1, [2, [3, 4]]], [1, [2, [3, 4]]], [1,
    [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1,
    [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1,
    [2, [3, 4]]]).Seq], [[1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, 2], [1, 2,
    3], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3,
    4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]]], $[[1, 2], ([1, [2, [3, 4]]],
    [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]],
    [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]], [1, [2, [3, 4]]],
    [1, [2, [3, 4]]], [1, [2, [3, 4]]]).Seq], "12345678")

    Same data rendered with ddt and I<:flat>:

     (6) @0
       0 = [3] @1       1 = [2] @9   2 = [2] @12        3 = [10] @25
       ├ 0 = [2] @2     ├ 0 = [2] §2 ├ 0 = [2] @13      ├ 0 = [2] §2
       │ ├ 0 = 1        └ 1 = [2] §2 │ ├ 0 = 1          ├ 1 = [2] §2
       │ └ 1 = [2] @3                │ └ 1 = 2          ├ 2 = [2] §13
       │   ├ 0 = 2                   └ 1 = .Seq(11) @14 ├ 3 = [3] @29
       │   └ 1 = [2] @4                ├ 0 = [2] §2     │ ├ 0 = 1
       │     ├ 0 = 3                   ├ 1 = [2] §2     │ ├ 1 = 2
       │     └ 1 = 4                   ├ 2 = [2] §2     │ └ 2 = 3
       ├ 1 = (1) @5                    ├ 3 = [2] §2     ├ 4 = [2] §2
       │ └ 0 = [2] @6                  ├ 4 = [2] §2     ├ 5 = [2] §2
       │   ├ 0 = 6                     ├ 5 = [2] §2     ├ 6 = [2] §2
       │   └ 1 = [1] @7                ├ 6 = [2] §2     ├ 7 = [2] §2
       │     └ 0 = 3                   ├ 7 = [2] §2     ├ 8 = [2] §2
       └ 2 = [2] §2                    ├ 8 = [2] §2     └ 9 = [2] §2
                                       ├ 9 = [2] §2
                                       └ ...
       4 = [2] §12 5 = 12345678.Str

Handling specific types
-----------------------

This section explains how to write specific handlers in classes that create a custom rendering

### in your own classes

When Data::Dump::Tree renders an object, it first checks if it has an internal handler for that type; if no handler is found, the object is queried and its handler is used if it is found; finally, DDT uses a generic handler.

The module tests, examples directory, and Data::Dump::Tree::DescribeBaseobjects are a good places to look at for more examples of classes defining a custom rendering.

#### method **ddt_get_header** in your class

    method ddt_get_header
    {
    # return 

    # some text                       # class type

    # usually blank for containers    |

    # the value for terminals         |
    |                                 |
    v                                 v 

    '',                              '.' ~ self.^name
    }

#### method **ddt_get_elements** in your class

    method ddt_get_elements
    {
    # return a list of elements data for each element of the container
     
    # key           # binder    # value
    (1,             ' = ',     'has no name'),
    (3,             ' => ',    'abc'),
    ('attribute',   ': ',      '' ~ 1),
    ('sub object',  '--> ',    [1 .. 3]),
    ('from sub',    '',        something()),

    }

The content of the original container is ignored, what you return is used. This lets you remove/add/modify elements.

### someone else's class and base types

You can not add methods to classes that you do not control. Data::Dump::Tree has type handlers, via roles, that it uses to handle specific types contained the structure you want to render.

You can override the default handlers and add new ones.

Create a role following this template (here a hash example): 

    role your_hash_handler
    {
    #                        Type you want to handle is Hash
    #                        ||||
    #                        vvvv
    multi method get_header (Hash $h)
	    {
	    # return 
	    # optional description    # type (string to display)
	    '',                       '{' ~ $h.elems ~ '}' }


    multi method get_elements (Hash $h)
	    {
	    # return the elements of your object
	    $h.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} 
	    }
    }

To make that handler active, make your dumper **do** the role

    # using 'does'
    my $d = Data::Dump::Tree.new: :width(80) ;
    $d does your_hash_handler ;

    $d.ddt: @your_data ;

    # or by passing roles to the constructor
    my $d = Data::Dump::Tree.new: :does(DDTR::MatchDetails, your_hash_handler) ;

    # or by passing roles to dump() method
    my $d = Data::Dump::Tree.new ;
    $d.ddt: $m, :does(DDTR::MatchDetails, your_hash_handler) ;

    # or by passing roles to ddt sub
    ddt: $m, :does(DDTR::MatchDetails, your_hash_handler) ;

### FINAL elements

So far we have seen how to render containers but sometimes we want to handle a type as if it was a Str or an Int, EG: not display its elements but instead display it on a single line.

You can, in a handler, specify that a type rendered is not a container, by returning DDT_FINAL in the type's _get_header_ handler.

For example, the Rat class type handler does not show a floating number, it displays the Rat on a single line. Here is the handler:

    multi method get_header (Rat $r)
    {
    # the rendering of the Rat
    $r ~ ' (' ~ $r.numerator ~ '/' ~ $r.denominator ~ ')',

    # its type
    '.' ~ $r.^name,

    # hint DDT that this is final
    DDT_FINAL,

    # hint DDT that this is has an address
    DDT_HAS_ADDRESS,
    }

Filtering
---------

![Imgur](https://i.imgur.com/GCTcmdP.png)

Data::Dump::Tree lets you filter the data to dump.

NOTE: filter must be **multi** subs.

NOTE: **$path**, a list passed to filters, is set if you use **:keep_paths** option, otherwise an empty list is passed to the filters.

To pass a filter to the dumper:

    ddt(
	    $s,

	    # all below are optional

	    :removal_filter(&removal_filter, ...),
	    :header_filters(&header_filter, ...),
	    :elements_filters(&elements_filter,),
	    :footer_filters(&footer_filters,),

	    :keep_paths
	    ) ;

Data::Dump::Tree filters are called in this order:

check if the element is to be removed from the rendering

    * removal filters are called

let you change the header rendering returned by the type's handler

    * header filters are called

let you change the elements of a container returned by the type's handler

    * element filters are called

after the element is rendered

    * footer filters are called

### removal filter

This is called before the type's handler **get_header** is called. This allows you to efficiently remove elements from the rendering.

    multi sub remove_filter(
	    $dumper,
	    $s, 		# "read only" object
	    $path		# path in the data structure

    )
    {
    True # return True if you want the element removed
    }

### header filter

This is called just after the type's _get_header_ is called, this allows you, EG, to insert something in the tree rendering

    multi sub header_filter(
	    $dumper,				# the dumper
	    $replacement                            # replacement
	    $s,                                     # "read only" object
	    ($depth, $path, $glyph, @renderings),   # info about tree

	    ($key, $binder, $value, $type, $final, $want_address) # element info
	    )
    {
    # Add something to the tree
    @renderings.push: (|$glyph , ('', "HEADER", '')) ;
    }

or change the default **rendering** of the object

    multi sub header_filter(
	    $dumper,				# the dumper
	    \replacement                            # replacement
	    Int $s,                                 # will only filter Ints
	    ($depth, $path, $glyph, @renderings),   # info about the tree

	    # what the type's handler has returned
	    (\key, \binder, \value, \type, \final, \want_address) # can be changed
	    )
    {
    @renderings.push: (|$glyph, ('', 'Int HEADER ' ~ $depth, '')) ;

    # in this example we need to set limit or we would create lists forever
    if $depth < 2 { replacement = <1 2> } ;

    # key, binder, value, and type are Str

    key = key ~ 'Hash replacement' ;
    #binder = '' ;
    #value = '' ;
    #type = '' ;

    final = DDT_NOT_FINAL ;
    want_address = True ;
    }

Note: You can not filter elements of type _Mu_ with header filters but you can in element filters.

### elements filter

Called after the type's _get_elements_. You can change the elements.

    multi sub elements_filter(
	    $dumper,
	    Hash $s, # type to filter (ie Hash)

    # rendering data you can optionaly use

    ($depth, $glyph, @renderings, ($key, $binder, $value, $path)),

    # elements you can modify 
    @sub_elements
    )

    {
    # optionaly add something in the rendering
    @renderings.push: (|$glyph, ('', 'SUB ELEMENTS', '')) ;

    # set/filter  the elements 
    @sub_elements = (('key', ' => ', 'value'), ('other_key', ': ', 1)) ;
    }

### footer filter

Called after the element is rendered.

    multi sub footer_filter($dumper, $s, ($depth, $filter_glyph, @renderings))
    {
    # add message to the rendering after the element is rendered
    @renderings.push: (|$filter_glyph, ('', "done with {$s.^name}", '')) ;
    }

Removing elements 
------------------

### In removal filters

See removal filters above.

### In header filters

  * remove the element 

If you return a Data::Dump::Tree::Type::Nothing replacement in your filter, the element will not be displayed at all.

    multi sub header_filter($dumper, \replacement, Tomatoe $s, $, $)
    {
    replacement = Data::Dump::Tree::Type::Nothing ;
    }

As DDT streams the rendering, it can not go back to fix the glyphs of the previous element, this will probably show as slightly wrong tree lines.

  * or reduce the type's rendering in a type handler

This does not remove the element but can be useful, create a type handler which renders the type with minimal text. This is sometime preferable to removing.

### In elements filters

  * use an elements filter for the **container** of the type you want to remove

If the element you don't want to see only appears in some containers, you can create a type handler, or filter, for that container type and weed out any reference to the element you don't want to see. 

  * or reduce the element rendering 

Returning a Data::Dump::Tree::Type::Nothing.new as value, that type renders an empty string.

    multi sub elements_filter( ... )
    {
	    # other elements data ...
	    
	    # the element to reduce rendering of 

	    # key          # binder   #value
	    ('your key',   '',        Data::Dump::Tree::Type::Nothing.new),
    }

Color Blob Mode (for lack of a better name)
-------------------------------------------

When rendering very large data structures the default coloring helps, a better way to render large data set is to turn off coloring for most of the data and highlight only the data that is of greater interest. This lets you skip large amount of data quickly. The best way of highlighting is by using background color not text color as it gets lost in the amount of data.

You can define "color filter" that control the color of the glyphs, the data, and will pad the colored lines to the end of terminal width.

An example can be found in *examples/background_color.pl6*. A few renderings are generated, some look noisy but they are there to show you the different possibilities, the most interesting examples are the ones that highlight as little as possible. Remember to pass :!color to DDT so element coloring is off.

As "Color blob mode" colors whole lines, DDT passes to you the glyphs and expects you to return the color you want for the line and the glyph, (that you can change). 

if you forget to pass :!colorto DDT, only the glyphs will be highlighter as can be seen in the last renderings of the example.

This mode also work surprisingly well for very short renderings, in that case try to use role *DDTR::FixedGlyphs*.

Roles provided with Data::Dump::Tree
------------------------------------

Data::Dump::Tree comes with a few extra roles that are not **does**'ed by the object returned by new()

Please feel free to send me roles you think would be useful to other.

You are welcome to make your own distribution for the roles too, I recommend using namespace DDTR::YourRole.

### DDTR::AsciiGlyphs

Uses ASCII codes rather than Unicode to render the tree.

### DDTR::CompactUnicodeGlyphs

This is the tightest rendering as only one character per level is used to display the tree glyphs.

### DDTR::PerlString

Renders string containing control codes (eg: \n, ANSI, ...) with backslashed codes and hex values.

### DDTR::FixedGlyphs

Replace all the glyphs by a single glyph; default is a two spaces glyph.

    my $d = Data::Dump::Tree.new does DDTR::FixedGlyphs(' . ') ;

### DDTR::NumberedLevel

Will add the level of the elements to the tree glyphs, useful with huge trees. If a Superscribe role is on, the level umber will also be superscribed

### DDTR::SuperscribeType

Use this role to display the type in Unicode superscript letters.

### DDTR::SuperscribeAddress

Use this role to display the address in Unicode superscript letters.

You can also use the method it provides in your type handlers and filters.

### DDTR::Superscribe

Use this role to display the type and address in Unicode superscript letters.

### Match objects

_Match_ objects are displayed as the string that it matched as well as the match start and end position (inclusive, unlike .perl).

    # multiline match
    aaaaa
    aaaaa
    aaaaa
    aaaaa
    [0..23]

    # same match with PerlString role
    "'aaaaa\naaaaa\naaaaa\naaaaa\n'[0..23]"

Some Roles are provided to allows you to change how Match object are displayed.

#### DDTR::MatchLimitString

Limits the length of the match string.

    # default max length of 10 characters
    aaaaa\naaaa(+14)[0..23]

You can set the maximum string length either by specifying a length when the role is added to the dumper.

    $dumper does DDTR::MatchLimit(15) ;

    aaaaa\naaaaa\n(+12)'[0..23]

or by setting the _$.match_string_limit_ member variable

    $dumper does DDTR::MatchLimit ;
    $dumper.match_string_limit = 15 ;

    aaaaa\naaaaa\n(+12)[0..23]

The specified length is displayed, the length of the remaining part is displayed within parenthesis.

#### DDTR::MatchDetails

Give complete details about a Match. The match string is displayed as well as the match start and end position.

You can set the maximum string length either by specifying a length when the role is added to the dumper or by setting the _$.match_string_limit_ member variable.

    # from examples/match.pl

    Match    [passwords]\n        jack=password1\n (+74) ⁰··¹¹³
    ├ <section>  ⁰··⁶⁸
    │ ├ <header> [passwords]⁴··¹⁴
    │ ├ <kvpair>
    │ │ ├ <key> jack ²⁴··²⁷
    │ │ └ <value> password1 ²⁹··³⁷
    │ └ <kvpair>
    │   ├ <key> joy ⁴⁷··⁴⁹
    │   └ <value> muchmoresecure123 ⁵¹··⁶⁷
    └ <section>  ⁶⁹··¹¹³
      ├ <header> [quotas]⁷³··⁸⁰
      ├ <kvpair>
      │ ├ <key> jack ⁹⁰··⁹³
      │ └ <value> 123 ⁹⁵··⁹⁷
      └ <kvpair>
        ├ <key> joy ¹⁰⁷··¹⁰⁹
        └ <value> 42 ¹¹¹··¹¹²

Custom Setup Roles
------------------

If you configure DDT in different ways to render different types, and you should, you will en up writing boilerplate setup code everywhere, you can define functions to return a setup object (or call ddt) or you can use a *custom setup role*. Custom Setup roles define a **custom_setup** method which is called by DDT before rendering your data.

A complete example can be found in *examples/CustomSetup/CustomSetup.pm* and *examples/custom_setup.pl*.

BUGS
====

Submit bugs (preferably as executable tests) and feel free to make suggestions.

Dumper Exception
----------------

As this module uses the MOP interface, it happens that it may use interfaces not implemented by some internal classes.

An example is Grammar that I tried to dump and got an exception about a class that I didn't even know existed.

Those exception are caught and displayed by the dumper as "DDT Exception: the_caught_exception"

Please let me know about them so I can add the necessary handlers to the distribution.

AUTHOR
======

Nadim ibn hamouda el Khemir https://github.com/nkh

Do not hesitate to ask for help.

LICENSE
=======

This program is free software; you can redistribute it and/or modify it under the same terms as Perl6 itself.

SEE-ALSO
========

README.md in the example directory

Perl 5:

  * Data::TreeDumper

Perl 6:

  * Data::Dump

  * Pretty::Printer



