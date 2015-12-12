#!/usr/bin/env perl6

use Test;
use Data::Dump::Tree;

plan 1;

ok True, 'colors';

todo 'test colors' ;
# ANSI colors available
	# BW output
	# colored ouput

# no ANSI colors available => handle graciously
