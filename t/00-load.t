use strict;
use warnings;
use Test::More;
use Test::Alien;

BEGIN {
    use_ok('Alien::proj4') or BAIL_OUT('Failed to load Alien::proj4');
}

alien_ok 'Alien::proj4';

diag(
    sprintf(
        'Testing Alien::proj4 %s, Perl %s, %s',
        $Alien::gdal::VERSION, $], $^X
    )
);

done_testing();

