
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

sub ddt_remote ($s, :$remote_port is copy, Bool :$counter, |other) is export 
{
$remote_port //= 3333 ;

use experimental :pack;

try 
	{
	my $c = IO::Socket::INET.new: :host<localhost>, :port($remote_port) ;
	my $string  = $s.Str ;

	$c.write: pack('N', $string.chars) ;
	"sending: {$string.chars}".say if $counter;

	#TODO: substr or Str.rotor (not implemented yet)
	for $string.comb.rotor(63 * 1024, :partial)
		{
		$c.write:  $_.join.encode('utf8') ;
		}

	$c.close ;
	}
		
if $!
	{
	"Error: Can't send below data to port:$remote_port time:{DateTime.now}".note ;
	$s.note ;

	return Nil ;
	}
else
	{
	return True ;
	}
}


sub ddt_remote_fold ($s, :$remote_port is copy, Bool :$counter, |other) is export 
{
use experimental :pack;

$remote_port //= 4444 ;

try 
	{
	require Data::Dump::Tree::CursesFoldable <&get_curses_foldable> ;

	my $c = IO::Socket::INET.new: :host<localhost>, :port($remote_port) ;

	my $string = (get_curses_foldable $s, |other).perl ;

	$c.write: pack('N', $string.chars) ;
	"sending: {$string.chars}".say if $counter;

	for $string.comb.rotor(63 * 1024, :partial)
		{
		$c.write:  $_.join.encode('utf8') ;
		}

	$c.close ;
	}
		
if $!
	{
	"Error: Can't send data to port:$remote_port time:{DateTime.now}\n$!".note ;
	}
}


sub ddt_remote_fold_object ($object, :$remote_port is copy, Bool :$counter, |other) is export 
{
use experimental :pack;
use Data::Dump::Tree::RemoteFoldObject ;

$remote_port //= 5555 ;

try 
	{
	my $rfo = RemoteFoldObject.new:
			:$object, 
			:options(| other.hash.grep: { $_.key eq 'remote_fold_object' }) ;

	my $c = IO::Socket::INET.new: :host<localhost>, :port($remote_port) ;
	my $string = $rfo.perl ;

	$c.write: pack('N', $string.chars) ;
	"sending: {$string.chars}".say if $counter;

	for $string.comb.rotor(63 * 1024, :partial)
		{
		$c.write:  $_.join.encode('utf8') ;
		}

	$c.close ;
	}
		
if $!
	{
	"Error: Can't send data to port:$remote_port time:{DateTime.now}\n$!".note ;
	}
}


