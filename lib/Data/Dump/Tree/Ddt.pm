
unit module Data::Dump::Tree::Ddt ;

sub ddt_curses(|args ) is export
{
try 
	{
	require Data::Dump::Tree::CursesFoldable <&display_foldable> ;
	display_foldable |args ;
	}

$!.note if $! ;
}

sub ddt_remote ($s, :$remote_port is copy, |other) is export 
{
$remote_port //= 3333 ;

try 
	{
	my $c = IO::Socket::INET.new: :host<localhost>, :port($remote_port) ;
	$c.print: $s ;
	$c.close
	}
		
if $!
	{
	"Error: Can't send below data to port:$remote_port time:{DateTime.now}".note ;
	$s.note ;
	}
}


