
use Data::Dump::Tree::CursesFoldable ;

sub MAIN(Bool :$debug)
{
display_foldable(get_s, :page_size(15), :$debug, :title<first>) ;

#display_foldable(1..3, :$debug, :title<second>, :!color) ;
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

