#!/usr/bin/env perl6

use NativeCall ;

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::DescribeBaseObjects ;

role my_role { has $.something } # test that Int+something type displays correctly 

role DDT_NR
{
}


my int32 $int32 = 7 ;
my int32 @int32 = $int32, 7, 8 ; 
my int64 @int64 = $int32, 7, 8 ; 
my @with_int32 = $int32, 7, 8 ; 

my Pointer[int32] $pointer ;

class FooHandle is repr('CPointer')
{
}

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

class MyStruct2 is repr('CStruct') {
	HAS Point $.point;  # embedded 
	has int32 $.flags;
}

sub some_argless_function() is native('something') { * }
our sub init() is native('foo') is symbol('FOO_INIT') { * }
sub add(int32, int32) returns int32 is native("calculator") { * }
sub add_p6(Int, Int) returns Int { 1 }
sub add_p62(Int, Int) { 1 }
sub add_p63(Int, Int --> Int) { 1 }

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

my $string = "FOO";
my @array := CArray[uint8].new($string.encode.list);

my $titles = CArray[Str].new;
$titles[0] = 'Me';
$titles[1] = 'You';

my $d3 = (MyStruct, MyStruct.new, MyStruct2, MyStruct2.new, @array, $titles, Types, Types.new, &add_p6, &add_p62, &add_p63, &add, &init, &some_argless_function, Point, FooHandle, $pointer, @int32, @with_int32, $int32, @int64, $point, $union) ;
ddt $d3 ;

''.say ;

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
>>>

