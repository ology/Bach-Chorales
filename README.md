# Bach::Chorales
Display Bach Chorales

To run, unzip the chorales.zip file and move its (PDF and MIDI file) contents to
the public/chorales/ subdirectory.

Then just start it up with say plack:

> plackup bin/app.psgi

Of course your system must have the required perl modules (as listed in the
Makefile.PL PREREQ_PM section).

> cpanm .

To install them.
