use v6.c;

use Data::Dump::Tree ;
use Data::Dump::Tree::Foldable ;
use Data::Dump::Tree::CursesFoldable ;

use MONKEY-SEE-NO-EVAL;
use experimental :pack ;

# https://github.com/FROGGS/p6-Ser/blob/master/lib/Ser.pm

sub MAIN(:$port = 4444, Bool :$timestamp, Bool :$counter)
{
"listening on: localhost port: $port".say ;

my $listen = IO::Socket::INET.new(:listen, :localhost<localhost>, :localport($port));
loop 
	{
	my $connection = $listen.accept ;

	my $t0 = now ;

	my $buffer = $connection.read(4) ;
	"$port:{DateTime.now}".say if $timestamp ;

	my $size = $buffer.unpack('N') // 0 ;
	"receiving: $size".say if $counter ;

	my $received = 0 ;
	my $block = '' ;

	while $block.chars < $size
		{
		$buffer = $connection.recv(:bin) ;
		$block ~= $buffer.decode('utf8') ;

		$received += $buffer.elems ;
		"received: {$buffer.elems}, total: $received".say if $counter ;
		}

	$connection.close ;

	"decoded: {$block.chars} characters".say if $counter ;
	"reception time: {now - $t0}".say if $timestamp ;
	
	"creating Foldable object ...".say ;
	$t0 = now ;
	my $foldable = EVAL($block) ;
	"creation time: {now - $t0}".say if $timestamp ;

	display_foldable($foldable) ;
	}
}
