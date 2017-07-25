
use Data::Dump::Tree ;
use Data::Dump::Tree::MultiColumns ;

display_columns get_dump_lines_integrated([1..4]), get_dump_lines_integrated([6..12]) ;

display_columns get_dump_lines_integrated([1..4]), get_dump_lines_integrated([6..12]), :width(50) ;

display_columns get_dump_lines_integrated([1..4]), get_dump_lines_integrated([6..12]), :width(50), :compact ;

display_columns get_dump_lines_integrated([6..12]), get_dump_lines_integrated([1..4]) ;

display_columns get_dump_lines_integrated([1..7]), get_dump_lines_integrated([4..12]), get_dump_lines_integrated([1..4]) ;

display_columns <line other_line>, get_dump_lines_integrated([6..12]), get_dump_lines_integrated([1..4]) ;

display_columns <line other_line>, get_dump_lines_integrated([6..12]), get_dump_lines_integrated([1..4]), :width(20) ;

display_columns <line other_line>, get_dump_lines_integrated([6..12]), 1..6, :width(20) ;

display_columns 1..4 ;

display_columns ;


