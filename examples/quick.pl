use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;

my $mol = HackaMol->new->read_file_mol(shift);

my $sasa = HackaMol::X::SASA->new(
              mol       => $mol,
              pdb_fn    => 'malonamide.pdb',
              exe       => '/Users/riccade/bin/surfrace5_0-dmr',              
              overwrite => 1,
              iradii    => 1,
              scratch   => 'malonamide',
);

$sasa->map_input;

use Data::Dumper;
my @res = $sasa->map_output;
print Dumper \@res;
