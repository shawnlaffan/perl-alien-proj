use strict;
use warnings;
use Test::More;
use Test::Alien;
use Alien::proj;


my ($result, $stderr, $exit) = Alien::proj->run_utility ("projinfo");
like ($stderr, qr{Rel. \d\.\d\.\d, .+ \d{4}},
    'Got expected result from projinfo utility');
diag '';
diag ("\nUtility results:\n" . $result);
diag ($stderr) if $stderr;
diag "Exit code is $exit";
diag '';


done_testing();

