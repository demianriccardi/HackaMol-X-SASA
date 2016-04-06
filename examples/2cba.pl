use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;

my $mol = HackaMol->new->pdbid_mol('2cba');

my $sasa = HackaMol::X::SASA->new(
              mol       => $mol,
              pdb_fn    => '2cba_new.pdb',
              exe       => '/usr/local/bin/freesasa',              
              overwrite => 1,
              scratch   => 'testing',
);

say "scratch> ", $sasa->scratch; 
say "command> ", $sasa->command;
 
$sasa->map_input;

use Data::Dumper;
my ($sasa_mol,$res) = $sasa->map_output;
print Dumper \$res;

$sasa_mol->print_pdb;

