#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'KiokuX::Model';

my $m = KiokuX::Model->new( dsn => "hash" );

can_ok( $m, qw(
	lookup

	store
	update
	insert

	clear_live_objects
) );

