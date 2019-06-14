
use Data::Dump::Tree ;

# use a module that's located in the examples directory
require ($*PROGRAM.parent(1).absolute ~ "/CustomSetup/CustomSetup.pm")  <CustomSetup> ;

my regex identifier  { \w+ }
my regex kvpair      { \s* <key=identifier> '=' <value=identifier> }

ddt "jack=password1" ~~ /<kvpair>*/, :title<key-value>, :does[CustomSetup] ;

