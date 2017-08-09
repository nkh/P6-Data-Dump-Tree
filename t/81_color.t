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
# 04_flat did not return the same result with color and no color
