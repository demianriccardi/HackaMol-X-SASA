package HackaMol::X::SASA;

#ABSTRACT: Solvent Accessible Surface Area calculations
use Moose;
use MooseX::StrictConstructor;
use Moose::Util::TypeConstraints;
use MooseX::Types::Path::Tiny qw(AbsPath);
use HackaMol;    # for building molecules
use File::chdir;
use namespace::autoclean;
use Carp;
use MooseX::Types::Path::Tiny qw/Path Paths AbsPath AbsPaths/;

with qw(
  HackaMol::X::Roles::ExtensionRole
);

has 'config_fn' => (
    is      => 'rw',
    isa     => Path,
    coerce  => 1,
    lazy    => 1,
    default => 'config.txt',
);

has 'by_atom' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => '-B',    # clear it if not wanting to slurp up pdb.
);

has 'pdb_fn' => (
    is      => 'rw',
    isa     => Path,
    coerce  => 1,
    lazy    => 1,
    default => 'mol_sasa.pdb',
);

has 'sasa_fn' => (
    is      => 'rw',
    isa     => Path,
    coerce  => 1,
    lazy    => 1,
    default => 'freesasa.out',
);

has 'overwrite' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    lazy    => 1,
);

has 'probe' => (
    is      => 'rw',
    isa     => 'Num',
    default => 1.4,
    lazy    => 1,
);

has 'algorithm' => (
    is      => 'rw',
    isa     => 'Str',
    default => '-L',    # -L (--lee-richards)  -S (--shrake-rupley)
    lazy    => 1,
);

has 'resolution' => (
    is      => 'rw',
    isa     => 'Num',
    lazy    => 1,
    default => 20,      # default for -L algorithm
);

has 'threads' => (
    is      => 'rw',
    isa     => 'Num',
    lazy    => 1,
    default => 2,      
);

has 'sasa_total' => (
    is  => 'rw',
    isa => 'Num',
);

has 'sasa_polar' => (
    is  => 'rw',
    isa => 'Num',
);

has 'sasa_nonpolar' => (
    is  => 'rw',
    isa => 'Num',
);

has 'stdout' => (
    is  => 'rw',
    isa => 'Str',
);

has 'stderr' => (
    is  => 'rw',
    isa => 'Str',
);

sub build_command {
    my $self = shift;
    my $cmd  = join( ' ',
        $self->exe, '-p', $self->probe, '-t', $self->threads, '-n', $self->resolution,
        $self->algorithm, $self->by_atom, $self->pdb_fn );
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
        my ( $stdout, $stderr ) = $self->capture_sys_command;
        my @summary = grep { m/freesasa/ .. m/MODEL/ } split ('\n', $stdout); #@lines;
        my %results;
#        $results{PARAMETERS}{$_->[0]} = $_->[1] foreach map {[split('\s+:\s+')]} grep { m/algorithm/ .. m/slices/}  @summary;
#        $results{INPUT}{$_->[0]}      = $_->[1] foreach map {[split('\s+:\s+')]} grep { m/source/ .. m/atoms/}  @summary;
        $results{RESULTS}{$_->[0]}    = $_->[1] foreach map {[split('\s+:\s+')]} grep { m/Total/ .. m/CHAIN/}  @summary;
#        use Data::Dumper;
#        print Dumper \%results;
        $self->stdout($stdout);
        $self->stderr($stderr);
        $self->sasa_nonpolar($results{RESULTS}{Apolar});
        $self->sasa_polar($results{RESULTS}{Polar});
        $self->sasa_total($results{RESULTS}{Total});
    };

    return $sub_cr;
}

#        my $mol = HackaMol->new->read_string_mol( $stdout, 'pdb' );
#        return ( $mol, \%results );

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
    my $self    = shift;
    my $mol     = $self->mol;
    my $pdbfile = $self->pdb_fn->stringify;

    if ( $self->overwrite ) {
        $mol->print_pdb($pdbfile);
    }
    else {
        if ( -e $pdbfile ) {
            carp "SASA $pdbfile already exists. set overwrite(1) to overwrite";
        }
        else {
            $mol->print_pdb($pdbfile);
        }
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
