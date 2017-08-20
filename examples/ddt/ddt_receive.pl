use v6.c;

use experimental :pack;

# This example is teken directly from the Perl6 documention.
# It's a no thrill print server on localhost, it will say what you send it.
 
sub MAIN(:$port = 3333, Bool :$timestamp, Bool :$counter)
{
"listening on: localhost port: $port".say ;

my $listen = IO::Socket::INET.new(:listen, :localhost<localhost>, :localport($port));
loop 
	{
	my $connection = $listen.accept ;

	my $buffer = $connection.read(4) ;
	"$port:{DateTime.now}".say if $timestamp ;

	my $size = $buffer.unpack('N') ;
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

	"decoded: {$block.chars} characters".say if $counter;
	$block.say ;

	$connection.close;
	}
}
