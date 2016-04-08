use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;


my $mol  = HackaMol -> new() -> pdbid_mol('2cba');
my $sasa = HackaMol::X::SASA->new( scratch => "CAII");

my $mol_sasa = $sasa->calc_mol($mol);
$sasa->print_summary; 
$sasa->write_out;

