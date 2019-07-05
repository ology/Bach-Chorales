# Bach::Chorales
Display Bach Chorales

To run, clone this repository and unzip the chorales.zip file and move
its (PDF and MIDI file) contents to the public/chorales/ subdirectory:

> gunzip chorales.zip
> mv chorales/* public/chorales

Of course your system must have the required perl modules (as listed in the
Makefile.PL PREREQ_PM section).

> cpanm --installdeps .

To install them.

Then just start it up with say plack:

> plackup bin/app.psgi

User interface:

![User interface](https://raw.githubusercontent.com/ology/Bach-Chorales/master/public/images/screenshot.png)
