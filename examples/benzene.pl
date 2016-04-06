use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;

my $c6h6_xyz =
'ATOM    168  CG  PHE A  20       7.255   3.799  17.700  1.00 11.07           C  
ATOM    169  CD1 PHE A  20       6.959   5.122  17.374  1.00 11.58           C  
ATOM    170  CD2 PHE A  20       7.562   2.816  16.744  1.00 11.55           C  
ATOM    171  CE1 PHE A  20       6.987   5.441  15.994  1.00 12.99           C  
ATOM    172  CE2 PHE A  20       7.586   3.128  15.383  1.00 11.98           C  
ATOM    173  CZ  PHE A  20       7.266   4.455  15.038  1.00 11.70           C  
'; 

my $bnz = HackaMol->new->read_string_mol($c6h6_xyz,'pdb');

my $sasa = HackaMol::X::SASA->new(
              mol       => $bnz,
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

