use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;

my $hexane =
'C                  -3.059  -0.706  -0.667
C                  -1.932   0.243  -0.352
C                  -0.621  -0.492  -0.171
C                   0.508   0.465   0.146
C                   1.820  -0.269   0.327
C                   2.946   0.680   0.642
H                  -4.015  -0.144  -0.797
H                  -3.194  -1.446   0.158
H                  -2.850  -1.268  -1.610
H                  -2.172   0.815   0.583
H                  -1.828   0.994  -1.180
H                  -0.379  -1.063  -1.105
H                  -0.722  -1.241   0.658
H                   0.266   1.037   1.081
H                   0.609   1.215  -0.682
H                   2.059  -0.841  -0.608
H                   1.716  -1.019   1.155
H                   3.903   0.119   0.771
H                   2.737   1.242   1.585
H                   3.081   1.421  -0.183';
 

my $hex = HackaMol->new->read_string_mol($hexane,'xyz');


foreach my $c (grep {$_->symbol eq 'C'} $hex->all_atoms){
  $c->record_name('ATOM');
  $c->name('CA');
}

my $sasa = HackaMol::X::SASA->new(
              mol       => $hex,
              pdb_fn    => 'hexane.pdb',
              exe       => '/Users/demianriccardi/bin/surfrace5_0-dmr',              
              overwrite => 1,
              iradii    => 1,
              scratch   => 'hexane',
);

say "scratch> ", $sasa->scratch; 
say "command> ", $sasa->command;
 
$sasa->map_input;

use Data::Dumper;
my @res = $sasa->map_output;
print Dumper \@res;


