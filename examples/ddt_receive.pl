use v6.c;

# This example is teken directly from the Perl6 documention.
# It's a no thrill print server on localhost, it will say what you send it.
 
sub MAIN(:$port = 3333, Bool :$timestamp)
{
"listening on: localhost port: $port".say ;

my $listen = IO::Socket::INET.new(:listen, :localhost<localhost>, :localport($port));
loop 
	{
	my $connection = $listen.accept ;

	while my $buffer = $connection.recv
		{
		"$port:{DateTime.now}".say if $timestamp ;
		$buffer.say ;
		}

	$connection.close;
	}
}
