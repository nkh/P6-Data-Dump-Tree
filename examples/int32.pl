#!/usr/bin/env perl6

use NativeCall ;

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::DescribeBaseObjects ;

role my_role { has $.something } # test that Int+something type displays correctly 

class Point is repr('CStruct') {
    has num64 $.x is rw;
    has num32 $.y;
    has int32 $.z = 3;
}

my $point = Point.new: :x(2e56), :y(10e10) ;

class Parts is repr('CUnion') {
        has int32 $.xyz;
        has int64 $.abc;
}

my Parts $union = Parts.new: :abc(10 ** 10) ;

class MyStruct is repr('CStruct') {
	has Point $.point;  # referenced 
	submethod TWEAK() { $!point := Point.new }; 
}

my $mystruct = MyStruct.new ;
$mystruct.point.x = num64.new(888e0)  ;


class MyStruct2 is repr('CStruct') {
	HAS Point $.point;  # embedded 
	submethod TWEAK() { $!point := Point.new }; 
}

my $mystruct2 = MyStruct2.new ;
$mystruct2.point.x = num64.new(777e0)  ;



class MyStruct3 is repr('CStruct') {
	HAS Point $.point;  # embedded 
	has int32 $.int32 ;
	submethod TWEAK() { $!point := Point.new }; 
}

my $mystruct3 = MyStruct3.new: :int32(7) ;
$mystruct3.point.x = num64.new(777e0)  ;


sub add_p6(Int, Int) returns Int { 1 }
sub some_argless_function() is native('something') { * }
our sub init() is native('foo') is symbol('FOO_INIT') { * }
sub add(int32, int32) returns int32 is native("calculator") { * }
sub Foo_init() returns Pointer is native("foo") { * }

class Types is repr('CStruct') {
	has int8 $.a1 ;
	has int16 $.a2 ;
	has int32 $.a3 ;
	has int64 $.a4 ;
	has uint8 $.a5 ;
	has uint16 $.a6 ;
	has uint32 $.a7 ;
	has uint64 $.a8 ;
	has long $.a9 ;
	has longlong $.a10 ;
	has ulong $.a11 ;
	has ulonglong $.a12 ;
	has num32 $.a13 ;
	has num64 $.a14 ;
	has Str $.a15 ;
	has CArray[int32] $.a16 ;
	has Pointer[void] $.a17 ;
	has bool $.a18 ;
	has size_t $.a19 ;
	has ssize_t $.a20 ;
}

my $types = Types.new ;

class MyHandle is repr('CPointer') {}
my Pointer[int32] $pointer ;

my int32 $int32 = 7 ;
my @with_int32 = $int32, 7, 8 ; 
my int32 @int32 = $int32, 7, 8 ; 

my $string = "FOO";
my @carray := CArray[uint8].new($string.encode.list);

my $carray_titles = CArray[Str].new;
$carray_titles[0] = 'Me';
$carray_titles[1] = 'You';

class StructiWithHandler is repr('CStruct') { has int32 $.flags }

role DDT_SWH
{
multi method get_header (StructiWithHandler $s)
	{ 'In DDT Handler', '.' ~ $s.^name, DDT_FINAL  }
}

my $d1 = (&add_p6, &add, &init, &some_argless_function, &Foo_init) ;
my $d2 = (MyHandle, $pointer) ;
my $d3 = ($int32, @with_int32, @int32, @carray, $carray_titles, ) ;
my $d4 = (Types, $types) ;
my $d5 = (Point, $point, $union, MyStruct) ;
my $d6 = StructiWithHandler ;

my $d7 = (MyStruct,  MyStruct.new,  $mystruct,  DVO "native_size: {nativesizeof MyStruct}", ) ; 
my $d8 = (MyStruct2, MyStruct2.new, $mystruct2, DVO "native_size: {nativesizeof MyStruct2}", ) ; 
my $d9 = (MyStruct3, MyStruct3.new, $mystruct3, DVO "native_size: {nativesizeof MyStruct3}", ) ; 

ddt $d1, :indent('  '), :nl ;
ddt $d2, :indent('  '), :nl ;
ddt $d3, :indent('  '), :nl  ;
ddt $d4, :indent('  '), :flat(0), :nl  ;

ddt $d5, :indent('  '), :nl  ;
ddt $d6, :does[DDT_SWH], :indent('  '), :nl  ;

ddt $d7, :indent('  '), :nl  ;
ddt $d8, :indent('  '), :nl  ;
ddt $d9, :indent('  '), :nl  ;

# IRL example

class wrong_rgba_color_s is repr('CStruct'){
	has	int32 $.red;
	has	int32 $.blue;
	has 	int32 $.green;
}

class rgba_color_s is repr('CStruct'){
	has	int32 $.red;
	has	int32 $.blue;
	has 	int32 $.green;
	has 	int32 $.alpha;
}


#struct s_toyunda_sub {
#        usigned int     start;
#        usigned int     stop;
#        char*   text;
#        rgba_color_t    color1;
#        rgba_color_t    color2;
#        rgba_color_t    tmpcolor;
#        float   positionx;
#        float   positiony;
#        float   position2x;
#        float   position2y;
#        float   fadingpositionx;
#        float   fadingpositiony;
#        int     size;
#        int     size2;
#        int fadingsize;
#        char*   image;
#};

class toyunda_subtitle_s is repr('CStruct') {
	has	int32 	$.start;
	has	int32	$.stop;

	has	Str	$.text;
	HAS	rgba_color_s	$.color1;
	HAS	rgba_color_s	$.color2;
	has	rgba_color_s	$.tmpcolor; # it should be HAS

	has	num32		$.positionx;
	has	num32		$.positiony;
	has	num32		$.position2x;
	has	num32		$.position2y;
	has	num32		$.fadingpositionx;
	has	num32		$.fadingpositiony;

	has	int32		$.size;
	has	int32		$.size2;
	has	int32		$.fadingsize;

	has	str		$.image; # bad use of str
}

ddt toyunda_subtitle_s, :indent('  '), :nl  ;
ddt toyunda_subtitle_s.new, :indent('  '), :nl  ;


