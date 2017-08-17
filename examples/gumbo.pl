#!/usr/bin/env perl6

use NativeCall ;

use Data::Dump::Tree ;
use Data::Dump::Tree::Enums ;
use Data::Dump::Tree::DescribeBaseObjects ;

class GumboSourcePosition is repr('CStruct') is export {
	has uint32                        $.line; # unsigned int line
	has uint32                        $.column; # unsigned int column
	has uint32                        $.offset; # unsigned int offset
}
class GumboStringPiece is repr('CStruct') is export {
	has Str                           $.data; # const char* data
	has size_t                        $.length; # Typedef<size_t>->|unsigned int| length
}
class GumboVector is repr('CStruct') is export {
	has Pointer[Pointer]              $.data; # void** data
	has uint32                        $.length; # unsigned int length
	has uint32                        $.capacity; # unsigned int capacity
}
class GumboAttribute is repr('CStruct') is export {
	has int32                         $.attr_namespace; # GumboAttributeNamespaceEnum attr_namespace
	has Str                           $.name; # const char* name
	HAS GumboStringPiece              $.original_name; # GumboStringPiece original_name
	has Str                           $.value; # const char* value
	HAS GumboStringPiece              $.original_value; # GumboStringPiece original_value
	HAS GumboSourcePosition           $.name_start; # GumboSourcePosition name_start
	HAS GumboSourcePosition           $.name_end; # GumboSourcePosition name_end
	HAS GumboSourcePosition           $.value_start; # GumboSourcePosition value_start
	HAS GumboSourcePosition           $.value_end; # GumboSourcePosition value_end
}
class GumboDocument is repr('CStruct') is export {
	HAS GumboVector                   $.children; # GumboVector children
	has bool                          $.has_doctype; # bool has_doctype
	has Str                           $.name; # const char* name
	has Str                           $.public_identifier; # const char* public_identifier
	has Str                           $.system_identifier; # const char* system_identifier
	has int32                         $.doc_type_quirks_mode; # GumboQuirksModeEnum doc_type_quirks_mode
}
class GumboText is repr('CStruct') is export {
	has Str                           $.text; # const char* text
	HAS GumboStringPiece              $.original_text; # GumboStringPiece original_text
	HAS GumboSourcePosition           $.start_pos; # GumboSourcePosition start_pos
}
class GumboElement is repr('CStruct') is export {
	HAS GumboVector                   $.children; # GumboVector children
	has int32                         $.tag; # GumboTag tag
	has int32                         $.tag_namespace; # GumboNamespaceEnum tag_namespace
	HAS GumboStringPiece              $.original_tag; # GumboStringPiece original_tag
	HAS GumboStringPiece              $.original_end_tag; # GumboStringPiece original_end_tag
	HAS GumboSourcePosition           $.start_pos; # GumboSourcePosition start_pos
	HAS GumboSourcePosition           $.end_pos; # GumboSourcePosition end_pos
	HAS GumboVector                   $.attributes; # GumboVector attributes
}
class GumboNode_v_Union is repr('CUnion') is export {
	HAS GumboDocument                 $.document; # GumboDocument document
	HAS GumboElement                  $.element; # GumboElement element
	HAS GumboText                     $.text; # GumboText text
}
class GumboNode is repr('CStruct') is export {
	has int32                         $.type; # GumboNodeType type
	has GumboNode                     $.parent; # Typedef<GumboNode>->|GumboNode|* parent
	has size_t                        $.index_within_parent; # Typedef<size_t>->|unsigned int| index_within_parent
	has int32                         $.parse_flags; # GumboParseFlags parse_flags
	HAS GumboNode_v_Union             $.v; # Union v
	submethod TWEAK() { $!v := GumboNode_v_Union.new }; 
}
class GumboOptions is repr('CStruct') is export {
	has Pointer                       $.allocator; # Typedef<GumboAllocatorFunction>->|F:void* ( void*, Typedef<size_t>->|unsigned int|)*| allocator
	has Pointer                       $.deallocator; # Typedef<GumboDeallocatorFunction>->|F:void ( void*, void*)*| deallocator
	has Pointer                       $.userdata; # void* userdata
	has int32                         $.tab_stop; # int tab_stop
	has bool                          $.stop_on_first_error; # bool stop_on_first_error
	has int32                         $.max_errors; # int max_errors
	has int32                         $.fragment_context; # GumboTag fragment_context
	has int32                         $.fragment_namespace; # GumboNamespaceEnum fragment_namespace
}
class GumboOutput is repr('CStruct') is export {
	has GumboNode                     $.document; # Typedef<GumboNode>->|GumboNode|* document
	has GumboNode                     $.root; # Typedef<GumboNode>->|GumboNode|* root
	HAS GumboVector                   $.errors; # GumboVector errors
}


dd GumboNode  ;
''.say ;
ddt GumboNode, :indent('   '), :nl  ;

#dd GumboNode.new ;
#ddt GumboNode.new, :indent('  '), :nl  ;

my GumboNode $p = GumboNode.new ;
my GumboNode $g = GumboNode.new ;
#$g.parent := $p ;
 
dd $g  ;
''.say ;
ddt $g, :indent('  '), :nl  ;

