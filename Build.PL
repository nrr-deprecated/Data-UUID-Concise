use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Data::UUID::Concise',
    license             => 'perl',
    dist_author         => q{Nathaniel Reindl <nrr@corvidae.org>},
    dist_version_from   => 'lib/Data/UUID/Concise.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'Data-UUID-Concise-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
