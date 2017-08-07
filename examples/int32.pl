#!/usr/bin/env perl6

use NativeCall ;

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::DescribeBaseObjects ;

role my_role { has $.something } # test that Int+something type displays correctly 

class Point is repr('CStruct') {
    has num64 $.x;
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
	has int32 $.flags;
}

say nativesizeof(MyStruct.new); 
say nativesizeof(MyStruct); 

my $mystruct = MyStruct.new ;
#$mystruct.point = $point ;

class MyStruct2 is repr('CStruct') {
	HAS Point $.point;  # embedded 
	has int32 $.flags;
}

say nativesizeof(MyStruct2.new); 
say nativesizeof(MyStruct2); 

my $mystruct2 = MyStruct2.new ;
#$mystruct2.point = $point ;


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

class StructiWithHandler is repr('CStruct') 
{
	has int32 $.flags;
}

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
my $d7 = (StructiWithHandler, MyStruct, MyStruct.new) ;

''.say ;
ddt $d1, :indent('  '), :nl ;
ddt $d2, :indent('  '), :nl ;
ddt $d3, :indent('  '), :nl  ;
ddt $d4, :indent('  '), :flat(0), :nl  ;

ddt $d5, :indent('  '), :nl  ;
ddt $d6, :does[DDT_SWH], :indent('  '), :nl  ;

dd $d3 ;

#`<<<
[16:53] <timotimo> that's more a property of a variable, really
[16:53] <timotimo> m: my int32 $foo = 99; say $foo.WHAT; say $foo.VAR.WHAT;
[16:53] <camelia> rakudo-moar aca4b9: OUTPUT: «(Int)␤(IntLexRef)␤»


[16:55] <timotimo> there you'll get a IntPosRef
[16:55] <timotimo> which is like an IntLexRef but instead of a lexical pad it refers to a native array
[16:55] <timotimo> m: my int32 @foo = 1, 2, 3; say @foo[1].WHAT; say @foo[1].VAR.WHAT
[16:55] <camelia> rakudo-moar aca4b9: OUTPUT: «(Int)␤(IntPosRef)␤»

[22:04] <Skarsnik> nadim, this can maybe help figure stuff about native type https://github.com/rakudo/rakudo/blob/nom/lib/NativeCall.pm6#L233


[11:24] <nadim> IE: $mystruct2.point = $point ; gave me error: Cannot modify an immutable Point ((Point))
[11:33] <nine> nadim: you'll probably have to initialize the fields individually: $mystruct2.point.x = 1; $mystruct2.point.y = 2;
[11:35] <lookatme> nadim, you can write a read-only accessor
[11:40] <lookatme> m: use NativeCall; class Point is repr("CStruct") { has num64 $.x; has num64 $.y; submethod TWEAK() { $!x = num64.new(10); $!y = num64.new(10);}; }; class MS is repr("CStruct") { has Point $.point; has int32 $.flags; submethod TWEAK() { $!point := Point.new; $!flags = 1; }; }; say MS.new
[11:40] <camelia> rakudo-moar a91ad2: OUTPUT: «MS.new(point => Point.new(x => 10e0, y => 10e0), flags => 1)␤»
[11:41] <lookatme> m: use NativeCall; class Point is repr("CStruct") { has num64 $.x; has num64 $.y; submethod TWEAK() { $!x = num64.new(10); $!y = num64.new(10);}; }; class MS is repr("CStruct") { has Point $.point; has int32 $.flags; submethod TWEAK() { $!point := Point.new; $!flags = 1; }; }; my $ms = MS.new; $ms.point.x = num64.new(32); say $ms;
[11:41] <camelia> rakudo-moar a91ad2: OUTPUT: «Cannot modify an immutable Num (10)␤  in block <unit> at <tmp> line 1␤␤»
[11:42] <lookatme> m: use NativeCall; class Point is repr("CStruct") { has num64 $.x is rw; has num64 $.y; submethod TWEAK() { $!x = num64.new(10); $!y = num64.new(10);}; }; class MS is repr("CStruct") { has Point $.point; has int32 $.flags; submethod TWEAK() { $!point := Point.new; $!flags = 1; }; }; my $ms = MS.new; $ms.point.x = num64.new(32); say $ms;
[11:42] <camelia> rakudo-moar a91ad2: OUTPUT: «MS.new(point => Point.new(x => 32e0, y => 10e0), flags => 1)␤»
[11:42] <lookatme> nadim, does ^^ helpful ?
[11:46] <lookatme> off work now

>>>


