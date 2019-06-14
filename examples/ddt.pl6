use Data::Dump::Tree ;
use Data::Dump::Tree::Ddt ; # for ddt_remote

my $s = [1, [1, [1..2]]] ;

ddt :title<no adverb>, $s ;
ddt :title<:print>, $s, :print ;
ddt ddt(:title<:get>, $s, :get) ;
ddt ddt(:title<:get_lines>, $s, :get_lines) ;
ddt ddt(:title<:get_lines-integrated>, $s, :get_lines_integrated) ;
ddt :title<:fold>, $s, :fold ;
ddt :title<:remote>, $s, :remote ;
ddt :title<:remote_fold>, $s, :remote_fold ;

my $d = DDT :!color  ;

$d.ddt: :title<no adverb>, $s ;
$d.ddt: :title<:print>, $s, :print ;
ddt $d.ddt(:title<:get>, $s, :get) ;
ddt $d.ddt(:title<:get_lines>, $s, :get_lines) ;
ddt $d.ddt(:title<:get_lines-integrated>, $s, :get_lines_integrated) ;
$d.ddt: :title<:fold>, $s, :fold ;
$d.ddt: :title<:remote>, $s, :remote, :remote_port(1234) ;
$d.ddt: :title<:remote_fold>, $s, :remote_fold ;

ddt_remote "ddt_remote" ;

