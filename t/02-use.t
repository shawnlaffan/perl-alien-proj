use strict;
use warnings;
use Test::More;
#use Config;
use Test::Alien;
use Alien::Proj4;

alien_ok 'Alien::Proj4';

#  nasty hack
$ENV{LD_LIBRARY_PATH}   = Alien::Proj4->dist_dir . '/lib';
$ENV{DYLD_LIBRARY_PATH} = Alien::Proj4->dist_dir . '/lib';


diag ('libs: '   . Alien::Proj4->libs);
diag ('cflags: ' . Alien::Proj4->cflags);
eval {
    diag ('Dynamic libs: ' . join ':', Alien::Proj4->dynamic_libs);
};
warn $@ if $@;

diag ('bin dir: ' . join (' ', Alien::Proj4->bin_dir));
my @bin = Alien::Proj4->bin_dir;
warn "no proj bin dir found via bin_dir method\n" if not @bin;

TODO: {
    local $TODO = 'leftover from gdal - might not need to be todo';
      #if $^O =~ /darwin|bsd/i;
    my $xs = do { local $/; <DATA> };
    xs_ok {xs => $xs, verbose => 1}, with_subtest {
      my($module) = @_;
      ok $module->version;
    };
}


done_testing();

 
__DATA__

//  A very simple test.  It really only tests that we can load proj4.

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "stdio.h"
#include <proj.h>

int main()
{
   printf("Hello, World!");
   return 0;
}

const char *
version(const char *class)
{
   return "v1";
}

MODULE = TA_MODULE PACKAGE = TA_MODULE
 
const char *version(class);
    const char *class;

