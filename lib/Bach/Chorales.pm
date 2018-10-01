package Bach::Chorales;

# ABSTRACT: Display Bach Chorales

use Dancer2;
use Encoding::FixLatin qw(fix_latin);
use File::Temp qw(tempfile);
use File::Find::Rule;
use GraphViz2;

use lib '/Users/gene/sandbox/Music';
use Bach;

our $VERSION = '0.01';

=head1 NAME

Bach::Chorales - Display Bach Chorales

=head1 DESCRIPTION

A C<Bach::Chorales> object displays Bach corales.

=head1 ROUTES

=head2 /

Main page.

=cut

any '/' => sub {
    my $chorale = body_parameters->{chorale};

    my $img_dir = 'public/diagrams';

    # Purge old image files
    my $yesterday = time - ( 24 * 60 * 60 );
    my @imgs = File::Find::Rule->file()->name('*.png')->mtime("<$yesterday")->in($img_dir);
    for my $img ( @imgs ) {
        unlink $img;
    }

    my $file = 'public/BWV-titles.txt';

    my $chorales = {};

    open( my $fh, '<', $file ) or die "Can't read $file: $!";

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

    my $filename;
    $filename = _build_diagram( $img_dir, $chorale )
        if $chorale;

    template 'index' => {
        page_title => 'Bach::Chorales',
        chorale    => $chorale,
        chorales   => $chorales,
        image      => $filename,
    };
};

sub _build_diagram {
    my ( $dir, $id ) = @_;

    # Read in the Bach data
    my $data = 'public/jsbach_chorals_harmony.data';
    my ( undef, $progression ) = Bach::read_bach( $data, 0 );

    my %seen;
    my %score;

    for my $song ( keys %$progression ) {
        next unless $song eq $id;

        my $last = '';

        for my $cluster ( @{ $progression->{$song} } ) {
            my ( undef, undef, $chord ) = split /,/, $cluster;

            if ( $last && !grep { $last eq $_ } @{ $seen{$chord} } ) {
                push @{ $seen{$last} }, $chord;
                $score{ $last . ' ' . $chord }++;
            }

            $last = $chord;
        }

        last;
    }

    my $g = GraphViz2->new(
        global => { directed => 1 },
        node   => { shape => 'oval' },
        edge   => { color => 'grey' },
    );

    # Collect the key signatures
    my %keys;
    my $file = 'public/BWV-keys.txt';
    open( my $fh, '<', $file ) or die "Can't read $file: $!";
    while ( my $line = readline($fh) ) {
        chomp $line;
        my @parts = split /\s+/, $line;
        $keys{ $parts[0] } = $parts[1];
    }
    close $fh;

    my %nodes;
    my %edges;

    for my $i ( keys %seen ) {
        my $color = 'black';
        $color = 'red'
            if $i eq $keys{$id};

        $g->add_node( name => $i, color => $color )
            unless $nodes{$i}++;

        for my $j ( @{ $seen{$i} } ) {
            $color = 'black';
            $color = 'red'
                if $j eq $keys{$id};

            $g->add_node( name => $j, color => $color )
                unless $nodes{$j}++;

            my $name = $i . ' ' . $j;
            $g->add_edge( from => $i, to => $j, label => $score{$name} )
                unless $edges{$name}++;
        }
    }

    my( undef, $filename ) = tempfile( DIR => $dir, SUFFIX => '.png' );

    $g->run( format => 'png', output_file => $filename );

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