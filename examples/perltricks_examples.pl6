use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;
use Terminal::ANSIColor ;

''.say ;
ddt [1..100], :nl, :indent('   ') ;

dd [1..100] ;
''.say ;
ddt [1..100], :flat({1, 5, 10}), :indent('   '), :nl  ;

dd True, [(1..100).pick: 100], :nl , :indent('   '), :nl ;
''.say ;
ddt True, [(1..100).pick: 100], :flat({1, 10, 10}), :nl, :indent('   ')  ;

dd True, [(1..300).pick: 300], :nl , :indent('   '), :nl ;
''.say ;
ddt True, [(1..300).pick: 300], :flat({1, 10, 12}), :nl, :indent('   ')  ;


role skinny
{
multi method get_elements (Array $a)
	{
	$a.list.map:
		{
		'',
		'',
		50 <= $_ < 60
			?? DVO(color('bold red') ~ $_.fmt("%4d") ~ color('reset'))
			!! DVO($_.fmt("%4d"))
		}
	}

}



ddt True, [(1..100).pick: 100], :flat({1, 10}), :does[skinny], :indent('   ')  ;


