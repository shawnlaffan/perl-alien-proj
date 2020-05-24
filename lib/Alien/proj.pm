package Alien::proj;

use strict;
use warnings;
use parent qw( Alien::Base );
use Env qw ( @PATH @LD_LIBRARY_PATH @DYLD_LIBRARY_PATH );
use Capture::Tiny qw /:all/;

our $VERSION = '1.09';

my %also;
my @alien_bins = (__PACKAGE__->bin_dir);

foreach my $lib (qw /Alien::libtiff Alien::sqlite/) {
    if (eval "require $lib" && $lib->install_type eq 'share') {
        $also{$lib}++;
        if ($lib->install_type eq 'share') {
            push @alien_bins, $lib->bin_dir;
        }
    }
}
if (eval 'require Alien::curl' && 'Alien::curl'->install_type eq 'share') {
    #  we only compile in libcurl when there is a dynamic curl-config 
    if (-e 'Alien::curl'->dist_dir . '/dynamic/curl-config') {
        $also{'Alien::curl'}++;
        if (Alien::curl->install_type eq 'share') {
            push @alien_bins, Alien::curl->dist_dir . '/dynamic';
        }
    }
}

sub bin_dirs {
    my $self = shift;
    return @alien_bins;
}

sub dynamic_libs {
    my ($self) = @_;
    
    my @libs = $self->SUPER::dynamic_libs;
    
    foreach my $lib (sort keys %also) {
        push @libs, $lib->dynamic_libs;
    }
    
    return @libs;
}

sub run_utility {
    my ($self, $utility, @args) = @_;

    local $ENV{PATH} = $ENV{PATH};
    unshift @PATH, $self->bin_dirs;
      #if @alien_bins;

    #  something of a hack
    local $ENV{LD_LIBRARY_PATH} = $ENV{LD_LIBRARY_PATH};
    push @LD_LIBRARY_PATH, $self->dist_dir . '/lib';

    local $ENV{DYLD_LIBRARY_PATH} = $ENV{DYLD_LIBRARY_PATH};
    push @DYLD_LIBRARY_PATH, $self->dist_dir . '/lib';

    if ($self->install_type eq 'share') {
        my $bin = $self->bin_dir;
        if (defined $bin) {
            #  should strip path from $utility
            #  if user specified one?
            $utility = "$bin/$utility";
        }
    }
    #  handle spaces in path
    if ($^O =~ /mswin/i) {
        if ($utility =~ /\s/) {
            $utility = qq{"$utility"};
        }
    }
    else {
        $utility =~ s|(\s)|\$1|g;
    }


    #  user gets the pieces if it breaks
    capture {system $utility, @args};
}


1;

__END__

=head1 NAME

Alien::proj - Compile the Proj library

=head1 BUILD STATUS
 
=begin HTML
 
<p>
    <img src="https://img.shields.io/badge/perl-5.10+-blue.svg" alt="Requires Perl 5.10+" />
    <a href="https://travis-ci.org/shawnlaffan/perl-alien-proj"><img src="https://travis-ci.org/shawnlaffan/perl-alien-proj.svg?branch=master" /></a>
    <a href="https://ci.appveyor.com/project/shawnlaffan/perl-alien-proj"><img src="https://ci.appveyor.com/api/projects/status/0j4yh071yw7xyjxx?svg=true" /></a>
</p>

=end HTML

=head1 SYNOPSIS

    use Alien::proj;
    
    #  assuming you have populated @args already
    my ($stdout, $stderr, $exit_code)
      = Alien::proj->run_utility ('projinfo', @args);
    
    #  Get the bin dirs of Alien::proj and 
    #  all share-installed dependent aliens
    my @dirs = Alien::proj->bin_dirs;

    
=head1 DESCRIPTION

PROJ is a generic coordinate transformation software.  See L<https://proj.org/about.html>.

This Alien package is probably most useful for compilation of other modules, e.g. L<Geo::GDAL::FFI>,
although there are also utility programs that could be of use.

The Proj library can be accessed from Perl code via the L<Geo::Proj4> package.

Note: As of version 1.07, share installs will look for libtiff and curl support for proj 7
and include them if they are found, except that curl will not be added if it is statically compiled.


=head1 User defined config args

User defined arguments can be passed to the configure script for share install
using the ALIEN_PROJ_CONFIG_ARGS environment variable. 

=head1 REPORTING BUGS

Please send any bugs, suggestions, or feature requests to 
L<https://github.com/shawnlaffan/perl-alien-proj/issues>.

=head1 SEE ALSO

L<Geo::Proj4>

L<Geo::GDAL::FFI>

L<Alien::geos::af>

L<Alien::gdal>

L<Alien::proj4> (if you need to stay on proj version 4)

L<Geo::LibProj::cs2cs>


=head1 AUTHORS

Shawn Laffan, E<lt>shawnlaffan@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE


Copyright 2018- by Shawn Laffan


This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
