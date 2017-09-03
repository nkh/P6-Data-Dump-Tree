
unit module Data::Dump::Tree::Ddt ;

sub ddt_tp(|args ) is export
{
try 
	{
	require Data::Dump::Tree::TerminalFoldable <&display_foldable> ;
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
	require Data::Dump::Tree::TerminalFoldable <&get_foldable> ;
	my $f = get_foldable $s, |other ;

	my $c = IO::Socket::INET.new: :host<localhost>, :port($remote_port) ;

	$c.write: pack('N', $f.lines.elems) ;

	for $f.lines
		{
		my $blob = $_.encode('utf8') ;
		$c.write: pack('N', $blob.bytes) ;
		$c.write: $blob ;
		}

	$c.write: pack('N', $_) for $f.line_lengths ;
	$c.write: pack('NNNN', |$_) for $f.folds ;

	$c.close ;
	}

if $!
	{
	"Error: Can't send data to port:$remote_port time:{DateTime.now}\n$!".note ;
	}
}


