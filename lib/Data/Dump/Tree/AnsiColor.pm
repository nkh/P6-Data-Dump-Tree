 
class AnsiColor
{
has %!color_lookup ;

method set_colors(%lookup, Bool $do_ansi)
{
%lookup<reset> = 'reset' ;
	
self!set_lookup_table(%lookup, sub (Str $s) {''}) ;

if $do_ansi == True
	{
	try
		{
		require Terminal::ANSIColor;
		self!set_lookup_table(%lookup, GLOBAL::Terminal::ANSIColor::EXPORT::DEFAULT::<&color>) ;
		}
	}
}

method !set_lookup_table(%lookup, $ansi_code) { for %lookup.kv -> $k, $v { %!color_lookup{$k} = $ansi_code($v) } }

multi method color(List $l, Str $name --> Seq) { $l.map: { %!color_lookup{$name} ~ $_ ~ %!color_lookup<reset>} }
multi method color(Str $string, Str $name --> Str) { %!color_lookup{$name} ~ $string ~ %!color_lookup<reset> }

#class
}


