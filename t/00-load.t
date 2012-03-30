#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Data::UUID::Concise' ) || print "Bail out!\n";
}

diag( "Testing Data::UUID::Concise $Data::UUID::Concise::VERSION, Perl $], $^X" );
