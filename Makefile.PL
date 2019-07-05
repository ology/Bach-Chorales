use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME         => 'Bach::Chorales',
    AUTHOR       => q{Gene Boggs <gene@ology.net>},
    VERSION_FROM => 'lib/Bach/Chorales.pm',
    ABSTRACT     => 'Display Bach Chorales',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML' => 0,
        'Dancer2' => 0.206000,
        'Encoding::FixLatin' => 0,
        'File::Temp' => 0,
        'File::Find::Rule' => 0,
        'GraphViz2' => 0,
        'Music::BachChoralHarmony' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Bach-Chorales-*' },
);
