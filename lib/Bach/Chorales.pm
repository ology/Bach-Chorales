package Bach::Chorales;

# ABSTRACT: Display Bach Chorales

use Dancer2;
use Encoding::FixLatin qw(fix_latin);
use File::Temp qw(tempfile);
use File::Find::Rule;
use GraphViz2;

use lib $ENV{HOME} . '/sandbox/Music-BachChoralHarmony/lib';
use Music::BachChoralHarmony;

use constant TYPE    => 'png';
use constant IMG_DIR => 'public/diagrams';

our $VERSION = '0.02';

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

    my $bach = Music::BachChoralHarmony->new;
    my $chorales = $bach->parse();

    my $filename;
    $filename = _build_diagram( $chorales->{$chorale} )
        if $chorale;

    my $bwv_title;
    for my $id ( sort keys %$chorales ) {
        $bwv_title->{$id} = {
            bwv   => $chorales->{$id}{bwv},
            title => fix_latin( $chorales->{$id}{title} ),
        };
    }

    template 'index' => {
        page_title => 'Bach::Chorales',
        chorale    => $chorale,
        chorales   => $bwv_title,
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

sub _build_diagram {
    my ($progression) = @_;

    # Build the bigram score hash
    my %score;
    my $last;

    for my $event ( @{ $progression->{events} } ) {
        my $chord = $event->{chord};

        $score{ $last . ' ' . $chord }++
            if $last;

        $last = $chord;
    }

    # Build the network graph
    my $g = GraphViz2->new(
        global => { directed => 1 },
        node   => { shape => 'oval' },
        edge   => { color => 'grey' },
    );

    my %nodes;
    my %edges;

    my $key = $progression->{key};

    for my $bigram ( keys %score ) {
        my ( $i, $j ) = split ' ', $bigram;

        my $color = $i eq $key ? 'red' : 'black';

        $g->add_node( name => $i, color => $color )
            unless $nodes{$i}++;

        $color = $j eq $key ? 'red' : 'black';

        $g->add_node( name => $j, color => $color )
            unless $nodes{$j}++;

        $g->add_edge( from => $i, to => $j, label => $score{$bigram} )
            unless $edges{$bigram}++;
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

=head1 AUTHOR
 
Gene Boggs <gene@cpan.org>
 
=head1 COPYRIGHT AND LICENSE
 
This software is copyright (c) 2019 by Gene Boggs.
 
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
 
=cut
