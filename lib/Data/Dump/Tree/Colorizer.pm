 
class Colorizer
{
has %!color_lookup ;

method set_colors(%colors, $do_color) 
{
if $do_color
	{
	for %colors.kv -> $color_name, $color { %!color_lookup{$color_name} = $.lookup_color($color) } 
	}
else
	{
	%!color_lookup = () ;
	}
}	

method lookup_color($color_name) { $color_name }

multi method color(Hash $h, Str $name --> Hash) 
{
my %colored_hash ;

for $h.kv -> $k, $v { %colored_hash{$k} = (%!color_lookup{$name} // '') , $v , %!color_lookup<reset> // ''} 

%colored_hash ;
}

multi method color(List $l, Str $name --> Seq) { $l.map: { (%!color_lookup{$name} // '') , $_ , %!color_lookup<reset> // ''} }
multi method color(Str $string, Str $name --> List) { (%!color_lookup{$name} // '') , $string , %!color_lookup<reset> // ''}
}

class HtmlColorizer is Colorizer
{

method lookup_color($color_name)
{
"<font color=$color_name>"
}

}

class CursesColorizer is Colorizer
{

}

class AnsiColorizer is Colorizer
{
has &.colorizer ;

method new
{
my &colorizer ;

if (try require ::Terminal::ANSIColor) !=== Nil 
	{
	&colorizer = ::("Terminal::ANSIColor::EXPORT::ALL::&color")
	}

self.bless(:is_ansi, :colorizer(&colorizer));
}

method lookup_color($color_name)
{
&!colorizer ?? &!colorizer($color_name) !! ''
}

#class
}


