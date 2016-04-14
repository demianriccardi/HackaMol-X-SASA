use Modern::Perl;
use HackaMol;
use HackaMol::Roles::SelectionRole;
use HackaMol::X::SASA;
use Moose::Util qw( ensure_all_roles ); #  to apply the role to the molecule object

my $sasa = HackaMol::X::SASA->new( scratch => "2SIC");

my $two_sic = HackaMol->new->pdbid_mol('2sic');

#run a sasa calculation to let freesasa toss out whatever atoms it may (i.e. multi occupancies, water)
my $sasa_mol = $sasa->calc_mol($two_sic);

#enable selections within the sasa_mol
ensure_all_roles($sasa_mol, 'HackaMol::Roles::SelectionRole');

my $ie = $sasa_mol->select_group("chain I .or. chain E");
my $i = $sasa_mol->select_group("chain I");
my $e = $sasa_mol->select_group("chain E");

$sasa_mol->push_groups($ie,$i,$e);

$sasa->calc_bygroup($sasa_mol);

#print Dumper $sasa->get_group_sasa($_) foreach (0 .. 2);


