#!/usr/bin/env perl
use strict;
use warnings;

use File::Copy;
use File::Find::Rule;
use List::Util 'first';

my $dir = 'public/chorales';

my @mid = File::Find::Rule->file()->name('*.mid')->in($dir);

my @pdf = File::Find::Rule->file()->name('*.pdf')->in($dir);

for my $pdf ( @pdf ) {
    ( my $pdf_name = $pdf ) =~ s/^$dir\/(\w+)\.pdf$/$1/;

    my $mid = first { /$pdf_name/ } @mid;

    ( my $mid_name = $mid ) =~ s/^$dir\/(\w+)\.mid$/$1/;

    my $new_pdf = $dir . '/' . $mid_name . '.pdf';

    move( $pdf, $new_pdf ) or die "Move failed for $pdf to $new_pdf: $!";
warn(__PACKAGE__,' ',__LINE__," MOVED: $pdf to ",$new_pdf,"\n");
}
