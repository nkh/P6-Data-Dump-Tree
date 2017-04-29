
use Data::Dump::Tree ;

role DDT::MultiColumns
{

multi method display_columns(**@rs, :$width?, Bool :$compact?)
{
$._display_columns(|@rs, :$width, :$compact)>>.say ;
}

multi method _display_columns(**@rs, :$width?, Bool :$compact?)
{
if @rs == 1
	{
	@rs[0] ;
	}
elsif @rs == 2 
	{
	$.get_concatenated_columns(
		@rs[0],
		@rs[1],
		:$width, :$compact
		) ;
	}
elsif @rs > 2
	{
	$.get_concatenated_columns(
		@rs[0],
		$._display_columns(|@rs[1..*], :$width, :$compact),
		:$width, :$compact
		) ;
	}
} 

method get_concatenated_columns(@r1, @r2, :$width is copy, Bool :$compact?)
{
my sub zips(**@as)
	{
	my @zip ;

	(^max @as.map: {$_.elems}).map: -> $index
		{
		@zip.append: $[ |(@as.map: { $_[$index] // '' }) ], ;
		}

	@zip
	} ;


#compute width without ANSI escape codes
my regex color { \[ \d+ [\;\d+]* <?before [\;\d+]* > m } 
my regex graph {\( [ 0|B ]}

my @r1_width = @r1.map: { S:g/ \e [ <color> | <graph> ] //.chars } ;

$width //= max @r1_width ;
$width = $compact ?? max @r1_width !! max $width, max @r1_width ;

my @concatenated_columns ;

for zips(@r1, @r1_width, @r2) -> ($r1, $r1w, $r2) 
	{
	my $color_width = $r1.chars - $r1w ;
	@concatenated_columns.push: sprintf("%-{$width + $color_width}s %s", $r1, $r2),
	}

@concatenated_columns ;
}

} # role


