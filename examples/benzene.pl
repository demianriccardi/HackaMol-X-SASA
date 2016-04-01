use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;

my $c6h6_xyz =
'  C        0.00000        1.40272        0.00000
  C       -1.21479        0.70136        0.00000
  C       -1.21479       -0.70136        0.00000
  C        0.00000       -1.40272        0.00000
  C        1.21479       -0.70136        0.00000
  C        1.21479        0.70136        0.00000
  H        0.00000        2.49029        0.00000
  H       -2.15666        1.24515        0.00000
  H       -2.15666       -1.24515        0.00000
  H        0.00000       -2.49029        0.00000
  H        2.15666       -1.24515        0.00000
  H        2.15666        1.24515        0.00000
'; 

my $bnz = HackaMol->new->read_string_mol($c6h6_xyz,'xyz');

foreach my $c (grep {$_->symbol eq 'C'} $bnz->all_atoms){
  $c->record_name('ATOM');
  $c->name('CA');
}

my $sasa = HackaMol::X::SASA->new(
              mol       => $bnz,
              pdb_fn    => 'benzene.pdb',
              exe       => '/Users/riccade/bin/surfrace5_0-dmr',              
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

