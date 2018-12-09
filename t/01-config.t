use strict;
use warnings;
use Test::More;
use Alien::proj4;

diag( 'NAME=' . Alien::proj4->config('name') );
diag( 'VERSION=' . Alien::proj4->config('version') );

my $alien = Alien::proj4->new;

diag 'CFLAGS: ' . $alien->cflags;

SKIP: {
    skip "system libs may not need -I or -L", 2
        if $alien->install_type('system');
    like( $alien->cflags // '', qr/-I/ , 'cflags');
    like( $alien->libs // '',   qr/-L/ , 'libs');
}


done_testing();

