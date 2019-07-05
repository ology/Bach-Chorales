requires "Dancer2" => "0.206000";
requires "Encoding::FixLatin" => "0";
requires "File::Temp" => "0";
requires "File::Find::Rule" => "0";
requires "GraphViz2" => "0";
requires "Music::BachChoralHarmony" => "0";

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
