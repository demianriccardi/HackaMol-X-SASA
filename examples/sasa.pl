use Modern::Perl;
use HackaMol;
use HackaMol::X::SASA;

my $hexane =
'ATOM      1  N   TYR     7       5.410 -17.900  11.040  1.7    54.47  0     0         
ATOM      2  CA  TYR     7       5.580 -16.470  10.730  2      11.85  0     0         
ATOM      3  C   TYR     7       5.130 -15.630  11.940  1.7    0.660  0     0         
ATOM      4  O   TYR     7       3.980 -15.730  12.380  1.5    16.40  0     0         
ATOM      5  CB  TYR     7       5.240 -15.750   9.420  2      28.71  0     0         
ATOM      6  CG  TYR     7       4.010 -14.910   9.570  1.7    0      0     0         
ATOM      7  CD1 TYR     7       4.020 -13.790  10.420  1.7    0      0     0         
ATOM      8  CD2 TYR     7       2.950 -15.080   8.670  1.7    20.52  0     0         
ATOM      9  CE1 TYR     7       2.880 -13.000  10.540  1.7    0.581  0     0         
ATOM     10  CE2 TYR     7       1.800 -14.290   8.800  1.7    25.82  0     0         
ATOM     11  CZ  TYR     7       1.800 -13.200   9.680  1.7    2.612  0     0         
ATOM     12  OH  TYR     7       0.680 -12.360   9.740  1.6    45.41  0     0         '; 

my $hex = HackaMol->new->read_string_mol($hexane,'pdb');

say $_->occ foreach $hex->all_atoms;
