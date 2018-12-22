# Data::Dump::Tree
[![Build Status](https://travis-ci.org/nkh/P6-Data-Dump-Tree.svg?branch=master)](https://travis-ci.org/nkh/P6-Data-Dump-Tree)

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

Data::Dump::Tree - Renders data structures in a tree fashion

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

`Data::Dump::Tree` renders your data structures in a tree fashion for legibility.

It also can:

  * colors the output if you install Term::ANSIColor (highly recommended)

  * display two data structures side by side (DDTR::MultiColumns)

  * display the difference between two data structures (DDTR::Diff)

  * generate DHTML output (DDTR::DHTML)

  * display an interactive folding data structure (DDTR::Folding)

  * display parts of the data structure Horizontally ( :flat() )

  * show NativeCall data types and representations (see int32 example)

  * be used to "visit" a data structure and call callbacks you define

INTERFACE
=========

sub ddt $data_to_dump, $data_to_dump, :adverb, :named_argument, ...
-------------------------------------------------------------------

Renders the data structure

This interface accepts the following adverbs:

  * **:print** prints the rendered data, the default befhavior without adverb

  * **:note** 'note's the rendered data

  * **:get** returns the rendered data

  * **:get_lines** returns the rendering in its native format

  * **:get_lines_integrated** returns a list of rendered lines

  * **:fold** opens a Terminal::Print interface, module must be installed

  * **:remote** sends a rendering the to listener

See examples/ddt.pl and ddt_receive.pl

  * **:remote_fold** sends a foldable rendering the to listener

See examples/ddt_fold_send.pl and ddt_fold_receive.pl.

method ddt: $data_to_dump, $data_to_dump, :adverb, :named_argument, ...
-----------------------------------------------------------------------

Renders the data structure, see above for a list of adverbs.

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
	    MyClass.new(size => 6, name => 'P6 class'),
	    'aaa' ~~ m:g/(a)/,
	    ] ;

    ddt $s, :title<A complex structure> ;

    ddt $s1, $s2, $s3, :!color ;

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

Rendering
==========

Each line of output consists 5 elements, 2 elements, the tree and the address, are under the control of Data::Dump::Tree, The three remaining elements can be under your control but Data::Dump::Tree provides defaults.

Refer to section 'handling specific types' to learn how to render specific  types with your own type handlers.

Elements of the dump
--------------------

    |- key = value .MyClass @2

### tree (glyphs)

The tree portion of the output shows the relationship between the data elements. The data is indented under its container.

You can control the color of the tree portion and if it is rendered with ASCII or Unicode.

### key

The key is the name of the element being displayed; in the examples above, the container is an array; Data:Dump::Tree gives the index of the element as the  key of the element. IE: '0', '1', '2', ...

### binder

The string displayed between the key and the value.

### value

The value of the element being displayed; Data::Dump::Tree displays the value of "terminal" variables, eg: Str, Int, Rat; for containers, no value is displayed.

### Type

The type of the variable with a '.' appended. IE: '.Str', '.MyClass'

Data::Dump::Tree will display

  * Ints, and Bools, type is set to white space to reduce noise

  * Hashes as '{n}' where n is the number of element of the hash

  * Arrays as '[n]'

  * Lists as '(n)'

  * Sets as '.Set(n)'

  * Sequences as '.Seq(n)' or '.Seq(*)' for lazy lists

You control if the sequences are dumped vertically or horizontally, how much of the sequence is dumped and if lazy sequences are dumped (you decide how many elements for lazy sequences too).

Check file *examples/sequences.pl* in the distribution as well as the  implementation in *lib/Data/Dump/Tree/DescribeBaseObjects.pm*.

  * Matches as '[x..y]' where x..y is the match range

See *Match objects* in the roles section below for configuration of the Match objects rendering.

### address

The Data::Dump::Tree address is added to every container in the form of a '@' and an index that is incremented for each container. If a container is found multiple times in the output, it will be rendered once only then referred to  as '§first_time_seen'

It is possible to name containers by using *set_element_name* before dumping  your data structure.

    my $d = Data::Dump::Tree.new ;

    $d.set_element_name: $s[5], 'some list' ;
    $d.set_element_name: @a, 'some array' ;

    $d.ddt: $s ;

If an element is named, its name will be displayed next to his address, the first time it is displayed and when an element refers to it.

Configuration and Overrides
---------------------------

There are multiple ways to configure the Dumper. You can pass a configuration to the ddt() sub or you can create a dumper object with your configuration.

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

The example directory contain a lot of examples. Read and run the examples to learn how to use DDT, specially the advanced examples.

### colors

#### $color = True

By default coloring is on if Term::ANSIColor is installed.

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

where colors are ANSI colors. *reset* means default color.

By default the glyphs will not be colored and the key and binder use colors 'key' and 'binder'. For certain renderings, with many and very long continuation lines, having colored glyphs and key-binder colored per level helps greatly.

#### $color_glyphs

Will set a default glyph color cycle.

    my @s = [ ... ] ;

    # monochrome glyphs
    ddt @s ;

    # colored glyphs, will cycle
    ddt @s, :color_glyphs ; # uses < gl_0 gl_1 gl_2 gl_3 >

#### @glyph_colors

You can also define your own cycle with **@glyph_colors**:

    my @s = [ ... ] ;

    # monochrome glyphs
    ddt @s ;

    # colored glyphs, will cycle (note that the colors must be defined)
    ddt @s, :color_glyphs, glyph_colors => < gl_0 gl_1 > ;

#### $color_kbs

Will set a default key and binding color cycle.

    my @s = [ ... ] ;

    # default uses colors 'key' and 'binder'
    ddt @s ;

    # used color 'kb_0', 'kb_1' ... and cycles
    ddt @s, :color_kbs ; #uses < kb_0 kb_1 ...  kb_10 >

#### @kb_colors

You can also define your own cycle with **@kb_colors**:

    my @s = [ ... ] ;

    # colored glyphs, will cycle (note that the colors must be defined)
    ddt @s, :color_kbs, kb_colors => < kb_0 kb_1 > ;

### $width = terminal width

Note that the width of the glyps is subtracted from the width you pass as we use that space when displaying multiline values in the dump.

    ddt $s, :width(40) ;

DDT uses the whole terminal width if no width is given.

### $width_minus = Int

Reduces the width, you can use it to reduce the automatically computer width.

### $indent = Str

The string is prepended to each line of the rendering

### $nl = Bool

Add an empty line to the rendering

### $die = Bool

Dies after displaying the data

### $max_depth = Int

Limit the depth of a dump. There is no limit by default.

### $max_depth_message = True

Display a message telling that you have reached the $max_depth limit, set this flag to false disable the message.

### $display_info = True

By default, this option is set. When set to false, neither the type not the  address are displayed.

### $display_type = True

By default this option is set.

### $display_address = True

By default this option is set.

### $display_perl_address = False

Display the internal address of the objects. Default is False.

### Unicode vs ANSI tree drawing

The tree is draw with Unicode characters + one space by default. See roles AsciiGyphs and CompactUnicodeGlyphs.

### Horizontal layout

You can use *:flat( conditions ...)* to render parts of your data horizontally. Horizontal layout is documented in the *LayoutHorizontal.pm* modeule and you can find multiple examples in *examples/flat.pm*.

You can chose which elements, which type of element or even dynamically chose to flatten, say, Arrays with more than 15 elements.

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

    Same data rendered with ddt and :flat(0):

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

This section will show you how to write specific handlers in the classes that you create and to create a custom rendering for a specific class, even if it  is not under your control.

### your own classes

When Data::Dump::Tree renders an object, it first checks if it has an internal handler for that type; if no handler is found, the object is queried and its handler is used, if none; finally, Data::Dump::Tree uses a generic handler.

It is important to understand that you precisely control how your class is  rendered, You can even return completely different data than the one contained in your class.

Data::Dump::Tree uses two methods, you can define either one or both.

#### ddt_get_header, code is defined in your class

    method ddt_get_header
    {
    # some comment, usually blank # class type
    "something about this class", '.' ~ self.^name
    }

#### ddt_get_elements, code is defined in your class

    method ddt_get_elements
    {

    #key           #binder   #value
    (1,            ' = ',    'has no name'),
    (3,            ' => ',   'abc'),
    ('attribute',  ': ',     '' ~ 1),
    ('sub object', '--> ',   [1 .. 3]),
    ('from sub',   '',       something()),

    }

In the type handler, you can:

  * Remove/add elements

  * Change the keys, values description

If your keys or values are text string and they contain embedded "\n",  Data::Dump::Tree will display them on multiple lines. See the Role section.

The module tests, and examples directory, and  Data::Dump::Tree::DescribeBaseobjects are a good place to look at for more examples.

### classes defined by someone else and base types

You can not add methods to classes that you do not control. Data::Dump::Tree has handlers, via roles, that it uses to display the elements of the structure you pass to dump(). You can override those handler and add new handlers.

  * get_header

  * get_elements

Both work in the same fashion.

    role your_hash_handler
    {
    # ..................... Type you want to handle is Hash
    #                        ||||
    #                        vvvv
    multi method get_header (Hash $h)
	     { '', '{' ~ $h.elems ~ '}' }


    multi method get_elements (Hash $h)
	    { $h.sort(*.key)>>.kv.map: -> ($k, $v) {$k, ' => ', $v} }

    }

To make that handler active, make your dumper do the role

    # using 'does'
    my $d = Data::Dump::Tree.new: :width(80) ;
    $d does your_hash_handler ;

    $d.ddt: @your_data ;

    # by passing roles to the constructor
    my $d = Data::Dump::Tree.new: :does(DDTR::MatchDetails, your_hash_handler) ;

    # by passing roles to dump() method
    my $d = Data::Dump::Tree.new ;
    $d.ddt: $m, :does(DDTR::MatchDetails, your_hash_handler) ;

    # by passing roles to ddt sub
    ddt: $m, :does(DDTR::MatchDetails, your_hash_handler) ;

### FINAL elements

So far we have seen how to render containers but sometimes we want to handle a type as if it was a Str or an Int, EG: not display its elements but instead display it on a single line.

You can, in a handler, tell Data::Dump::Tree that a type rendering is DDT_FINAL.

The default role has a handler that is specific for the Rat class. Rather than show a floating number, as "say $rat;" would, or render the Rat type with it's  attributes, we display the Rat on a single line. Here is the handler:

    multi method get_header (Rat $r)
    {
    # the rendering of the Rat
    $r ~ ' (' ~ $r.numerator ~ '/' ~ $r.denominator ~ ')',

    #its type
    '.' ~ $r.^name,

    # optional hint to DDT that this is final
    DDT_FINAL,

    # optional hint to DDT that this is has an address or not
    DDT_HAS_ADDRESS,
    }

Handling specific objects, filtering
------------------------------------

In the previous section we discussed rendering types with specific handler. The handlers apply to all the objects of the type. Sometimes you want to  handle instances differently. An example would be having three Hashes, the Hash handler will display each key and it's value; If you want to handle  the first Hash and the third Hash differently, you can write a filter.

To pass a filter to the dumper:

    ddt(
	    $s,
	    :header_filters(&header_filter, ...),
	    :elements_filters(&elements_filter,),
	    :footer_filters(&footer_filters,),
	    ) ;

Data::Dump::Tree cycle is:

when the element is to be displayed, DDT calls the element which return a description of itself then

    * DDT_HEADER filters are called

when sub elements of an element are to be displayed, DDT calls the element which returns a list of the sub elements in the form ('name' 'binder' 'sub_element')

    * DDT_SUB_ELEMENTS filters are called

when DDT has rendered the element and will get to the next element

    * DDT_FOOTER filters are called

### DDT_HEADER filter

This is called just after the type's _get_header_ is called, this allows you, EG, to insert something in the tree rendering

    sub header_filter(
	    $dumper,				# the dumper
	    $r,                                     # replacement
	    $s,                                     # "read only" object
	    ($depth, $path, $glyph, @renderings),   # info about tree
	    ($k, $b, $v, $f, $final, $want_address) # element info
	    )
    {
    # Add something to the tree
    @renderings.push: (|$glyph , ('', "HEADER", '')) ;
    }

or change the **rendering** of the object

    sub header_filter(
	    $dumper,				# the dumper
	    \r,                                     # replacement
	    Int $s,                                 # filter Ints
	    ($depth, $path, $glyph, @renderings),   # info about the tree
	    (\k, \b, \v, \f, \final, \want_address) # reference, can change
	    )
    {
    @renderings.push: (|$glyph, ('', 'Int HEADER ' ~ $depth, '')) ;

    # need to set limit or we would create lists forever
    if $depth < 2 { r = <1 2> } ;

    # k, b, v, f are text

    k = k ~ ' will be replaced by Hash ' ;
    #b = '' ;
    #v = '' ;
    #f = '' ;

    final = DDT_NOT_FINAL ;
    want_address = True ;
    }

Note: You can not filter elements of type _Mu_ with DDT_HEADER filters but you can in DDT_SUB_ELEMENTS filters.

### DDT_SUB_ELEMENTS filter

Called after the type's _get_elements_ ; you can change the sub elements.

    sub sub_elements_filter(
	    $dumper,
	    Hash $s,
	    ($depth, $glyph, @renderings, ($key, $binder, $, $path)),
	    @sub_elements
	    )
    {
    @renderings.push: (|$glyph, ('', 'SUB ELEMENTS', '')) ;
    @sub_elements = (('key', ' => ', 'value'), ('other_key', ': ', 1)) ;
    }

### DDT_FOOTER filter

Called when the element rendering is done.

    sub footer_filter($dumper, $s, ($depth, $filter_glyph, @renderings))
    {
    @renderings.push: (|$filter_glyph, ('', "FOOTER for {$s.^name}", '')) ;
    }

Data::Dump::Tree::Type::Nothing
-------------------------------

You can use this type to have DDT make some elements of the structure vanish from the rendering

### Filtering an element away

If you return a Data::Dump::Tree::Type::Nothing replacement in your filter, the element will not be displayed at all.

    sub my_filter($, \r, Tomatoe $s, $, $)
    {
    r = Data::Dump::Tree::Type::Nothing ;
    }

As DDT streams the rendering, it can not go back to fix the glyphs when an  element is filtered away, this will probably show as slightly wrong glyph lines. Nevertheless, when duping big structures which contains elements you don't want to see, this is an easy an effective manner; the other, better, ways are

  * Create a type handler

You can minimize the rendering of the type.

See *Type element with only a name* above.

  * Create a filter for containers

If the element you don't want to see only appears in some containers, you can create a type handler, or filter, for that container type and weed out any  reference to the element you don't want to see. This will draw proper glyph lines as the element, you don't want to see, is never seen by DDT.

### Type element with only a name

If you return a Data::Dump::Tree::Type::Nothing in a type handler, only the key will be displayed.

    method ddt_get_elements
    {
	    [
	    ...
	    ('your key', '', Data::Dump::Tree::Type::Nothing),
	    ...
	    ]
    }

Roles provided with Data::Dump::Tree
------------------------------------

Data::Dump::Tree comes with a few extra roles that are not 'does'ed by the object returned by new()

Please feel free to send me roles you think would be useful to other and that you believe fit well in the same bundle.

You are welcome to make your own distribution for the roles too, I recommend using namespace DDTR::YourRole.

### DDTR::AsciiGlyphs

Uses ASCII codes rather than Unicode to render the tree.

### DDTR::CompactUnicodeGlyphs

This is the tightest rendering as only one character per level is used to display the tree glyphs.

### DDTR::PerlString

Renders string containing control codes (eg: \n, ANSI, ...) with backslashed codes and hex values.

### DDTR::FixedGlyphs

Replace all the glyphs by a single glyph; default is a three spaces glyph.

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

You can set the maximum string length either by specifying a length when the  role is added to the dumper.

    $dumper does DDTR::MatchLimit(15) ;

    aaaaa\naaaaa\n(+12)'[0..23]

or by setting the _$.match_string_limit_ member variable

    $dumper does DDTR::MatchLimit ;
    ...
    $dumper.match_string_limit = 15 ;

    aaaaa\naaaaa\n(+12)[0..23]

The specified length is displayed, the length of the remaining part is displayed within parenthesis.

#### DDTR::MatchDetails

Give complete details about a Match. The match string is displayed as well as the match start and end position.

You can set the maximum string length either by specifying a length when the  role is added to the dumper or by setting the _$.match_string_limit_ member variable.

    # from examples/named_captures.pl
    $dumper does (DDTR::MatchDetails, DDTR::FixedGlyphs) ;

    config [2]
       0 = \{ \\s* '[' (\\w+) ']' \\h* \\n+ }.Regex
       1 =     [passwords]\n        jack=password1\n (+74)[0..113]
          <section>     [passwords]\n        jack=password1\n (+29)[0..68]
	     <header>     [passwords]\n[0..15]
	        <0> passwords[5..13]
	     <kvpair>         jack=password1\n[16..38]
	        <identifier> jack[24..27]
	        <key> jack[24..27]
	        <identifier> password1[29..37]
	        <value> password1[29..37]
	     <kvpair>         joy=muchmoresecure123\n[39..68]
	        <identifier> joy[47..49]
	        <key> joy[47..49]

Deprecated interface
====================

From version **1.6.0** the prefered interface is via sub and method **ddt**. The old interface is still available but will be removed.

sub interface
-------------

  * sub dump($data_to_dump, $data_to_dump, :named_argument, ...)

  * sub get_dump($data_to_dump, $data_to_dump, :named_argument, ...)

  * sub get_dump_lines($data_to_dump, $data_to_dump, :named_argument, ...)

method interface
----------------

  * method dump: $data_to_dump, $data_to_dump, :named_argument, ...

  * method get_dump: $data_to_dump, $data_to_dump, :named_argument, ...

  * method get_dump_lines: $data_to_dump, $data_to_dump, :named_argument, ...

BUGS
====

Submit bugs (preferably as executable tests) and feel free to make suggestions.

Dumper Exception
----------------

As this module uses the MOP interface, it happens that it may use interfaces not implemented by some internal classes.

An example is Grammar that I tried to dump and got an exception about a class that I didn't even know existed.

Those exception are caught and displayed by the dumper as  "DDT Exception: the_caught_exception"

Please let me know about them so I can add the necessary handlers to the  distribution.

AUTHOR
======

Nadim ibn hamouda el Khemir https://github.com/nkh

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



