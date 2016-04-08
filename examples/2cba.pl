use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;


my $bldr = HackaMol->new();
my $mol = $bldr->pdbid_mol('2cba');

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
$sasa->map_output;

say $sasa->sasa_total;
say $sasa->sasa_nonpolar;
say $sasa->sasa_polar;
#print Dumper \$res;
#$sasa_mol->print_pdb('quick.pdb');

