use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION   => '0.07',
    PREREQ_PM => {
        'Mojolicious'                      => '3.97',
        'DBIx::Class'                      => 0,
        'File::Basename'                   => 0,
        'Time::HiRes'                      => 0,
        'File::Spec::Functions'            => 0,
        'DBIx::Class'                      => 0,
        'DBIx::Class::Storage::Statistics' => 0,
        'HTML::FormHandler'                => 0,
        'HTML::FormHandler::Model::DBIC'   => 0,
        'TryCatch'                         => 0,
        'List::MoreUtils'                  => 0,
        'Smart::Comments'                  => 0,
        'Time::HiRes'                      => 0,
        'Test::Routine'                    => 0,

    },
    EXE_FILES => [qw(script/cocktail_fu)],
    test      => { TESTS => 't/*.t' }
);
