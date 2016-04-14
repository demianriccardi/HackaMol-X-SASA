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

has 'by_atom' => (  # to print out the PDB with radii and SASA
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

has 'write_fn' => (
    is     => 'rw',
    isa    => Path,
    coerce => 1,
);

has 'overwrite' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
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
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_stdout',
    clearer   => 'clear_stdout',
);

has 'stderr' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_stderr',
    clearer   => 'clear_stderr',
);

has 'group_sasa' => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[HashRef]',
    default => sub { [] },
    lazy    => 1,
    handles => {
        get_group_sasa     => 'get',
        set_group_sasa     => 'set',
        all_group_sasa     => 'elements',
        clear_group_sasa   => 'clear',
        map_group_sasa     => 'map',
    },  

);

sub build_command {

    my $self = shift;
    my $cmd  = join( ' ',
        $self->exe,        '-p',             $self->probe,
        '-t',              $self->threads,   '-n',
        $self->resolution, $self->algorithm, $self->by_atom,
        $self->pdb_fn );
    return $cmd;

}

sub _build_map_in {

    # this builds the default behavior, can be set anew via new
    return sub { return ( shift->write_input(@_) ) };

}

sub _build_map_out {

    # this builds the default behavior, can be set anew via new
    my $sub_cr = sub {
        my $self = shift;
        my ( $stdout, $stderr ) = $self->capture_sys_command;
        my @summary =
          grep { m/freesasa/ .. m/MODEL/ } split( '\n', $stdout );    #@lines;
        my %results;
        $results{RESULTS}{ $_->[0] } = $_->[1]
          foreach map { [ split('\s+:\s+') ] }
          grep        { m/Total/ .. m/CHAIN/ } @summary;

        $self->stdout($stdout);
        $self->stderr($stderr);
        $self->sasa_nonpolar( $results{RESULTS}{Apolar} );
        $self->sasa_polar( $results{RESULTS}{Polar} );
        $self->sasa_total( $results{RESULTS}{Total} );
    };

    return $sub_cr;
}

sub calc {
    my $self = shift;
    if($self->has_stdout){
      carp "overwriting stdout" if $self->has_stdout; 
      $self->clear_stdout;
      $self->clear_stderr;
    }
    $self->map_input(@_);
    $self->map_output;
}

sub calc_bygroup{

  my $self = shift;
  my $mol  = shift;
  unless ($mol->has_groups){  
    carp "calc_bygroup> mol has no groups" ;
    return(0) ;
  }
  foreach my $ig (0 .. $mol->count_groups - 1){
    my $group = $mol->get_groups($ig);
    $self->calc($group);
    my %hash = ( 
                nonpolar => $self->sasa_nonpolar,
                polar    => $self->sasa_polar,
                total    => $self->sasa_total,
    );
    $self->set_group_sasa($ig,\%hash);
  }  
}

sub calc_mol {  #run the calculation and return the molecule
    my $self = shift;
    $self->calc(@_);
    return $self->stdout_mol;
}

sub stdout_mol {

    # process stdout and return molecule
    my $self = shift;
    return 0 unless $self->has_stdout;
    my $stdout = $self->stdout;
    my $mol = HackaMol->new->read_string_mol( $stdout, 'pdb' );
    do { $_->vdw_radius( $_->occ ); $_->sasa( $_->bfact ) }
      foreach
      $mol->all_atoms; # $stdout has radii and sasa in the occ and bfact columns
    return ($mol);
}

sub write_out {
    my $self = shift;
    my $file = shift;
    return 0 unless $self->has_stdout;
    if ($file) {   # to write wherever without having the added assignment steps
        $self->write_fn($file)->spew( $self->stdout );
    }
    else {         #default
        $self->sasa_fn->spew( $self->stdout );
    }
}

sub read_out {
    my $self   = shift;
    my $file   = shift || croak "must pass file for reading";
    my $stdout = $self->sasa_fn($file)->slurp;
    $self->stdout($stdout);
}


sub summary {
    my $self = shift;
    return 0 unless $self->has_stdout;
    my $stdout = $self->stdout;
    my %summary;
    my @summary =
      grep { m/freesasa/ .. m/MODEL/ } split( '\n', $stdout );    #@lines;
    $summary{PARAMETERS}{ $_->[0] } = $_->[1]
      foreach map { [ split('\s+:\s+') ] }
      grep        { m/algorithm/ .. m/slices/ } @summary;
    $summary{INPUT}{ $_->[0] } = $_->[1]
      foreach map { [ split('\s+:\s+') ] }
      grep        { m/source/ .. m/atoms/ } @summary;
    $summary{RESULTS}{ $_->[0] } = $_->[1]
      foreach map { [ split('\s+:\s+') ] }
      grep        { m/Total/ .. m/CHAIN/ } @summary;
    return \%summary;
}

sub print_summary {
    my $self = shift;
    return 0 unless $self->has_stdout;
    my $stdout = $self->stdout;
    my @summary =
      grep { m/freesasa/ .. m/MODEL/ } split( '\n', $stdout );    #@lines;
    print $_ . "\n" foreach @summary;
}

sub BUILD {
    my $self = shift;

    if ( $self->has_scratch ) {
        $self->scratch->mkpath unless ( $self->scratch->exists );
        $self->sasa_fn( $self->scratch . '/' . $self->sasa_fn );
    }

    unless ( $self->has_exe ) {
        $self->exe("/usr/local/bin/freesasa");
    }

    unless ( $self->has_command ) {
        my $cmd = $self->build_command;
        $self->command($cmd);
    }

    return;
}

sub write_input {
    my $self    = shift;
    my $mol;
    $mol        = shift  || $self->mol;
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
