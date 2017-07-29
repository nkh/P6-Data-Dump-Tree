
use Data::Dump::Tree ;
use Data::Dump::Tree::MultiColumns ;

for
	(
	(get_dump_lines_integrated([1..4]), get_dump_lines_integrated([6..12]), :width(50)),
	(get_dump_lines_integrated([1..4]), get_dump_lines_integrated([6..12])),
	(get_dump_lines_integrated([1..4]), get_dump_lines_integrated([6..12]), :width(50), :compact),
	(get_dump_lines_integrated([6..12]), get_dump_lines_integrated([1..4])),
	(get_dump_lines_integrated([1..7]), get_dump_lines_integrated([4..12]), get_dump_lines_integrated([1..4])),
	(<line other_line>, get_dump_lines_integrated([6..12]), get_dump_lines_integrated([1..4])),
	(<line other_line>, get_dump_lines_integrated([6..12]), get_dump_lines_integrated([1..4]), :width(20)),
	(<line other_line>, get_dump_lines_integrated([6..12]), 1..6, :width(20)),
	((1..4),),
	(),
	)
	{
	my (:@a, :@p) := $_.classify: { $_ !~~ Pair ?? 'a' !! 'p' }; 

	say get_columns(|@a, |%(@p)) ;
	}

