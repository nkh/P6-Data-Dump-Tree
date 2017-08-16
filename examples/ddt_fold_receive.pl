use v6.c;

# This example is teken directly from the Perl6 documention.
# It's a no thrill print server on localhost, it will say what you send it.

use Data::Dump::Tree ;
use Data::Dump::Tree::Foldable ;
use Data::Dump::Tree::CursesFoldable ;

use MONKEY-SEE-NO-EVAL;

# https://github.com/FROGGS/p6-Ser/blob/master/lib/Ser.pm

sub MAIN(:$port = 4444, Bool :$timestamp)
{
"listening on: localhost port: $port".say ;

my $listen = IO::Socket::INET.new(:listen, :localhost<localhost>, :localport($port));
loop 
	{
	my $connection = $listen.accept ;

	while my $buffer = $connection.recv(:bin)
		{
		"$port:{DateTime.now}".say if $timestamp ;

		my $t0 = now ;
		my $decoded = $buffer.decode('utf-8') ;

		my $t1 = now ;
		"decoded in {$t1 - $t0 } s".say ;
	
		my $f = EVAL($decoded) ;

		my $t2 = now ;
		"evaled in {$t2 - $t1 } s".say ;
		
		display_foldable($f) ;
		}

	$connection.close;
	}
}
