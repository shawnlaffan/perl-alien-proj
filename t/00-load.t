use strict;
use warnings;
use Test::More;
use Test::Alien;
use File::Which;
use Config;

BEGIN {
    use_ok('Alien::proj') or BAIL_OUT('Failed to load Alien::proj');
}

alien_ok 'Alien::proj';

diag(
    sprintf(
        'Testing Alien::proj %s, Perl %s, %s',
        $Alien::proj::VERSION, $], $^X
    )
);


diag '';
diag 'Install type is ' . Alien::proj->install_type;
diag 'Proj version is ' . Alien::proj->version;
diag 'Aliens:';
my %alien_versions;
foreach my $alien (qw /Alien::sqlite Alien::libtiff Alien::curl/) {
    my $have = eval "require $alien";
    next if !$have;
    diag sprintf "%s: version: %s, install type: %s", $alien, $alien->version, $alien->install_type;
    $alien_versions{$alien} = $alien->version;
}

diag_dynamic_libs();

done_testing();


my $RE_DLL_EXT = qr/\.$Config::Config{so}$/i;
if ($^O eq 'darwin') {
    $RE_DLL_EXT = qr/\.($Config::Config{so}|bundle)$/i;
}

sub diag_dynamic_libs {
    if ($^O =~ /darwin/i) {
        _diag_dynamic_libs_macos();
    }
}

sub _diag_dynamic_libs_macos {
    my $OTOOL = which('otool')  or diag "otool not found, skipping dynamic lib summary";
    my @target_libs = Alien::proj->dynamic_libs;
    my %seen;
    while (my $lib = shift @target_libs) {
        #say "otool -L $lib";
        my @lib_arr = qx /$OTOOL -L $lib/;
        note qq["otool -L $lib" failed\n]
          if not $? == 0;
        diag join "\n", @lib_arr;
        shift @lib_arr;  #  first result is dylib we called otool on
        
        # follow any aliens or non-system paths
        foreach my $line (@lib_arr) {
            $line =~ /^\s+(.+?)\s/;
            my $dylib = $1;
            next if $seen{$dylib};
            next if $dylib =~ m{^/System};  #  skip system libs
            next if $dylib =~ m{^/usr/lib/libSystem};
            next if $dylib =~ m{^/usr/lib/};
            $seen{$dylib}++;
            #  add this dylib to the search set
            push @target_libs, $dylib;
        }
    }
}
