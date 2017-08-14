
use Data::Dump::Tree::CursesFoldable ;

sub MAIN(Bool :$debug)
{
display_foldable(get_s(600), :$debug, :title<first>) ;

#display_foldable(1..3, :$debug, :title<second>, :!color) ;
}

# ---------------------------------------------------------------------------------

sub get_s($n = 100)
{

my @p = item {};
for ^$n
        {
        my $ds = (Hash, Array).pick.new;
        my $to = @p[(^@p).pick];
        $to ~~ Hash
                ?? ($to{join '', ('a'..'z').pick xx 5} = $ds)
                !! $to.push($ds); @p.push($ds)
        }

@p[0]
}

