
use Data::Dump::Tree ;

sub MAIN(Bool :$debug)
{
ddt :fold, get_s, :page_size(15), :$debug, :title<first> ;
}

# ---------------------------------------------------------------------------------

sub get_s
{
my class Tomatoe{ has $.color ;}

        [
	"111\n1212\ntest\nhello\ndone\n",
	{"222\n1212\ntest\nhello\ndone\n" => [1, [2.3]]},
        Tomatoe,
        [ [ [ Tomatoe, ] ], ],
        123,
        [ |1..3 ],
        ] ;
}

