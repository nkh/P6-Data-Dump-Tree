use Data::Dump::Tree ;
use Data::Dump::Tree::CursesFoldable ;
use Data::Dump::Tree::Ddt ;

sub MAIN
{
my $s = [1, [1, [1..2]]] ;

#ddt_remote_bin "ddt_remote".encode('utf-8') ;

my $size = ddt :remote_fold, get_s(), :title<remote_fold>  ;

"Send $size bytes of fold data to remote.".say if $size ;
}

# -----------------------------------------------------------------------------------------
              
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

