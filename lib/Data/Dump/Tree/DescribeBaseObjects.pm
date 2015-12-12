
use lib '.' ;
use Data::Dump::Tree::Enums ;

role DescribeBaseObjects
{
# get_headers: "final" objects returnf their value and type
multi method get_header (Int $i) { ($i,  '.' ~ $i.^name, DDT_FINAL) }
multi method get_header (Str $s) { ($s.defined ?? $s !! 'Type object', '.' ~ $s.^name, DDT_FINAL) }
multi method get_header (Rat $r) { ('den: ' ~ $r.denominator ~ ' num: ' ~ $r.numerator, '.' ~ $r.^name, DDT_FINAL) }

# Block must be declare or it groaks when passed a Sub
#TODO: report to P6P
multi method get_header (Block $b) { ($b.perl, '.' ~ $b.^name, DDT_FINAL) }
multi method get_header (Routine $r) { ('', '.' ~ $r.^name, DDT_FINAL) }
multi method get_header (Sub $s) { ($s.perl, '.' ~ $s.^name, DDT_FINAL) }

# get_headers: containers return some information and their type
multi method get_header (Any $a) { ('',([$a.^name, |self!get_Any_parents_list($a)].map: {'.' ~ $_}).join(' ')) } 
multi method get_elements (Any $a) { [ self!get_Any_attributes($a)] } 

multi method get_header (Match $a) { ('[' ~ $a.from ~ ' .. ' ~ $a.to ~ ']', '.' ~ $a.^name, DDT_FINAL) } 
multi method get_header (Grammar $a) { ($a.perl, '.Grammar', DDT_FINAL) } 

multi method get_header (List $l) { ('', '(' ~ $l.elems ~ ')') }
multi method get_elements (List $l) { [ ($l Z 0 .. *).map: -> ($v, $i) {"$i = ", $v} ] }

multi method get_header (Array $a) { ('', '[' ~ $a.elems ~ ']') }

multi method get_header (Hash $h) { ('', '{' ~ $h.elems ~ '}') }
multi method get_elements (Hash $h) { [ $h.sort(*.key)>>.kv.map: -> ($k, $v) {"$k => ", $v} ] }

}

role Data::Dump::Tree::Role::MatchDetails 
{
multi method get_header (Match $a) { ('', '.' ~ $a.^name) } 
multi method get_elements (Match $a) 
{
# removed list hash ast
[ <from to orig>.map: { ("$_: ", $a."$_"()) } ]
}
#role 
}

role Data::Dump::Tree::Role::PerlString 
{
multi method get_header (Str $s) { ($s.perl, '.' ~ $s.^name, DDT_FINAL) } 
}

role Data::Dump::Tree::Role::SilentSub
{
multi method get_header (Routine $r) { ('', '.' ~ $r.^name, DDT_FINAL) }
multi method get_header (Sub $r) { ('', '.' ~ $r.^name, DDT_FINAL) }
}

class Data::Dump::Tree::Type::Nothing
{
multi method ddt_get_header { ('', '', DDT_FINAL) }
}


