use Modern::Perl;
use HackaMol;
use HackaMol::Roles::SelectionRole;
use HackaMol::X::SASA;
use Moose::Util qw( ensure_all_roles ); #  to apply the role to the molecule object


my $ie = HackaMol->new->pdbid_mol('2sic');
ensure_all_roles($ic, 'HackaMol::Roles::SelectionRole');

my $i = $ie->select_group("chain I");
my $e = $ie->select_group("chain E");

$ie->push_groups($i,$e);

my $sasa = HackaMol::X::SASA->new( scratch => "2SIC");

my $ie_sasa_mol = $sasa->calc_mol($ie);



my $i_sasa_mol  = $sasa->calc_mol($i);
my $e_sasa_mol  = $sasa->calc_mol($e);


 
$sasa->map_input;

use Data::Dumper;
my @res = $sasa->map_output;
print Dumper \@res;

