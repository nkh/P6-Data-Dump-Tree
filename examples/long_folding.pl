
use Data::Dump::Tree ;

sub MAIN(Bool :$debug)
{
ddt :curses, get_s(600), :$debug, :title<first> ;
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

