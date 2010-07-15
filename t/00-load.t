#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Entities' ) || print "Bail out!
";
}

diag( "Testing Entities $Entities::VERSION, Perl $], $^X" );
