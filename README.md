# Data::Dump::Tree 

## for perl6

Date::Dump::Tree - Renders data structures in a tree fashion with colors

Just use the modul and dump(your_data). 

See lib/Data/Dump/Tree.pod for a complete documentation.


## usage

```perl6
	use Data::Dump::Tree ;

	say dump @your_data, :title('A complex structure'), ... ;

	my $d = Data::Dump::Tree.new ;
	$d.dump @your_data ;

	$dumper does role { .... } ;
	$d.dump @your_data ;

```

output example:
```
	A complex structure [5] @0
	|- 0 = text.Str
	|- 1 = den: 10 num: 31.Rat
	|- 2 = {2} @1
	|  |- a => 1.Int
	|  `- b => string.Str
	|- 3 = .MyClass @2
	|  |- $.size = 6.Str
	|  `- $.name = P6 class.Str
	`- 4 = (3) @3
	   |- 0 = [0 .. 1].Match
	   |- 1 = [1 .. 2].Match
	   `- 2 = [2 .. 3].Match


```

![Imgur](http://i.imgur.com/P7eRSwl.png?1)

