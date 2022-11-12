# Bach::Chorales
Display Bach Chorales

To run, clone this repository and unzip the chorales.zip file and move
its (PDF and MIDI file) contents to the public/chorales/ subdirectory:

    gunzip chorales.zip
    mv chorales public/

Of course your system must have the required perl modules (as listed in
the cpanfile).

    cpanm --installdeps .

To install them.

Then start it with, say, Plack:

    plackup bin/app.psgi

And then browse to http://127.0.0.1:5000/ - Voila!

User interface:

![User interface](https://raw.githubusercontent.com/ology/Bach-Chorales/master/UI.png)
