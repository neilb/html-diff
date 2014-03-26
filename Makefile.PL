#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'HTML::Diff',
    VERSION_FROM => 'lib/HTML/Diff.pm',

    PREREQ_PM    => {
        'Algorithm::Diff' => '1.15',
    },

    EXE_FILES    => ['htmldiff'],
);

