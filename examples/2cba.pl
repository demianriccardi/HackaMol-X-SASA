use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;


my $mol  = HackaMol -> new() -> pdbid_mol('2cba');
my $sasa = HackaMol::X::SASA->new( scratch => "CAII");

my $mol_sasa = $sasa->calc_mol($mol);
say $mol->natoms; $mol->print_pdb("shit.pdb");
say $mol_sasa->natoms; $mol_sasa->print_pdb("sasashit.pdb");

$sasa->print_summary; 

