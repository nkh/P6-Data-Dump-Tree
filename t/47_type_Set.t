
#!/usr/bin/env perl6

use Test ;
plan 1 ;

use Data::Dump::Tree ;
use Data::Dump::Tree::ExtraRoles ;
use Data::Dump::Tree::DescribeBaseObjects ;

my $d = Data::Dump::Tree.new(:!color, width => 79, display_perl_address => False) ;
my $s = set "zero" => 0, "one" => 1, "two" => 2 , "two" => 2, 7 ;

my $dump_1 = $d.get_dump(title => 'Set', $s );
is($dump_1.lines.elems, 5, '5 dump lines') or diag $dump_1 and diag $s.perl ;

