
use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;

role DDTR::Diff
{
has Bool $diff_glyphs = True ;
has %diff_glyphs = 
	same_object          => '===',
	same_type_same_value => 'eqv',
	same_type_diff_value => '!= ',
	different_type       => ' ! ',
	same_container       => ' ~ ',
	diff_container       => '!~!',
	container_left       => ' [r',
	container_right      => 'l] ',
	only_lhs             => 'l  ',
	only_rhs             => '  r' ;

has $diff_synch_filter ;

method dump_synched($s1, $s2, *%options) 
{
$diff_synch_filter = %options<diff_synch_filter> ;

%.colors<diff1 diff2 diff_glyphs> = ('reset', 'reset', 'reset') ;

my $color = role { method Str { state $++ %% 2 ?? 'diff1' !! 'diff2' } }.new  ;
self.reset ;

$diff_glyphs [R//]= %options<diff_glyphs> ;

my $diff_glyph_width = max(%diff_glyphs.values>>.chars) + 2 ;

my $width = Int(((%options<width> // $.width) - ($diff_glyph_width + 1)) / 2) ;
my $d1 = Data::Dump::Tree.new(
		|%options, width => $width, 
		title => (%options<lhs_title title>:v)[0] // '',
		header_filters => %options<header_filters lhs_header_filters>:v,
		elements_filters => %options<elements_filters lhs_elements_filters>:v,
		footer_filters => %options<footer_filters lhs_footer_filters>:v,
		) ;
 
$d1.reset ; #setup object

my $d2 = Data::Dump::Tree.new(
		|%options, width => $width,
		title => (%options<rhs_title title>:v)[0] // '',
		header_filters => %options<header_filters rhs_header_filters>:v,
		elements_filters => %options<elements_filters rhs_elements_filters>:v,
		footer_filters => %options<footer_filters rhs_footer_filters>:v,
		) ;
 
$d2.reset ; # setup object

my @diff_glyphs ;

my $empty_glyph = ('', '', '') ;
my @root_glyphs = 0, |( $empty_glyph xx 5)  ;

$.diff_elements(
	# $dumper, $header, $depth, @head_glyphs, @glyphs
	$d1, ($d1.get_title, '', $s1, ''), 0, (), @root_glyphs,
	@diff_glyphs,
	$d2, ($d2.get_title, '', $s2, ''), 0, (), @root_glyphs,
	) ;


my ($remove_eqv, $remove_eq) = %options<remove_eqv remove_eq> ;

if %options<compact_width>
	{
	my $max_line_width ;

	for $d1.get_renderings Z @diff_glyphs -> ($r1, $dg)
		{ 
		next if $remove_eq && $dg eq %diff_glyphs<same_object> ;
		next if $remove_eqv && $dg eq %diff_glyphs<same_type_same_value> ;

		$max_line_width max=  $r1.map( { $_[1] } ).join.chars ;
		}
	
	$width = min $width, $max_line_width ;
	}

for $d1.get_renderings Z @diff_glyphs Z $d2.get_renderings -> ($r1, $dg is copy, $r2) 
	{
	next if $remove_eq && $dg eq %diff_glyphs<same_object> ;
	next if $remove_eqv && $dg eq %diff_glyphs<same_type_same_value> ;

	$dg = '' unless $diff_glyphs ;

	my $r1c = $r1.map( { $_.join } ).join ;
	my $r1w = $r1.map( { $_[1] } ).join.chars ;
 
	my $color_width = $r1c.chars - $r1w ;

	printf "%-{$width + $color_width}s %-{$diff_glyph_width}s %s",
		$r1c,
		$dg,
		$r2.map( { $_.join } ).join ;

	''.say ;
	}
}

method diff_elements(
	$d1, $s1_header, $cd1, $head_glyph1, @glyphs1,
	@diff_glyphs,
	$d2, $s2_header, $cd2, $head_glyph2, @glyphs2,
	)
{
my ($final1, $rendered1, $s1, $cont_glyph1) = 
	$d1.render_element($s1_header, $cd1, $head_glyph1, @glyphs1) ; 

my ($final2, $rendered2, $s2, $cont_glyph2) = 
	$d2.render_element($s2_header, $cd2, $head_glyph2, @glyphs2) ; 

# handle Seq as they get consumed during the diff
my sub cache_seq(Seq $s)
	{
	my $seq_display_size = $d1.consume_seq<max_element_vertical> ;
	my $size = $s.is-lazy ?? ~Inf !! $s.elems ;

	my @l = $s.cache[0..^$seq_display_size].grep({.defined}) ;
	@l.push: Data::Dump::Tree::Type::Final.new(:value('..' ~ $size)) if $size > $seq_display_size ;

	@l
	}

$s1 = cache_seq($s1)  if $s1 ~~ Seq ;
$s2 = cache_seq($s2)  if $s2 ~~ Seq ;

my ($pad_glyph1, $pad_glyph2) = (|$head_glyph1, @glyphs1[2]), (|$head_glyph2, @glyphs2[2]) ;

my $diff_glyph = ' ? ' ;
my $is_different = 0 ;

# handle sub level
if $final1 && !$final2  # different types
	{
	$diff_glyph = %diff_glyphs<container_left> ;
	$d2.render_non_final($s2, $cd2, (|$head_glyph2, $cont_glyph2), $s2_header) unless $rendered2 ;
	$is_different++ ;
	}
elsif !$final1 && $final2  # different types
	{
	$diff_glyph = %diff_glyphs<container_right> ;
	$d1.render_non_final($s1, $cd1, (|$head_glyph1, $cont_glyph1), $s1_header) unless $rendered1 ;
	$is_different++ ;
	} 
elsif $final1 && $final2
	{
	$diff_glyph = $s1.^name ~~ $s2.^name
			?? ($s1.WHERE == $s2.WHERE) 
				?? %diff_glyphs<same_object> 
				!! $s1 eqv $s2
					?? %diff_glyphs<same_type_same_value>
					!! do { $is_different++ ; %diff_glyphs<same_type_diff_value> }
			!! do { $is_different++ ; %diff_glyphs<different_type> } ;	
	}
else
	{
	if $s1.^name ~~ $s2.^name
		{
		if $s1.WHERE == $s2.WHERE
			{
			$diff_glyph = %diff_glyphs<same_object> ;
			$d1.render_non_final($s1, $cd1, (|$head_glyph1, $cont_glyph1), $s1_header) ;
			$d2.render_non_final($s2, $cd2, (|$head_glyph2, $cont_glyph2), $s2_header) ;
			}
		elsif $s1 eqv $s2
			{
			$diff_glyph = %diff_glyphs<same_type_same_value> ;
			$d1.render_non_final($s1, $cd1, (|$head_glyph1, $cont_glyph1), $s1_header) ;
			$d2.render_non_final($s2, $cd2, (|$head_glyph2, $cont_glyph2), $s2_header) ;
			}
		else
			{
			$diff_glyph = %diff_glyphs<same_container> ;
			
			synch_renderings(
				$d1.get_renderings, $pad_glyph1,
				$d2.get_renderings, $pad_glyph2,
				@diff_glyphs, $diff_glyph,
				) ;

			my $index = @diff_glyphs.end ; # may have to change the glyph after rendering sub levels 

			my (@sub_elements1, %glyphs1) := $d1.get_sub_elements($s1, $cd1, (|$head_glyph1, $cont_glyph1), $s1_header) ;
			my (@sub_elements2, %glyphs2) := $d2.get_sub_elements($s2, $cd2, (|$head_glyph2, $cont_glyph2), $s2_header) ;

			if $diff_synch_filter
				{
				$diff_synch_filter(
					$s1, @sub_elements1, $cd1, $d1.get_renderings, (|$head_glyph1, $cont_glyph1),
					@diff_glyphs,
					$s2, @sub_elements2, $cd2, $d2.get_renderings, (|$head_glyph2, $cont_glyph2),
					) ;
				}
			else
				{
				if $s1 ~~ Hash and $s2 ~~ Hash
					{
					my %h1 = @sub_elements1.map: { $_[0] => $_ }  ;
					($s2.keys (-) $s1.keys).map: { %h1{$_.key} = ($_.key, ' (-)', Data::Dump::Tree::Type::Nothing.new) } ;
					@sub_elements1 = %h1.sort(*.key)>>.kv.map: -> ($k, $v) { $v }

					my %h2 = @sub_elements2.map: { $_[0] => $_ }  ;
					($s1.keys (-) $s2.keys).map: { %h2{$_.key} = ($_.key, ' (-)', Data::Dump::Tree::Type::Nothing.new) } ;
					@sub_elements2 = %h2.sort(*.key)>>.kv.map: -> ($k, $v) { $v }
					}
				}

			for zipi(@sub_elements1, @sub_elements2) -> ($index, $sub1, $sub2)
				{
				my $sub_element_glyphs1 = $d1.get_element_glyphs(%glyphs1,  $index == @sub_elements1.end) ;
				my $sub_element_glyphs2 = $d2.get_element_glyphs(%glyphs2,  $index == @sub_elements2.end) ;

				if $sub1.defined && $sub2.defined
					{
					$is_different +=  $.diff_elements(
								$d1, $sub1, $cd1 + 1, (|$head_glyph1, $cont_glyph1), $sub_element_glyphs1, 
								@diff_glyphs,
								$d2, $sub2, $cd2 + 1, (|$head_glyph2, $cont_glyph2), $sub_element_glyphs2,
								) ;
					}
				elsif $sub1.defined
					{
					$is_different++ ;
					$diff_glyph = %diff_glyphs<only_lhs> ;
					$d1.render_element_structure($sub1, $cd1 + 1, (|$head_glyph1, $cont_glyph1), $sub_element_glyphs1) ;
					}
				else
					{
					$is_different++ ;
					$diff_glyph = %diff_glyphs<only_rhs> ;
					$d2.render_element_structure($sub2, $cd2 + 1, (|$head_glyph1, $cont_glyph2), $sub_element_glyphs2) ; 
					}
				}

			@diff_glyphs[$index] =	%diff_glyphs<same_type_same_value> unless $is_different ;
			}
		}
	else
		{
		# different type but equivalent
		if $s1 eqv $s2
			{
			$diff_glyph = %diff_glyphs<same_type_same_value> ;

			$d1.render_non_final($s1, $cd1, (|$head_glyph1, $cont_glyph1), $s1) unless $rendered1 ;
			$d2.render_non_final($s2, $cd2, (|$head_glyph2, $cont_glyph2), $s2) unless $rendered2 ;
			}
		else
			{
			$diff_glyph = %diff_glyphs<diff_container> ;
			$d1.render_non_final($s1, $cd1, (|$head_glyph1, $cont_glyph1), $s1) unless $rendered1 ;
			$d2.render_non_final($s2, $cd2, (|$head_glyph2, $cont_glyph2), $s2) unless $rendered2 ;
			$is_different++ ;
			}
		}
	}

# footer filter 
$d1.footer_filters and $s1.WHAT !=:= Mu and 
	$d1.filter_footer($s1, ($cd1, (|$head_glyph1, $cont_glyph1), $d1.get_renderings))  ;

$d2.footer_filters and $s2.WHAT !=:= Mu and 
	$d2.filter_footer($s2, ($cd2, (|$head_glyph2, $cont_glyph2), $d2.get_renderings))  ;

synch_renderings(
	$d1.get_renderings, $pad_glyph1,
	$d2.get_renderings, $pad_glyph2,
	@diff_glyphs, $diff_glyph,
	) ;

$is_different ;
}

sub synch_renderings(@r1, $p1, @r2, $p2, @d, $dg)
{
@r1.append: $p1 xx @r2.elems - @r1.elems ;
@r2.append: $p2 xx @r1.elems - @r2.elems ;
@d.append: $dg xx @r1.elems - @d.elems ;
}

sub zipi(**@as)
{
my @zip ;

(^max @as.map: {$_.elems}).map: -> $index
	{
	@zip.append: $[ $index, |(@as.map: { $_[$index] }) ], ;
	}

@zip
}


#role
}

