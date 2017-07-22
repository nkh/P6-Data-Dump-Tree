
use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;

role DDT::MultiColumns
{

method display_columns(**@rs, :$total_width, :$width, Bool :$compact?)
{
$.get_columns(|@rs, :$total_width, :$width, :$compact).say ;
}

my regex COLOR { \[ \d+ [\;\d+]* <?before [\;\d+]* > m } 

my role MaxLines { has $.max_lines is rw = 0 } 

method get_columns(**@rs, :$total_width, :$width, Bool :$compact)
{
return '' unless @rs ;

my $current_length = 0 ;
my $current_block = [] but MaxLines ;
my $current_block_max_length = 0 ;
my @blocks = $current_block ;

for |@rs
	{
	$current_block.max_lines max= $_.elems ; 

	my @lines_width ;

	# compute width without ANSI escape codes
	my $r_max_width = (.map: { my $w = S:g/ \e <COLOR> //.chars ; @lines_width.push: $w ; $w }).max ;

	my $r_width = $compact ?? $r_max_width !! max $width // 0, $r_max_width ;

	if $total_width.defined && $current_length + $r_width >= $total_width 
		{
		$current_length = 0 ;
		$current_block = [] but MaxLines ;
		@blocks.push: $current_block ; 
		}

	$current_length += $r_width + 1 ; # joined with a single space later
	$current_block.push: $r_width, @lines_width, $_ ;
	}

my $o ;

for @blocks -> @block
	{
	for ^@block.max_lines -> $index
		{
		my $string ; 

		for @block -> $width, $width_lines, $lines 
			{
			$string ~= $index < $lines.elems
					?? $lines[$index] ~ (' ' x $width - $width_lines[$index]) ~ ' '
					!! ' ' x $width ~ ' ' ;
			}

		$o ~= $string ~ "\n" ;
		}
	}

$o ;
} 


} # role


