use Modern::Perl;
use HackaMol;
use HackaMol::Roles::SelectionRole;
use HackaMol::X::SASA;
use Data::Dumper;

# set up two calculators
my $calc_erk2 = HackaMol::X::SASA->new( scratch => "4GT3");
my $calc_dfg  = HackaMol::X::SASA->new( scratch => "dfg");

# get pdb from rcsb
my $pdb_erk2 = HackaMol->new->pdbid_mol('4gt3');

#run a sasa calculation to let freesasa toss out whatever atoms it may (i.e. multi occupancies, water)
my $sasa_erk2 = $calc_erk2->calc_mol($pdb_erk2);
# dump out the results
print Dumper $calc_erk2->summary;

# this dfg has sasa in the bfacts for dfg buried in the protein 
my $erk2_dfg = $sasa_erk2->select_group('resid 160-167 .and. chain A');
$erk2_dfg->print_pdb;

my $total_sasa_dfg = 0;
$total_sasa_dfg += $_->bfact foreach $erk2_dfg->all_atoms;

say 'total SASA dfg inside: ', $total_sasa_dfg;
print "\n";

# just run another calculation by group to grab the summary
$sasa_erk2->push_groups($erk2_dfg,$sasa_erk2);
$calc_erk2->calc_bygroup($sasa_erk2);
print Dumper $calc_erk2->get_group_sasa(0); # buried dfg
print Dumper $calc_erk2->get_group_sasa(1); # all 

# or calculate the SASA for the exposed dfg
my $sasa_dfg = $calc_dfg->calc_mol($erk2_dfg);
print Dumper $calc_dfg->summary;
$sasa_dfg->print_pdb;



