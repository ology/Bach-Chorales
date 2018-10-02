package Bach::Chorales;

# ABSTRACT: Display Bach Chorales

use Dancer2;
use Encoding::FixLatin qw(fix_latin);
use File::Temp qw(tempfile);
use File::Find::Rule;
use GraphViz2;

use lib '/Users/gene/sandbox/Music';
use Bach;  # https://github.com/ology/Music/blob/master/Bach.pm

use constant IMG_DIR => 'public/diagrams';
use constant DATA    => 'public/data/jsbach_chorals_harmony.data';
use constant TITLES  => 'public/data/BWV-titles.txt';
use constant KEYS    => 'public/data/BWV-keys.txt';
use constant TYPE    => 'png';

our $VERSION = '0.01';

=head1 NAME

Bach::Chorales - Display Bach Chorales

=head1 DESCRIPTION

A C<Bach::Chorales> object displays Bach chorales.

=head1 ROUTES

=head2 /

Main page.

=cut

any '/' => sub {
    my $chorale = body_parameters->{chorale};

    _purge_diagrams();

    my $chorales = _build_chorales();

    my $filename;
    $filename = _build_diagram($chorale)
        if $chorale;

    template 'index' => {
        page_title => 'Bach::Chorales',
        chorale    => $chorale,
        chorales   => $chorales,
        image      => $filename,
    };
};

sub _purge_diagrams {
    my $threshold = time - ( 30 * 60 );

    my @imgs = File::Find::Rule->file()
                               ->name( '*.' . TYPE )
                               ->mtime("<$threshold")
                               ->in(IMG_DIR);
    unlink $_ for @imgs;
}

sub _build_chorales {
    my $chorales = {};

    open( my $fh, '<', TITLES ) or die "Can't read " . TITLES . ": $!";

    while ( my $line = readline($fh) ) {
        chomp $line;
        next if $line =~ /#/ || $line =~ /^\s*$/ || $line =~ /UCI-ID/;

        my @song = split /\s+/, $line, 3;

        $chorales->{ $song[0] } = {
            bwv   => $song[1],
            title => fix_latin( $song[2] ),
        } if @song == 3;
    }

    close $fh;

    return $chorales;
}

sub _build_diagram {
    my ($id) = @_;

    # Read in the Bach data
    my ( undef, $progression ) = Bach::read_bach( DATA, 0 );

    # Build the bigram and score hashes
    my %bigram;
    my %score;

    my $last = '';

    for my $cluster ( @{ $progression->{$id} } ) {
        my ( undef, undef, $chord ) = split /,/, $cluster;

        if ( $last ) {
            $score{ $last . ' ' . $chord }++;

            if ( !grep { $last eq $_ } @{ $bigram{$chord} } ) {
                push @{ $bigram{$last} }, $chord;
            }
        }

        $last = $chord;
    }

    # Collect the key signatures
    my %keys;
    open( my $fh, '<', KEYS ) or die "Can't read " . KEYS . ": $!";
    while ( my $line = readline($fh) ) {
        chomp $line;
        my @parts = split /\s+/, $line;
        $keys{ $parts[0] } = $parts[1];
    }
    close $fh;

    # Build the network graph
    my $g = GraphViz2->new(
        global => { directed => 1 },
        node   => { shape => 'oval' },
        edge   => { color => 'grey' },
    );

    my %nodes;
    my %edges;

    for my $i ( keys %bigram ) {
        my $color = $i eq $keys{$id} ? 'red' : 'black';

        $g->add_node( name => $i, color => $color )
            unless $nodes{$i}++;

        for my $j ( @{ $bigram{$i} } ) {
            $color = $j eq $keys{$id} ? 'red' : 'black';

            $g->add_node( name => $j, color => $color )
                unless $nodes{$j}++;

            my $name = $i . ' ' . $j;
            $g->add_edge( from => $i, to => $j, label => $score{$name} )
                unless $edges{$name}++;
        }
    }

    my( undef, $filename ) = tempfile( DIR => IMG_DIR, SUFFIX => '.' . TYPE );

    $g->run( format => TYPE, output_file => $filename );

    $filename =~ s/^public//;

    return $filename;
}

true;

__END__

=head1 SEE ALSO

L<Dancer2>

L<Encoding::FixLatin>

L<File::Temp>

L<File::Find::Rule>

L<GraphViz2>

=cut
