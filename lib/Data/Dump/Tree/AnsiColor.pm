 
class AnsiColor
{
has %!color_lookup ;
has Bool $.is_ansi is rw = False ;
has &.ansicolor;

method new
{
my $is_ansi = False;
my &ansicolor;

if (try require ::Terminal::ANSIColor) === Nil {
    &ansicolor = sub (Str $s) {''}
} else {
    $is_ansi = True ;
    &ansicolor = ::("Terminal::ANSIColor::EXPORT::ALL::&color");
}

self.bless(:$is_ansi, :&ansicolor);
}

method !set_lookup_table(%lookup, $ansi_code) { for %lookup.kv -> $k, $v { %!color_lookup{$k} = $ansi_code($v) } }

method set_colors(%lookup, Bool $do_ansi)
{
%lookup<reset> = 'reset' ;

$.is_ansi && $do_ansi 
	?? self!set_lookup_table(%lookup, &.ansicolor)
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


