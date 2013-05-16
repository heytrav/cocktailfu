use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION   => '0.01',
    PREREQ_PM => {
        'Mojolicious'           => '3.97',
        'DBIx::Class'           => 0,
        'File::Basename'        => 0,
        'Time::HiRes'           => 0,
        'File::Spec::Functions' => 0,

    },
    test => { TESTS => 't/*.t' }
);