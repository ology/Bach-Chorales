#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use Bach::Chorales;

Bach::Chorales->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Bach::Chorales;
use Plack::Builder;

builder {
    enable 'Deflater';
    Bach::Chorales->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use Bach::Chorales;
use Bach::Chorales_admin;

use Plack::Builder;

builder {
    mount '/'      => Bach::Chorales->to_app;
    mount '/admin'      => Bach::Chorales_admin->to_app;
}

=end comment

=cut

