#!/usr/bin/env perl

use strict;
use warnings;
use Test::Moose;
use Test::More;
use Test::Fatal qw(lives_ok dies_ok);
use Test::Dir;
use Test::Warn;
use HackaMol::X::SASA;
use HackaMol;
use Math::Vector::Real;
use File::chdir;
use Cwd;

BEGIN {
    use_ok('HackaMol::X::SASA');
}

my $cwd = getcwd;

# coderef

{    # test HackaMol class attributes and methods

    my @attributes = qw(
                        sasa_polar sasa_nonpolar sasa_total
                        threads algorithm 
                       );
    my @methods    = qw(
                        build_command write_input map_input map_output 
                       );

    my @roles = qw(HackaMol::Roles::ExeRole HackaMol::Roles::PathRole);

    map has_attribute_ok( 'HackaMol::X::SASA', $_ ), @attributes;
    map           can_ok( 'HackaMol::X::SASA', $_ ), @methods;
    map          does_ok( 'HackaMol::X::SASA', $_ ), @roles;

}

done_testing();

