
use Data::Dump::Tree ;
use Data::Dump::Tree::Ddt ; # for ddt_remote

# a data structure we know will be more than 64 KB in size when we send it
# over the network
my $s = [|1..1_500];

"object.perl.chars: {$s.perl.chars}".say ;

# send a textual representation
ddt :title<:remote>, $s, :remote ;

# send a foldable object, IE a rendering of the object, slow to EVAL but already rendered
ddt :title<:remote_fold>, $s, :remote_fold ;



