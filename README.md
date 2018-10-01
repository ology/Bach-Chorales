# Bach::Chorales
Display Bach Chorales

To run, unzip the chorales.zip file and move its (PDF and MIDI file) contents to
the public/chorales/ subdirectory:

> gunzip chorales.zip
> mv chorales/* public/chorales

Also, you must have my Bach.pm module which is located in my Music repo:

> git clone https://github.com/ology/Music.git

Then fix the path at the top of lib/Bach/Chorales.pm to your cloned location.

Then just start it up with say plack:

> plackup bin/app.psgi

Of course your system must have the required perl modules (as listed in the
Makefile.PL PREREQ_PM section).

> cpanm .

To install them.

![User interface](https://raw.githubusercontent.com/ology/Bach-Chorales/master/public/images/screenshot.png)
