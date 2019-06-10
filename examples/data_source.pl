
use Data::Dump::Tree ;
use JSON::Tiny ;

my $JSON =
Q<<{
  "glossary": {
    "title": "example glossary"
  }
}>> ;

my $parsed = JSON::Tiny::Grammar.parse: $JSON ;

# use a module that's located in the examples directory
require ($*PROGRAM.parent(1).absolute ~ "/CustomSetup/DataSource.pm6")  <DataSource> ;

use Data::Dump::Tree::ExtraRoles ;
ddt $parsed, :title<JSON >, :does[DDTR::PerlString,DDTR::MatchDetails] ;
ddt $parsed, :title<JSON >, :!color, :does[DataSource, DDTR::PerlString,DDTR::MatchDetails] ;

ddt [1, 2, [ 3, 4, [Str],], {a => 1}, (a => [1, 2])], :title<struct> ;
ddt [1, 2, [ 3, 4, [Str],], {a => 1}, (a => [1, 2])], :title<struct>, :!color, :does[DataSource] ;

# following line fixed (believe it or not) error:
# Cannot mix in non-composable type Any into object of type Data::Dump::Tree
# which happens during the ddt call ... above!
# bug report https://github.com/rakudo/rakudo/issues/2983
my regex {1}

