use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;

my $mol = HackaMol->new->pdbid_mol("2cba");

my $sasa = HackaMol::X::SASA->new(
              mol     => $mol,
              pdb_fn  => '2cba.pdb',
              exe     => '/Users/riccade/bin/surfrace5_0-dmr',              
              overwrite => 1,
              scratch => 'tmp',
);

$sasa->map_input;

use Data::Dumper;
my @res = $sasa->map_output;
print Dumper \@res;
