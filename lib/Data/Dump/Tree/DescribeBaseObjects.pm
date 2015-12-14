
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
multi method get_header (Any $a) { ('', self!get_class_and_parents($a)) }
multi method get_elements (Any $a) { [ self!get_Any_attributes($a)] } 

multi method get_header (Match $a) { ('[' ~ $a.from ~ '..' ~ $a.to ~ '|', '.' ~ $a.^name, DDT_FINAL) } 

multi method get_header (Grammar $a) { ($a.perl ~ ' ', '.Grammar', DDT_FINAL,) } 

multi method get_header (List $l) { ('', '(' ~ $l.elems ~ ')') }
multi method get_elements (List $l) { [ ($l Z 0 .. *).map: -> ($v, $i) {"$i = ", $v} ] }

multi method get_header (Array $a) { ('', '[' ~ $a.elems ~ ']') }

multi method get_header (Hash $h) { ('', '{' ~ $h.elems ~ '}') }
multi method get_elements (Hash $h) { [ $h.sort(*.key)>>.kv.map: -> ($k, $v) {"$k => ", $v} ] }

}

role Data::Dump::Tree::Role::MatchDetails 
{

multi method get_header (Match $a)
{
my $final = (1 == $a.keys && $a{$a.keys[0]} ~~ Nil) || 0 == $a.keys
                ?? DDT_FINAL
                !!  '' ;

( $a ~ ' [' ~ $a.from ~ '..' ~ $a.to ~ '|', '.' ~ $a.^name, $final )
}

multi method get_elements (Match $m)
{
[ ($m.keys.sort: { $m{$^a}.from <=> $m{$^b}.from }).map: { ( "$_: ", $m{$_}) } ]
}

#role
}

role DDTR::MatchDetails does Data::Dump::Tree::Role::MatchDetails {} 


role Data::Dump::Tree::Role::PerlString 
{
multi method get_header (Str $s) { ($s.perl, '.' ~ $s.^name, DDT_FINAL) } 
}
role DDTR::PerlString does Data::Dump::Tree::Role::PerlString {} ;

role Data::Dump::Tree::Role::SilentSub
{
multi method get_header (Routine $r) { ('', '.' ~ $r.^name, DDT_FINAL) }
multi method get_header (Sub $r) { ('', '.' ~ $r.^name, DDT_FINAL) }
}
role DDTR::SilentSub does Data::Dump::Tree::Role::SilentSub {} ;

class Data::Dump::Tree::Type::Nothing
{
multi method ddt_get_header { ('', '', DDT_FINAL) }
}


