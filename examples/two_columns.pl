
use Data::Dump::Tree ;
use Data::Dump::Tree::MultiColumns ;



my $d = Data::Dump::Tree.new does DDT::MultiColumns ;

$d.display_columns($d.get_dump_lines([1..4]), $d.get_dump_lines([6..12])) ;

$d.display_columns($d.get_dump_lines([1..4]), $d.get_dump_lines([6..12]), :width(50)) ;

$d.display_columns($d.get_dump_lines([1..4]), $d.get_dump_lines([6..12]), :width(50), :compact) ;

$d.display_columns($d.get_dump_lines([6..12]), $d.get_dump_lines([1..4])) ;

$d.display_columns($d.get_dump_lines([1..7]),$d.get_dump_lines([4..12]), $d.get_dump_lines([1..4])) ;

$d.display_columns(<line other_line>, $d.get_dump_lines([6..12]), $d.get_dump_lines([1..4])) ;

$d.display_columns(<line other_line>, $d.get_dump_lines([6..12]), $d.get_dump_lines([1..4]), :width(20)) ;

$d.display_columns(<line other_line>, $d.get_dump_lines([6..12]), 1..4, 1..6, :width(25)) ;

$d.display_columns(1..4) ;

$d.display_columns() ;


