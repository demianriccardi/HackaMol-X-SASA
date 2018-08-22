use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;

my $mol = HackaMol->new->pdbid_mol(shift);

my $sasa = HackaMol::X::SASA->new(
              mol       => $mol,
              pdb_fn    => 'benzene.pdb',
              exe       => '/Users/demianriccardi/bin/surfrace5_0-dmr',              
              overwrite => 1,
              iradii    => 1,
              scratch   => 'c6h6',
);

say "scratch> ", $sasa->scratch; 
say "command> ", $sasa->command;
 
$sasa->map_input;

use Data::Dumper;
my @res = $sasa->map_output;
print Dumper \@res;

$sasa->load_sasa;

printf("%5s %5s %3i %8.2f\n", $_->name, $_->resname, $_->resid, $_->sasa) foreach $mol->all_atoms;

