use v6.c;

use Data::Dump::Tree ;
use Data::Dump::Tree::Foldable ;
use Data::Dump::Tree::TerminalFoldable ;

use MONKEY-SEE-NO-EVAL;
use experimental :pack ;

# https://github.com/FROGGS/p6-Ser/blob/master/lib/Ser.pm

sub MAIN(:$port = 4444, Bool :$timestamp, Bool :$counter, Bool :$help)
{

with $help { display_help() and exit 0 }

"listening on: localhost port: $port".say ;

my $listen = IO::Socket::INET.new(:listen, :localhost<localhost>, :localport($port));

loop 
	{
	my $connection = $listen.accept ;

	my $t0 = now ;

	my $elements = $connection.read(4).unpack('N') // 0 ;

	"$port:{DateTime.now}".say if $timestamp ;
	"receiving foldable, elements: $elements".say if $counter ;

	my @lines = my_receive(:$connection, :size($connection.read(4).unpack('N') // 0), :$counter) xx $elements ;
	my @line_lengths = ($connection.read(4).unpack('N') // 0) xx $elements ;
	my @folds = [ ($connection.read(4).unpack('N') // 0)  xx 4 ] xx $elements ;

	$connection.close ;
	"reception time: {now - $t0}".say if $timestamp ;
	
	my $foldable = Data::Dump::Tree::Foldable.new: :@lines, :@line_lengths, :@folds ;
	display_foldable($foldable) ;
	}

}

sub my_receive(:$connection, :$size, :$counter = 0)
{
my $received = 0 ;
my $line = '' ;

while $received < $size
	{
	my $buffer = $connection.read($size) ;
	$line ~= $buffer.decode('utf8') ;

	$received += $buffer.bytes ;
	"received: {$buffer.bytes}, total: $received".say if $counter ;
	}

$line
}

sub display_help
{
my $help = qq:to/EOH/ ;
Keyboard Mapping:
=================

q quit

Selection:
----------
e selection line up
d selection line down

Folding:
--------
r reset
a fold all
u unfold all
CursorLeft or CursorRight flip folding

Navigation:
-----------
CursorUp
CursorDown
PageUp
PageDown
Home
End


EOH

$help.say ;

}


