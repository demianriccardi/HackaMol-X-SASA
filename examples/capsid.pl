use Modern::Perl;
use HackaMol;
use HackaMol::Roles::SymopRole;
use HackaMol::X::SASA;
use Moose::Util qw(ensure_all_roles);

my $sasa = HackaMol::X::SASA->new( scratch => "1QGT");

my $bldr = HackaMol->new();
ensure_all_roles($bldr, 'HackaMol::Roles::SymopRole');

my $mol = $bldr->pdbid_mol("1QGT");

my $symops = $bldr->in_fn("1QGT.pdb")->slurp;

$bldr->apply_pdbstr_symops($symops,$mol);

use Data::Dumper;
say $sasa->command;
my $hash = $sasa->calc_mol_by_ts($mol, 1);
print Dumper $hash;
$hash = $sasa->calc_mol_by_ts($mol, 2);
print Dumper $hash;
$hash = $sasa->calc_mol_by_ts($mol, 1,2);
print Dumper $hash;
$hash = $sasa->calc_mol_by_ts($mol, 1 .. 10);
print Dumper $hash;
