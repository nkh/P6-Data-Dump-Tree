 
class AnsiColor
{
has %!color_lookup ;
has Bool $.is_ansi is rw = False ;

method new
{
my $is_ansi = False;

if (try require ::Terminal::ANSIColor) !=== Nil { $is_ansi = True }

self.bless(:is_ansi);
}

method !set_lookup_table(%lookup, $ansi_code) { for %lookup.kv -> $k, $v { %!color_lookup{$k} = $ansi_code($v) } }

method set_colors(%lookup, Bool $do_ansi)
{
%lookup<reset> = 'reset' ;

$.is_ansi && $do_ansi 
	?? self!set_lookup_table(%lookup, ::("Terminal::ANSIColor::EXPORT::ALL::&color"))
	!! self!set_lookup_table(%lookup, sub (Str $s) {''}) ;
}

multi method color(Hash $h, Str $name --> Hash) 
{
my %colored_hash ;

for $h.kv -> $k, $v { %colored_hash{$k} = (%!color_lookup{$name} // '') ~ $v ~ %!color_lookup<reset>} 

%colored_hash ;
}

multi method color(List $l, Str $name --> Seq) { $l.map: { (%!color_lookup{$name} // '') ~ $_ ~ %!color_lookup<reset>} }
multi method color(Str $string, Str $name --> Str) { (%!color_lookup{$name} // '') ~ $string ~ %!color_lookup<reset> }

#class
}


