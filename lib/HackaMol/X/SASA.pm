package HackaMol::X::SASA;

#ABSTRACT: Solvent Accessible Surface Area calculations
use Moose;
use MooseX::StrictConstructor;
use Moose::Util::TypeConstraints;
use Math::Vector::Real;
use MooseX::Types::Path::Tiny qw(AbsPath) ;
use HackaMol; # for building molecules
use File::chdir;
use namespace::autoclean;
use Carp;
use MooseX::Types::Path::Tiny qw/Path Paths AbsPath AbsPaths/;

with qw(
        HackaMol::X::Roles::ExtensionRole 
);

has 'radii_fn' => (
    is        => 'rw',
    isa       => Path,
    coerce    => 1,
    default   => 'radii.txt',
);

has 'pdb_fn' => (
    is        => 'rw',
    isa       => Path,
    coerce    => 1,
    default   => 'mol.pdb',
);

has 'overwrite' => (
    is        => 'rw',
    isa       => 'Bool',
    default   => 0,
    lazy      => 1,
);


has 'probe' => (
    is        => 'rw',
    isa       => 'Num',
    default   => 1.4,
    lazy      => 1,
);

has 'iradii' => (
    is        => 'rw',
    isa       => 'Int',
    default   => 1,
    lazy      => 1,
);

has 'mode' => (
    is        => 'rw',
    isa       => 'Int',
    default   => 1,
    lazy      => 1,
);

sub build_command {
    my $self = shift;
    my $cmd = join(' ', $self->exe, $self->iradii, $self->pdb_fn,
                        $self->probe, $self->mode
                  ); 
    # we always capture output
    return $cmd;
}

sub _build_map_in {
    # this builds the default behavior, can be set anew via new
    return sub { return ( shift->write_input ) };
}

sub _build_map_out {
    # this builds the default behavior, can be set anew via new
    my $sub_cr = sub {
        my $self = shift;
        my $qr   = qr/Total area = (\d+.\d+), Polar area= (\d+.\d+) , Non-polar area= (\d+.\d+)/;
        my ( $stdout, $sterr ) = $self->capture_sys_command;
        my @TA_polar_nonpolar = map { m/$qr/; [ $1, $2, $3 ] }
                      grep { m/$qr/ }
                      split( "\n", $stdout );
        return (@TA_polar_nonpolar);
    };
    return $sub_cr;
}

sub BUILD {
    my $self = shift;

    if ( $self->has_scratch ) {
        $self->scratch->mkpath unless ( $self->scratch->exists );
    }


    unless ( $self->has_command ) {
        my $cmd = $self->build_command;
        $self->command($cmd);
    }

    return;
}

sub write_input {
    my $self = shift;
  #dumb for now
  my $radii = '      Set 1                         Set 2
(Richards, 1977)   (Richmond & Richards, 1978)

ch4 2.00                1.90
ch3 1.70                1.70
nh4 2.00                1.70
nh3 1.70                1.70
oh4 1.60                1.40
oh3 1.50                1.40
sh  2.00                1.80
st  1.80                1.80
zn  0.64                0.64
fe  0.64                0.64';

    my $mol = $self->mol;
    my $pdbfile = $self->pdb_fn->stringify;

    if ($self->overwrite) {
       $mol->print_pdb($pdbfile);
    }
    else { 
      if (-e $pdbfile) {
        carp "SASA $pdbfile already exists. set overwrite(1) to overwrite";
      } 
      else {
        $mol->print_pdb($pdbfile);
      }
    }

    $self->radii_fn->spew($radii);
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
