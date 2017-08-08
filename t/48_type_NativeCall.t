#!/usr/bin/env perl6

use Test ;
plan 17 ;

use NativeCall ;
use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;

my $d = Data::Dump::Tree.new: :!color ;


class Point is repr('CStruct') {
    has num64 $.x is rw;
    has num32 $.y;
    has int32 $.z = 3;
}

my $point = Point.new: :x(2e56), :y(10e10) ;

my $dump = $d.get_dump: $point;
is $dump.lines.elems, 4, '4 lines' or diag $dump ;
like $dump, /'<CStruct>'/, '<CStruct>' or diag $dump ;
like $dump, /'int32'/, 'int32' or diag $dump ;

class Parts is repr('CUnion') {
        has int32 $.xyz;
        has int64 $.abc;
}

my Parts $union = Parts.new: :abc(10 ** 10) ;

$dump = $d.get_dump: $union ;
is $dump.lines.elems, 3, '3 lines' or diag $dump ;
like $dump, /'<CUnion>'/, '<CUnion>' or diag $dump ;

class MyStruct is repr('CStruct') {
	has Point $.point;  # referenced 
	submethod TWEAK() { $!point := Point.new }; 
}

my $mystruct = MyStruct.new ;
$mystruct.point.x = num64.new(888e0)  ;

$dump = $d.get_dump: $mystruct ;
is $dump.lines.elems, 5, '5 lines' or diag $dump ;
like $dump, /'int32'/, 'sub element' or diag $dump ;

sub some_argless_function() is native('something') { * }

$dump = $d.get_dump: &some_argless_function ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'<NativeCall>'/, 'sub <NativeCall>' or diag $dump ;

class MyHandle is repr('CPointer') {}
$dump = $d.get_dump: MyHandle ;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'<CPointer>'/, '<CPointer>' or diag $dump ;

my Pointer[int32] $pointer ;

$dump = $d.get_dump: $pointer;
is $dump.lines.elems, 1, '1 line' or diag $dump ;
like $dump, /'<CPointer>'/, '<CPointer>' or diag $dump ;

my int32 @int32 = 6, 7, 8 ; 
$dump = $d.get_dump: @int32;
is $dump.lines.elems, 4, '4 lines' or diag $dump ;
like $dump, /'<array>'/, '<array>' or diag $dump ;

my $carray_titles = CArray[Str].new;
$carray_titles[0] = 'Me';
$carray_titles[1] = 'You';

$dump = $d.get_dump: $carray_titles ;
is $dump.lines.elems, 3, '3 lines' or diag $dump ;
like $dump, /'<CArray>'/, 'CArray>' or diag $dump ;

