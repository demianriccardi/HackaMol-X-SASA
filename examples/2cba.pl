use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;


my $bldr = HackaMol->new();
my $mol = $bldr->pdbid_mol('2cba');

my $sasa = HackaMol::X::SASA->new(
              exe       => '/usr/local/bin/freesasa',              
              overwrite => 1,
              scratch   => 'testing',
);

my $mol_sasa = $sasa->calc_mol($mol);
$sasa->print_summary; 

