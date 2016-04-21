use Modern::Perl;
use HackaMol::X::SASA;


my $sasa = HackaMol::X::SASA->new();
$sasa->read_out("quick.out");
$sasa->print_summary;

